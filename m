From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw: Readd zd_addr_t cast
Date: Sat, 10 Feb 2007 08:36:06 +0100
Message-ID: <20070210073606.GA12495@p15091797.pureserver.info>
References: <20070210012718.3B6E87B409F@zog.reactivated.net> <200702100702.15264.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	rpjday@mindspring.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:51497 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbXBJHgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 02:36:07 -0500
Content-Disposition: inline
In-Reply-To: <200702100702.15264.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07-02-10 07:02 Michael Buesch wrote:

> On Saturday 10 February 2007 02:27, Daniel Drake wrote:
> > Robert P.J. Day's recent commit ("getting rid of all casts of k[cmz]alloc()
> > calls") introduced a sparse warning for zd1211rw, related to our type-checking
> > of addresses.
> > 
> > 	zd_chip.c:116:15: warning: implicit cast to nocast type
> > 
> > This patch readds the type cast, it is correct.
> > 
> > Signed-off-by: Daniel Drake <dsd@gentoo.org>
> > 
> > Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
> > ===================================================================
> > --- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
> > +++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
> > @@ -113,7 +113,7 @@ int zd_ioread32v_locked(struct zd_chip *
> >  
> >  	/* Allocate a single memory block for values and addresses. */
> >  	count16 = 2*count;
> > -	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> > +	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> >  		                   GFP_NOFS);
> 
> Unrelated, but I am wondering since quite some time why you pass GFP_NOFS here.
> Any special reason? I think in general there is no good reason for code outside
> of the VFS to use this flag.
> IMHO you should pass either GFP_ATOMIC or GFP_KERNEL.

Michael,

you are right. The theory has been to prevent the NFS operations
while being in the kernel. But no driver in drivers/net is using
it. I will exchange it by GFP_KERNEL, this code is protected by a
mutex and is not atomic.

Ciao,

Uli

-- 
Uli Kunitz
