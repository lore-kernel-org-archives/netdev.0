From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: fix dma api mismatches
Date: Thu, 18 Jun 2009 00:46:42 -0700 (PDT)
Message-ID: <20090618.004642.31377117.davem@davemloft.net>
References: <4A39EA27.3020404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755734AbZFRHqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:46:39 -0400
In-Reply-To: <4A39EA27.3020404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Jun 2009 09:17:59 +0200

> Please find following patch, candidate for stable, but alas not tested
> since I dont have the hardware. I hit this on a 2.6.30 kernel on a machine
> I dont have access anymore.
> 
> Thank you
> 
> [PATCH] forcedeth: fix dma api mismatches
> 
> forcedeth doesnt use properly dma api in its tx completion path
> and in nv_loopback_test()
> 
> pci_map_single() should be paired with pci_unmap_single()
> pci_map_page() should be paired with pci_unmap_page()
> 
> forcedeth xmit path uses pci_map_single() & pci_map_page(),
> but tx completion path only uses pci_unmap_single()
> 
> nv_loopback_test() uses pci_map_single() & pci_unmap_page()
> 
> Add a dma_single field in struct nv_skb_map, and
> define a helper function nv_unmap_txskb
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ayaz Abdulla <aabdulla@nvidia.com>

I'm going to apply this to net-next-2.6 now since it looks
painfully correct to me.
