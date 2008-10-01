From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: A few design questions wrt the hso driver.
Date: Wed, 01 Oct 2008 16:10:22 +0200
Message-ID: <48E384CE.8040200@option.com>
References: <Pine.LNX.4.44L0.0810011006430.2421-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Bird <ajb@spheresystems.co.uk>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:38602 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbYJAOKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:10:32 -0400
In-Reply-To: <Pine.LNX.4.44L0.0810011006430.2421-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,
Thank you good sir, I'll look into it.

Alan Stern wrote:
> On Wed, 1 Oct 2008, Denis Joseph Barrow wrote:
> 
>> Now a more involved question.
>> The suspend resume code in hso.c hso_get_activity &
>> hso_put_activity code to me looks very racy but the code seems to be working relatively reliably
>> because the schedule resume stuff happens at a slow pace. 
>> Despite the codes simplicity I do not have a good feel for whether it
>> is stable or not & don't feel like an authority on how to make the code better.
>>
>> The more obvious possible issues I see with it the code are,
>> I could be wrong if I am please say so.
>> 1) On smp systems there is a
>> workqueue for each cpu which means
>> that if one cpu workqueue is not going to be scheduled soon & the other 
>> workqueue is, if a suspend is queued on the cpu which is busy
>> & a resume is later queued on the cpu with soon to run workqueue
>> the resume will most likely happen before the suspend i.e. out of order.
>>
>> 2) Also only the schedule_work will only queue the
>> request once so if multiple schedule works happen
>> only the first one is accepted even if you wanted
>> to change the order of the suspend resume requests later on
>> they won't reorder.
> 
> I agree that the code looks very racy.  You may be able to improve it
> by using the new infrastructure in this patch:
> 
> 	http://marc.info/?l=linux-usb&m=122279021325200&w=2
> 
> It is intended specifically for handling asynchronous suspends and 
> resumes.
> 
> Alan Stern


-- 
best regards,
D.J. Barrow
