From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: A few design questions wrt the hso driver.
Date: Wed, 1 Oct 2008 10:09:05 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0810011006430.2421-100000@iolanthe.rowland.org>
References: <48E36A0A.9080003@option.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48E36A0A.9080003-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2008, Denis Joseph Barrow wrote:

> Now a more involved question.
> The suspend resume code in hso.c hso_get_activity &
> hso_put_activity code to me looks very racy but the code seems to be working relatively reliably
> because the schedule resume stuff happens at a slow pace. 
> Despite the codes simplicity I do not have a good feel for whether it
> is stable or not & don't feel like an authority on how to make the code better.
> 
> The more obvious possible issues I see with it the code are,
> I could be wrong if I am please say so.
> 1) On smp systems there is a
> workqueue for each cpu which means
> that if one cpu workqueue is not going to be scheduled soon & the other 
> workqueue is, if a suspend is queued on the cpu which is busy
> & a resume is later queued on the cpu with soon to run workqueue
> the resume will most likely happen before the suspend i.e. out of order.
> 
> 2) Also only the schedule_work will only queue the
> request once so if multiple schedule works happen
> only the first one is accepted even if you wanted
> to change the order of the suspend resume requests later on
> they won't reorder.

I agree that the code looks very racy.  You may be able to improve it
by using the new infrastructure in this patch:

	http://marc.info/?l=linux-usb&m=122279021325200&w=2

It is intended specifically for handling asynchronous suspends and 
resumes.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
