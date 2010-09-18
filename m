From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Fri, 17 Sep 2010 22:58:24 -0700 (PDT)
Message-ID: <20100917.225824.193719467.davem@davemloft.net>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	<1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	<1284717448.3391.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752595Ab0IRF6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 01:58:06 -0400
In-Reply-To: <1284717448.3391.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Sep 2010 11:57:28 +0200

> [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
> 
> qlcnic driver allocates rx skbs and gives to hardware too bytes of extra
> storage, allowing for corruption of kernel data.
> 
> NET_IP_ALIGN being 0 on some platforms (including x86), drivers should
> not assume it's 2.
> 
> rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
> ...
> skb = dev_alloc_skb(rds_ring->skb_size);
> skb_reserve(skb, 2);
> pci_map_single(pdev, skb->data, rds_ring->dma_size, PCI_DMA_FROMDEVICE);
> 
> (and rds_ring->skb_size == rds_ring->dma_size) -> bug
> 
> 
> Because of extra alignment (1500 + 32) -> four extra bytes are available
> before the struct skb_shared_info, so corruption is not noticed.
> 
> Note: this driver could use netdev_alloc_skb_ip_align()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6, thanks Eric.
