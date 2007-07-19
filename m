From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [5/8]
Date: Thu, 19 Jul 2007 07:13:38 -0700
Message-ID: <20070719141338.GD12892@xyzzy.farnsworth.org>
References: <469EEE95.8050500@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:2288 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965402AbXGSONk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:13:40 -0400
Content-Disposition: inline
In-Reply-To: <469EEE95.8050500@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:54:45AM +0000, Steven J. Hill wrote:
> Fix 'mv643xx_eth_tx_timeout_task' function prototype.
> 
> Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
> ---
> 
> --- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 21:45:13.000000000 -0500
> +++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 21:44:07.000000000 -0500
> @@ -317,11 +315,9 @@
>   *
>   * Actual routine to reset the adapter when a timeout on Tx has occurred
>   */
> -static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
> +static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
>  {
> -	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
> -						  tx_timeout_task);
> -	struct net_device *dev = mp->mii.dev; /* yuck */
> +	struct mv643xx_private *mp = netdev_priv(dev);
>  
>  	if (!netif_running(dev))
>  		return;

Applying this patch results yields a new compiler warning:
drivers/net/mv643xx_eth.c: In function `mv643xx_eth_probe':
drivers/net/mv643xx_eth.c:1375: warning: assignment from incompatible pointer type

I think we're stuck with the "struct work_struct" argument.

-Dale
