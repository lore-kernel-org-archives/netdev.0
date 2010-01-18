From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 3/9] drivers/net: Eliminate useless code
Date: Mon, 18 Jan 2010 06:47:30 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1001180646460.12648@ask.diku.dk>
References: <Pine.LNX.4.64.1001161657400.28745@ask.diku.dk>
 <20100117.193140.153138395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57922 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab0ARFrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 00:47:33 -0500
In-Reply-To: <20100117.193140.153138395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Jan 2010, David Miller wrote:

> From: Julia Lawall <julia@diku.dk>
> Date: Sat, 16 Jan 2010 16:57:56 +0100 (CET)
> 
> > The variable qdev is initialized twice to the same (side effect-free)
> > expression.  Drop one initialization.
> > 
> > A simplified version of the semantic match that finds this problem is:
> > (http://coccinelle.lip6.fr/)
> > 
> > // <smpl>
> > @forall@
> > idexpression *x;
> > identifier f!=ERR_PTR;
> > @@
> > 
> > x = f(...)
> > ... when != x
> > (
> > x = f(...,<+...x...+>,...)
> > |
> > * x = f(...)
> > )
> > // </smpl>
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> Something in your patch creation process is corrupting these
> patches.
> 
> > diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> > index f922294..4ef0afb 100644
> > --- a/drivers/net/qla3xxx.c
> > +++ b/drivers/net/qla3xxx.c
> > @@ -4087,9 +4087,8 @@ static void __devexit ql3xxx_remove(struct pci_dev *pdev)
> >  	struct ql3_adapter *qdev = netdev_priv(ndev);
> >  
> >  	unregister_netdev(ndev);
> > -	qdev = netdev_priv(ndev);
> >  
> >  	ql_disable_interrupts(qdev);
> >  
> > --
> 
> That hunk header states that after the line is removed there should
> be 8 lines present in the hunk, but the patch only shows 7 such
> lines.
> 
> I suspect something is eating the final line of your patches.

Oops, sorry.  I will try again.  I'm surprised that checkpatch didn't 
complain.

julia
