From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Can someone please try...
Date: Tue, 23 Jan 2007 10:21:34 +0100
Message-ID: <200701231021.34995.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <200701222200.19784.mb@bu3sch.de> <1169532880.8258.2.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44540
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932920AbXAWJW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 04:22:57 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1169532880.8258.2.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 January 2007 07:14, Pavel Roskin wrote:
> On Mon, 2007-01-22 at 22:00 +0100, Michael Buesch wrote: 
> > > No more random crashes.  There is still a crash if I rmmod the driver
> > > while wlan0 is up, but it's a separate issue, and it's easy to avoid
> > > (unlike the interface going down).  I hope to look at it soon.
> > 
> > Did you apply that d80211 rmmod crash fix that Michael Wu posted
> > recently. I bet it will fix your issue.
> 
> I have tried the patch, and it doesn't fix the problem.  It's a separate
> problem.  It happens when bcm43xx_interrupt_handler() is called on a
> device that has already been removed.

That shouldn't happen and doesn't for me.

> It looks like 
> bcm43xx_wireless_core_stop() should be called from
> bcm43xx_one_core_detach().

No, well... . remove_interface should have been called by the stack, no?

> Unfortunately, I cannot come to a satisfactory solution yet.  If I call
> bcm43xx_wireless_core_stop() with the mutex held, the driver won't
> unload if the interface is down.  If I don't hold the mutex, it would
> happen when the interface is up.
> 
> By the way, I think it's a bad idea to unlock any mutexes or other locks
> set outside the function.  The caller assumes that the lock is held
> until it (the caller) unlocks it.  Unlocking locks from other functions
> breaks this convention. 

It would result in a deadlock, if we don't unlock it there. That's
perfectly fine.

> > > I think the assert() should be replaced with a FIXME, which would not
> > > annoy end users so much.
> > 
> > Well, no. It's kind of: Michael, go ahead and fix that crap!
> > So I'd like to keep it to get me to fix it. :D
> 
> I, for one, prefer to keep my to-do items in my to-do list, but I don't
> want to distract you with petty arguments from fixing the real problem.

Well, assert() statements are there to find bugs. And if there is a bug,
they trigger. That's pretty much the semantics of an assert() statement.
I'm not sure why you want to hide a bug.

Either way, in this case it seems like the code is right
and just the assert() mask is wrong. But that's only this way by luck.
Could easily have been the other way around. ;)
Specs were slightly wrong at this point.

But as I said, I will commit a fix today.

> > Hm, is this 4318? It is known to loose lots of packets.
> 
> No, it's 4312.

That has got the same problems.

-- 
Greetings Michael.
