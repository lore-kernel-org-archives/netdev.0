From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: use pci_dma_mapping_error to test return value
Date: Fri, 08 Jan 2010 00:55:28 -0800 (PST)
Message-ID: <20100108.005528.263100819.davem@davemloft.net>
References: <20100105211659.GA12882@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751488Ab0AHIzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:55:20 -0500
In-Reply-To: <20100105211659.GA12882@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Wed, 6 Jan 2010 00:16:59 +0300

> @@ -821,7 +821,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int frg_cnt, first_frg_len;
>  	skb_frag_t *frag;
>  	int i = 0, j = 0, avail;
> -	u64 dma_pointer;
> +	dma_addr_t dma_pointer;
>  	struct vxge_tx_priv *txdl_priv = NULL;
>  	struct __vxge_hw_fifo *fifo_hw;
>  	int offload_type;

This will cause build warnings on platforms withe dma_addr_t
is some type other than "unsigned long long", such as on
sparc64 where it is a u32.

This is because of the %ll printf format used to display it
a few lines down from here.
