From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: A few design questions wrt the hso driver.
Date: Wed, 01 Oct 2008 14:16:10 +0200
Message-ID: <48E36A0A.9080003@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh@suse.d
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
I'm currently beginning to test the modem functionality of the hso driver.

Simple question first.
There is this comment near the top of hso.c
Interface 2:	Standard modem interface - circuit switched interface, should
		not be used.

Who put this comment in & why? is it obselete?
The modem port at least works on minicom till the point
of setting up the ppp connection.

I'm not a modem guru
Also has anyone ideas on how to test the hso_serial_tiocmset
TIOCM_RTS TIOCM_DTR stuff.

My project lead Filip wants me to implement code to report
on DCD/RxCarrier DTR/TxCarrier to the kernel any ideas
where I might find an example of such stuff implemented
in the kernel & a means to test it.

Now a more involved question.
The suspend resume code in hso.c hso_get_activity &
hso_put_activity code to me looks very racy but the code seems to be working relatively reliably
because the schedule resume stuff happens at a slow pace. 
Despite the codes simplicity I do not have a good feel for whether it
is stable or not & don't feel like an authority on how to make the code better.

The more obvious possible issues I see with it the code are,
I could be wrong if I am please say so.
1) On smp systems there is a
workqueue for each cpu which means
that if one cpu workqueue is not going to be scheduled soon & the other 
workqueue is, if a suspend is queued on the cpu which is busy
& a resume is later queued on the cpu with soon to run workqueue
the resume will most likely happen before the suspend i.e. out of order.

2) Also only the schedule_work will only queue the
request once so if multiple schedule works happen
only the first one is accepted even if you wanted
to change the order of the suspend resume requests later on
they won't reorder.

I've also noticed a spurious crash twice near the top of hso_serial_close as
in the latest hso 1.6 driver shipped by option, I've been
unable to acertain the cause of this crash but suspect the suspend/resume
disconnect device reconnect device gremlins are at work here.

-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
