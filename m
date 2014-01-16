From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 8/9] xen-netback: Timeout packets in RX path
Date: Thu, 16 Jan 2014 00:03:34 +0000
Message-ID: <20140116000334.GE5331@zion.uk.xensource.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
 <1389731995-9887-9-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63303 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbaAPADf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:03:35 -0500
Content-Disposition: inline
In-Reply-To: <1389731995-9887-9-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 08:39:54PM +0000, Zoltan Kiss wrote:
[...]
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 109c29f..d1cd8ce 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -129,6 +129,9 @@ struct xenvif {
>  	struct xen_netif_rx_back_ring rx;
>  	struct sk_buff_head rx_queue;
>  	RING_IDX rx_last_skb_slots;

Hmm... You seemed to mix your other patch with this series. :-)

> +	bool rx_queue_purge;
> +
> +	struct timer_list wake_queue;
>  
>  	/* This array is allocated seperately as it is large */
>  	struct gnttab_copy *grant_copy_op;
> @@ -225,4 +228,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
>  
>  extern bool separate_tx_rx_irq;
>  
[...]
> @@ -559,7 +579,7 @@ void xenvif_free(struct xenvif *vif)
>  		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>  			unmap_timeout++;
>  			schedule_timeout(msecs_to_jiffies(1000));
> -			if (unmap_timeout > 9 &&
> +			if (unmap_timeout > ((rx_drain_timeout_msecs/1000) * DIV_ROUND_UP(XENVIF_QUEUE_LENGTH, (XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS))) &&

This line is really too long. And what's the rationale behind this long
expression?

Wei.
