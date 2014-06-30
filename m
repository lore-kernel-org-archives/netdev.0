From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: RE: [PATCH] declance: Fix 64-bit compilation warnings
Date: Mon, 30 Jun 2014 10:58:23 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1406301055450.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406282329040.15455@eddie.linux-mips.org> <1403996818.9064.48.camel@joe-AO725> <063D6719AE5E284EB5DD2968C1650D6D172693EB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'Joe Perches' <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:37947 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbaF3J6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 05:58:25 -0400
Received: from localhost.localdomain ([127.0.0.1]:54638 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859949AbaF3J6XOmVaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 11:58:23 +0200
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172693EB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jun 2014, David Laight wrote:

> > > @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
> > >  						/* The ones required by tmd2 */
> > >  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
> > >  		if (i < 3 && ZERO)
> > > -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> > > -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> > > +			printk("%d: 0x%8.8x(%#0*lx)\n",
> > > +			       i, leptr, (int)sizeof(long),
> > > +			       (long)lp->tx_buf_ptr_cpu[i]);
> > 
> > You need to adjust the "*" and sizeof(long) with +2 for the
> > 0x prefix in the output length here.
> 
> Do you need all the leading zeros at all?

 For output alignment; plus the change is not intended to change 
semantics, but just to address the lack of 64-bit cleanliness.

  Maciej
