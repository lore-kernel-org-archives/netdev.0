From: Karsten Keil <kkeil@suse.de>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 08:34:07 +0200
Message-ID: <20080923063407.GB23815@pingi.kke.suse.de>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080922.191826.16007223.davem@davemloft.net> <20080923022731.GE25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	kkeil@suse.de, netdev@vger.kernel.org, ak@linux.intel.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40703 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbYIWGeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 02:34:11 -0400
Content-Disposition: inline
In-Reply-To: <20080923022731.GE25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:27:32AM +0200, Andi Kleen wrote:
> On Mon, Sep 22, 2008 at 07:18:26PM -0700, David Miller wrote:
> > From: akpm@linux-foundation.org
> > Date: Mon, 22 Sep 2008 14:51:03 -0700
> > 
> > > - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
> > > - Fix timer handler prototype to be correct
> > > - Comment ugly SMP race I didn't fix.
> > > 
> > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Applied to net-next-2.6
> 
> I'm hoping someone takes care of the SMP race. I think the timers
> need all reference counting similar to other network objects to
> handle this cleanly.

Yes I already have some idea without refcounting, checking how much time is left
if it is more as some treshhold (maybe 2 or 10 jiffies) delete the timer,
if not mark it for deletion only and delete it during the run function without
triggering the device. In the race case it would trigger the device too but
this is not critical.
Another easier implementation could mark it only, without trying to delete
it imediately. But in this case unneeded timers would hang around (on big busy PBX
boxes this can be some 100) for some time.

What do you think ?

> 
> It might be a good idea to mark it BROKEN_ON_SMP in the meantime.

No really needed, normally the timers deleted long time before running out
or never so it should never see such a race, maybe if the application is
aborted and cleanup all timers this could happen but also this should be no
normal case, since usually you do not kill a PBX if any connections are
active.
Yes it could be used to do some deny on service kind of attack, so it should
be fixed at all.


-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
