From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] wan/x25_asy: integer overflow in x25_asy_change_mtu()
Date: Thu, 17 Jul 2014 11:14:31 +0200
Message-ID: <1405588471.10255.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140717080310.GB477@mwanda>
	 <063D6719AE5E284EB5DD2968C1650D6D1727688E@AcuExch.aculab.com>
	 <20140717085818.GG18338@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43613 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755237AbaGQJOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 05:14:41 -0400
In-Reply-To: <20140717085818.GG18338@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 11:58 +0300, Dan Carpenter wrote:
> On Thu, Jul 17, 2014 at 08:45:58AM +0000, David Laight wrote:
> > From: Dan Carpenter
> > > If "newmtu * 2 + 4" is too large then it can cause an integer overflow
> > > leading to memory corruption.  Btw, "newmtu" is not allowed to be a
> > > negative number because of the check in dev_set_mtu(), so that's ok.
> > 
> > This still allows large numbers to be used to allocate almost all of
> > kernel memory - causing massive issues elsewhere.
> > 
> > I'd have thought a 'sanity' limit on the mtu would be more appropriate.
> > I've no idea which mtu is being changed here, and I can't even remember
> > the x.25 protocol well enough if it is an x.25 level 3 limit.
> > But I suspect that a 'sanity' bound to 1MB won't cause any grief.
> > 
> 
> I agree that a sanity check is probably better but I don't think kmalloc
> can allocate more than 128k (or something.  It's arch dependent as
> well).  So using 1MB is almost no different from my original patch.

kmalloc() can typically allocate up to 4MB (MAX_ORDER = 11) if you are
lucky (enough contiguous memory)

Really, I do not think we should allow more than 65534 MTU, which would
allocate two 128K blocks at most.

If some bigger MTU was really needed, we would have switch to vmalloc()
a long time ago.

X.25 was limited to 4096 bytes packets if I remember well, and I used
128 and 256 only, that was a long time ago.

( link speeds were limited to 128kbps, it would be quite impractical to
use large packets...)
