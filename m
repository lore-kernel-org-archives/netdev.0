From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Thu, 3 Jul 2014 03:34:04 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org> <20140702.182807.1245632778216212860.davem@davemloft.net> <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:50521 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGCCeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 22:34:05 -0400
Received: from localhost.localdomain ([127.0.0.1]:38979 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6816071AbaGCCeEcDvFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 04:34:04 +0200
In-Reply-To: <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Jul 2014, Maciej W. Rozycki wrote:

> > > @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
> > >  						/* The ones required by tmd2 */
> > >  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
> > >  		if (i < 3 && ZERO)
> > > -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> > > -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> > > +			printk("%d: 0x%8.8x(%#0*lx)\n",
> > > +			       i, leptr, 2 * (int)sizeof(long) + 2,
> > > +			       (long)lp->tx_buf_ptr_cpu[i]);
> > 
> > Please just use "%p", no casts required.
> 
>  Hmm, there was something about %p that made me reject it, however I can't 
> recall what it was and I can get the desired output with this format 
> specifier (the NULL special case difference can be ignored, the pointers 
> printed here won't ever be NULL).  Sending an update right away.

 Ah, there it is:

drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
drivers/net/ethernet/amd/declance.c:503: warning: '#' flag used with '%p' printf format
drivers/net/ethernet/amd/declance.c:520: warning: '#' flag used with '%p' printf format

That's obviously GCC's incompatibility to our implementation.  I'm not 
sure if that can be worked around, but I'll see what I can do about it.

  Maciej
