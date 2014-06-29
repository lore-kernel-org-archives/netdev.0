From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] declance: Fix 64-bit compilation warnings
Date: Sun, 29 Jun 2014 02:30:56 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1406290226380.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406282329040.15455@eddie.linux-mips.org> <1403996818.9064.48.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:34175 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbaF2Ba6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 21:30:58 -0400
Received: from localhost.localdomain ([127.0.0.1]:50866 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6822067AbaF2Ba4IFUI6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 03:30:56 +0200
In-Reply-To: <1403996818.9064.48.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Jun 2014, Joe Perches wrote:

> > @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
> >  						/* The ones required by tmd2 */
> >  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
> >  		if (i < 3 && ZERO)
> > -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> > -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> > +			printk("%d: 0x%8.8x(%#0*lx)\n",
> > +			       i, leptr, (int)sizeof(long),
> > +			       (long)lp->tx_buf_ptr_cpu[i]);
> 
> You need to adjust the "*" and sizeof(long) with +2 for the
> 0x prefix in the output length here.

 Good catch, thanks!  MIPS kernel addresses always have their MSB set so 
this is hard to notice in testing.  But also the width has to be doubled 
first, to take two digits per byte into account too.  Sending an updated 
change right away, as soon as it builds and boots.

  Maciej
