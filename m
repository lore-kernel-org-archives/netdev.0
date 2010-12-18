From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 3/3] igb: example of how to update igb to make use
 of in-kernel Toeplitz hashing
Date: Fri, 17 Dec 2010 21:09:23 -0800 (PST)
Message-ID: <20101217.210923.193721885.davem@davemloft.net>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	<20101218010048.28602.49776.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43212
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750721Ab0LRFIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 00:08:54 -0500
In-Reply-To: <20101218010048.28602.49776.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 17 Dec 2010 17:00:48 -0800

> @@ -1691,6 +1692,7 @@ static const struct net_device_ops igb_netdev_ops = {
>  	.ndo_open		= igb_open,
>  	.ndo_stop		= igb_close,
>  	.ndo_start_xmit		= igb_xmit_frame_adv,
> +	.ndo_select_queue	= toeplitz_select_queue,
>  	.ndo_get_stats64	= igb_get_stats64,
>  	.ndo_set_rx_mode	= igb_set_rx_mode,
>  	.ndo_set_multicast_list	= igb_set_rx_mode,

Adding a NETIF_F_TX_TOEPLITZ flag that skb_tx_hash() keys off of would
be a lot simpler.

We want less overriding of ->ndo_select_queue(), not more, and this case
is definitely gratuitous.
