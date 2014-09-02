From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: avoid panic in boomerang_start_xmit when
 finding page address:
Date: Tue, 02 Sep 2014 14:08:46 -0700 (PDT)
Message-ID: <20140902.140846.27292264952407548.davem@davemloft.net>
References: <1409676715-2291-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245AbaIBVIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:08:47 -0400
In-Reply-To: <1409676715-2291-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue,  2 Sep 2014 12:51:55 -0400

> @@ -2177,10 +2177,10 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>  
>  			vp->tx_ring[entry].frag[i+1].addr =
> -					cpu_to_le32(pci_map_single(
> -						VORTEX_PCI(vp),
> -						(void *)skb_frag_address(frag),
> -						skb_frag_size(frag), PCI_DMA_TODEVICE));
> +					cpu_to_le32(skb_frag_dma_map(
> +						&VORTEX_PCI(vp)->dev,
> +						frag,
> +						frag->page_offset, frag->size, PCI_DMA_TODEVICE));

You need to adjust the final argument to be "DMA_TO_DEVICE".
