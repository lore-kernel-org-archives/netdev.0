From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 07/13] xen-netback: add persistent tree counters to
 debugfs
Date: Tue, 19 May 2015 16:36:04 +0100
Message-ID: <20150519153604.GF26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-8-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38221 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbbESPgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 11:36:14 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-8-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:31PM +0200, Joao Martins wrote:
> Prints the total/max number of persistent grants and how many of
> them are in use.
> 
> Signed-off-by: Joao Martins <joao.martins@neclab.eu>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/xenbus.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 766f7e5..1e6f27a 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -121,6 +121,17 @@ static int xenvif_read_io_ring(struct seq_file *m, void *v)
>  		   skb_queue_len(&queue->rx_queue),
>  		   netif_tx_queue_stopped(dev_queue) ? "stopped" : "running");
>  
> +	if (queue->vif->persistent_grants) {
> +		seq_printf(m, "\nRx persistent_gnts: in_use %d max %d gnts %d\n",
> +			   atomic_read(&queue->rx_gnts_tree.gnt_in_use),
> +			   queue->rx_gnts_tree.gnt_max,
> +			   queue->rx_gnts_tree.gnt_c);
> +		seq_printf(m, "\nTx persistent_gnts: in_use %d max %d gnts %d\n",
> +			   atomic_read(&queue->tx_gnts_tree.gnt_in_use),
> +			   queue->tx_gnts_tree.gnt_max,
> +			   queue->tx_gnts_tree.gnt_c);
> +	}
> +
>  	return 0;
>  }
>  
> -- 
> 2.1.3
