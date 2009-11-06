From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] move dma_head/dma_maps out of skb_shared_info and into
 sk_buff
Date: Thu, 05 Nov 2009 17:40:24 -0800 (PST)
Message-ID: <20091105.174024.105269738.davem@davemloft.net>
References: <4AF373C9.7040700@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753622AbZKFBj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 20:39:58 -0500
In-Reply-To: <4AF373C9.7040700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 05 Nov 2009 16:54:33 -0800

> During testing we found issues with the use of skb_dma_map/unmap on
> systems that had iommu enabled and were configured to use a bridge.
> The
> issue is that if two ports are members of the same bridge, and a
> broadcast packet is sent out on the bridge skb_clone will be used to
> send a copy to all ports, but the clones run into issues because the
> dma mappings for the cloned skbs all share the shared_info structure
> where the dma mappings are stored.
> 
> To resolve that this patch moves those dma mappings out of the
> shared_info structure and into the sk_buff itself.  This allows cloned
> skbs to be mapped separately without causing dma unmapping errors.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

DMA mappings are a property of the data not the SKB.

And the DMA mappings are in the shared area exactly so that
we don't eat the space for every clone of the data.

We need another way around this problem and I'll just as
soon remove the DMA mapping bits entirely from SKBs before
I'll put them into struct sk_buff
