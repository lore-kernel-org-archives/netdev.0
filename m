From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 09/11] pxa168_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 20:15:46 +0200
Message-ID: <20110619181546.GB3594@riccoc20.at.omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
 <bda59e6bdd024ed1c3249b1708900d0fa0baa994.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51140 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab1FSSPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 14:15:45 -0400
Received: by fxm17 with SMTP id 17so550628fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 11:15:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bda59e6bdd024ed1c3249b1708900d0fa0baa994.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 01:20:05PM +0200, Richard Cochran wrote:
> This patch enables software (and phy device) transmit time stamping
> Compile tested only.
> 
> Cc: Sachin Sanap <ssanap@marvell.com>
> Cc: Zhangfei Gao <zgao6@marvell.com>
> Cc: Philip Rakity <prakity@marvell.com>
> Cc: Mark Brown <markb@marvell.com>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/pxa168_eth.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
> index 89f7540..cd2e471 100644
> --- a/drivers/net/pxa168_eth.c
> +++ b/drivers/net/pxa168_eth.c
> @@ -1273,6 +1273,7 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	wmb();
>  	wrl(pep, SDMA_CMD, SDMA_CMD_TXDH | SDMA_CMD_ERD);
>  
> +	skb_tx_timestamp(skb);
>  	stats->tx_bytes += skb->len;

And the line above is unsafe, too.

>  	stats->tx_packets++;
>  	dev->trans_start = jiffies;
> -- 
> 1.7.0.4
> 
