From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [PATCH] mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
Date: Tue, 23 Jan 2007 18:02:59 +0100
Message-ID: <7d01f9f00701230902x5876bba3y4d70b083151e16ad@mail.gmail.com>
References: <20070123165225.GA20153@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Jarek Poplawski" <jarkao2@o2.pl>, mlachwani@mvista.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:20330 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933089AbXAWRDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 12:03:12 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1272690uga
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 09:03:11 -0800 (PST)
To: "Dale Farnsworth" <dale@farnsworth.org>
In-Reply-To: <20070123165225.GA20153@xyzzy.farnsworth.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> From Dale Farnsworth <dale@farnsworth.org>
>
> mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
>
> This bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
> and Jarek Poplawski <jarkao2@o2.pl>.  This patch is a modification of their
> fixes.  We acquire and release the lock for each descriptor that is freed
> to minimize the time the lock is held.
>
> ---
>
>  drivers/net/mv643xx_eth.c |   11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index c41ae42..b3bf864 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -332,13 +339,13 @@ int mv643xx_eth_free_tx_descs(struct net
>                 if (skb)
>                         mp->tx_skb[tx_index] = NULL;
>
> -               spin_unlock_irqrestore(&mp->lock, flags);
> -
>                 if (cmd_sts & ETH_ERROR_SUMMARY) {
>                         printk("%s: Error in TX\n", dev->name);
>                         mp->stats.tx_errors++;
>                 }

Note that this printk probably won't show immediately because IRQs are
disabled. But that's maybe not a big deal.

HTH

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
