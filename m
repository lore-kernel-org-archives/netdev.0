From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: stop vif thread spinning if
 frontend is unresponsive
Date: Tue, 07 Jan 2014 16:29:56 -0500 (EST)
Message-ID: <20140107.162956.1062166230525232035.davem@davemloft.net>
References: <1389111929-37231-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaAGV36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:29:58 -0500
In-Reply-To: <1389111929-37231-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 7 Jan 2014 16:25:29 +0000

> @@ -477,6 +477,7 @@ static void xenvif_rx_action(struct xenvif *vif)
>  	unsigned long offset;
>  	struct skb_cb_overlay *sco;
>  	int need_to_notify = 0;
> +	int ring_full = 0;

Please use bool, false, and true.

>  
> -	if (!npo.copy_prod)
> +	if (!npo.copy_prod) {
> +		if (ring_full)
> +			vif->rx_queue_stopped = true;
>  		goto done;
> +	}
> +
> +	vif->rx_queue_stopped = false;

And then you can code this as:

	vif->rx_queue_stopped = (!npo.copy_prod && ring_full);
	if (!npo.copy_prod)
		goto done;
