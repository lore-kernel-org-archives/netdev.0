From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] drivers/net: Eliminate useless code
Date: Sun, 17 Jan 2010 19:31:40 -0800 (PST)
Message-ID: <20100117.193140.153138395.davem@davemloft.net>
References: <Pine.LNX.4.64.1001161657400.28745@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755461Ab0ARDbc@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1001161657400.28745@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 16 Jan 2010 16:57:56 +0100 (CET)

> The variable qdev is initialized twice to the same (side effect-free)
> expression.  Drop one initialization.
> 
> A simplified version of the semantic match that finds this problem is:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @forall@
> idexpression *x;
> identifier f!=ERR_PTR;
> @@
> 
> x = f(...)
> ... when != x
> (
> x = f(...,<+...x...+>,...)
> |
> * x = f(...)
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Something in your patch creation process is corrupting these
patches.

> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index f922294..4ef0afb 100644
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -4087,9 +4087,8 @@ static void __devexit ql3xxx_remove(struct pci_dev *pdev)
>  	struct ql3_adapter *qdev = netdev_priv(ndev);
>  
>  	unregister_netdev(ndev);
> -	qdev = netdev_priv(ndev);
>  
>  	ql_disable_interrupts(qdev);
>  
> --

That hunk header states that after the line is removed there should
be 8 lines present in the hunk, but the patch only shows 7 such
lines.

I suspect something is eating the final line of your patches.
