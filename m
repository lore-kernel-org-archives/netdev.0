From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Wed, 02 Jul 2014 20:05:34 -0700
Message-ID: <1404356734.14741.18.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0087.hostedemail.com ([216.40.44.87]:33636 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751525AbaGCDFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 23:05:38 -0400
In-Reply-To: <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-03 at 03:34 +0100, Maciej W. Rozycki wrote:
> On Thu, 3 Jul 2014, Maciej W. Rozycki wrote:
> 
> > > > @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
> > > >  						/* The ones required by tmd2 */
> > > >  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
> > > >  		if (i < 3 && ZERO)
> > > > -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> > > > -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> > > > +			printk("%d: 0x%8.8x(%#0*lx)\n",
> > > > +			       i, leptr, 2 * (int)sizeof(long) + 2,
> > > > +			       (long)lp->tx_buf_ptr_cpu[i]);
> > > 
> > > Please just use "%p", no casts required.
> > 
> >  Hmm, there was something about %p that made me reject it, however I can't 
> > recall what it was and I can get the desired output with this format 
> > specifier (the NULL special case difference can be ignored, the pointers 
> > printed here won't ever be NULL).  Sending an update right away.
> 
>  Ah, there it is:
> 
> drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
> drivers/net/ethernet/amd/declance.c:503: warning: '#' flag used with '%p' printf format
> drivers/net/ethernet/amd/declance.c:520: warning: '#' flag used with '%p' printf format
> 
> That's obviously GCC's incompatibility to our implementation.  I'm not 
> sure if that can be worked around, but I'll see what I can do about it.

The kernel vsprintf implementation doesn't prefix
pointers with 0x, so you can use 0x%p if you really
want that with a leading prefix, but you don't have
to use it.
