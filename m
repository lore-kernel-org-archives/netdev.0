From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 15:33:04 -0400
Message-ID: <20060627193259.GE1207@tuxdriver.com>
References: <20060626212547.GE30706@tuxdriver.com> <200606271725.26037.mb@bu3sch.de> <44A158EB.90406@garzik.org> <200606271831.02108.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:9233 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030251AbWF0Tdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 15:33:36 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200606271831.02108.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 06:31:01PM +0200, Michael Buesch wrote:
> On Tuesday 27 June 2006 18:12, Jeff Garzik wrote:
> > Michael Buesch wrote:
> > > So, I will submit a patch to lower the udelay(10) to udelay(1)
> > > and we can close the discussion? ;)
> > 
> > No, that totally avoids my point.  Your "otherwise idle machine" test is 
> > probably nowhere near worst case in the field, for loops that can 
> > potentially lock the CPU for a long time upon hardware fault.  And then 
> > there are the huge delays in specific functions that I pointed out...
> 
> wtf are you requesting from me?
> 1) I proved you that the loop does only spin _once_ or even _less_.
> 2) If the hardware is faulty, the user must replace it.
>    Because, if the hardware is faulty, it can crash the whole
>    machine anyway, obviously.
> 
> 3) There is no "huge delay". I proved it with my logs.
>    -> No CPU hog => Nothing to fix.

Michael,

I think Jeff's concern is that by using udelay you are busy-waiting.
And, the for loop limit of 100000 means you could freeze the kernel
for up to a whole second.  Granted that this won't happen very often
and in the grand scheme of things a second isn't all _that_ long,
but still it would be better to avoid a delay like that -- a second
could be the time it takes to avoid a meltdown at the nuclear power
plant. :-)

Could you not use msleep instead of udelay (and scale the for loop
appropriately)?  What would be the problem with that?  It would get
rid of the busy waiting.

To be fair, this code was already in the driver and was only being
moved by this patch.  Still, what better time to fix it than now? :-)

I'll go ahead and reshuffle wireless-2.6 to drop this patch.  A new
patch that passes muster w/ Jeff will be most welcome! :-)

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
