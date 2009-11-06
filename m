From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC] move dma_head/dma_maps out of skb_shared_info and into
 sk_buff
Date: Thu, 05 Nov 2009 19:00:52 -0800
Message-ID: <1257476452.14523.10.camel@localhost>
References: <4AF373C9.7040700@intel.com>
	 <20091105.174024.105269738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:46524 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbZKFDBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 22:01:06 -0500
Received: by pwj9 with SMTP id 9so394312pwj.21
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2009 19:01:11 -0800 (PST)
In-Reply-To: <20091105.174024.105269738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-05 at 17:40 -0800, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 05 Nov 2009 16:54:33 -0800
> 
> > During testing we found issues with the use of skb_dma_map/unmap on
> > systems that had iommu enabled and were configured to use a bridge.
> > The
> > issue is that if two ports are members of the same bridge, and a
> > broadcast packet is sent out on the bridge skb_clone will be used to
> > send a copy to all ports, but the clones run into issues because the
> > dma mappings for the cloned skbs all share the shared_info structure
> > where the dma mappings are stored.
> > 
> > To resolve that this patch moves those dma mappings out of the
> > shared_info structure and into the sk_buff itself.  This allows cloned
> > skbs to be mapped separately without causing dma unmapping errors.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> DMA mappings are a property of the data not the SKB.
> 
> And the DMA mappings are in the shared area exactly so that
> we don't eat the space for every clone of the data.
> 
> We need another way around this problem and I'll just as
> soon remove the DMA mapping bits entirely from SKBs before
> I'll put them into struct sk_buff

We may need to pull the dma mapping bits entirely then since we end up
effectively needing to store a copy of the dma mapping every time
dma_map_single/page is called w/ iommu enabled, otherwise we can only
map the data portion of the skb once without leaking dma mappings.

Would there be any complaint if I were to submit a patch that removed
skb_dma_map/unmap?

Thanks,

Alex

