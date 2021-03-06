# encoding: utf-8
class SinhvienController < DashboardController
        
  before_filter :get_sinhvien
  before_filter :get_survey
  before_filter :current_sinhviens
  before_filter :check_complete, :only => [:update]
  

  def show  	  	  	  	
  	redirect_to(root_path) unless @current_sinhvien  	
  	flash[:success] = "Bạn đang làm bài thăm dò môn: #{@current_sinhvien.tenmon}"
  end

  def update
  	  @current_sinhvien.update_voted!	  	
	  	@radio_answers.each do |k,v|
	  		Ketqua.create!(:answer_id => v.to_i, :sinhvien_id => @current_sinhvien.id)
	  	end
	  	@text_answers.each do |k,v|	  		
	  		begin
	  			ket = Ketqua.create!(:answer_id => k[6..-1].to_i ,:answer_text => v.to_s, :sinhvien_id => @current_sinhvien.id)	  				  				  			
		  	rescue => e    
		  		File.open("D:\\mylog.txt", 'w') { |file| file.write(e.message) }
		  	end
	  	end

	  	check_condition 	
  end
  private
  	  
  protected
	  def check_complete
	  	@myparams = params.select {|k,v| v != nil and !v.empty?  }

	  	@radio_answers = @myparams.select {|k,v|  k.include?('_radio_')}
	  	@text_answers = @myparams.select {|k,v| k.include?('_text_')}
	  	@radio_questions = @current_survey.questions.select { |q| q.question_type_id == 1}


	  	if @radio_answers.size < @radio_questions.size then
			redirect_to @current_sinhvien  , :flash => { :error => "Please complete." }
			return
	    end 
  	  end

  	  def current_sinhviens
	  	@current_sinhviens ||= Sinhvien.by_masinhvien(current_user.masinhvien).by_survey(current_survey.id).by_voted  	
	  	if @current_sinhviens.size > 1 then 
	  		@current_status = "Môn tiếp theo"
	  	else
	  		@current_status = "Kết thúc"
	  	end
	  end

  	  def get_sinhvien  	  	
  	  	sv = Sinhvien.find(params[:monhoc_id])
  	  	if !sv.voted? then
  	  		@current_sinhvien = sv 
  	  	else
  	  		@current_sinhvien = nil
  	  	end
  	  end
	 
	  def get_survey
	  	@current_survey ||= @current_sinhvien.survey
	  end

	private
	  def check_condition	  	
		if !@current_sinhviens.empty? then 
	  		@current_sinhvien = @current_sinhviens.first
	  		flash[:success] = "Bạn đang làm bài thăm dò môn: #{@current_sinhvien.tenmon}"
	  		redirect_to sinhvien_path(@current_survey, @current_sinhvien )
	  		return
	  	else
	  		redirect_to root_path  , :flash => { :notice => "Cám ơn bạn đã hoàn thành bài thăm dò." }
	  		return
	  	end
	  end
 	
end
