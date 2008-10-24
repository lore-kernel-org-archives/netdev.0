From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 24 Oct 2008 10:12:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0810241008060.13114-100000@iolanthe.rowland.org>
References: <49019392.3050306@t2data.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: USB list <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	David Brownell <david-b@pacbell.net>
To: Per Hallsmark <per.hallsmark@t2data.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:60025 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753301AbYJXOMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 10:12:23 -0400
In-Reply-To: <49019392.3050306@t2data.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Oct 2008, Per Hallsmark wrote:

> Alan Stern wrote:
> > On Thu, 23 Oct 2008, Per Hallsmark wrote:
> >
> >   
> >> Enable more aggressive autosuspend in usbnet.
> >> Some commenting and cleanups done.
> >> Signed-off-by: Per Hallsmark <per@hallsmark.se>
> >>     
> >
> > I've been considering submitting the patch below.  It would help your 
> > work; you could remove all the "waker" stuff.
> >   

> So, if I understand the patch correctly, the waker's in cdc-acm, cdc-wdm 
> and usbnet
> could then be removed and a change to use *_async() should be done?

That's right.  There are a few races you have to worry about (maybe
they're already taken into account -- I'm not familiar with these
drivers):

	What happens if a new URB has to be submitted at about the
	same time as an autosuspend occurs?

	What happens if you call one of the *_async() routines at the
	same time as some other CPU updates intf->pm_usage_count?

> I work with a module that have usb interfaces driven by above three 
> drivers so it
> could be a good testing case I guess.
> Generic solutions are the best so if this approach would work then of 
> course a
> change should be made I think. I have no time to test it in near time 
> though,
> perhaps later next week.

Okay, let me know how it turns out.

Alan Stern

