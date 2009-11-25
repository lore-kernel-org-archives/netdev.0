From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Wed, 25 Nov 2009 17:00:51 +0530
Message-ID: <20091125113050.GA19837@serverengines.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:63512 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbZKYLan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 06:30:43 -0500
Received: by pxi10 with SMTP id 10so5682028pxi.33
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 03:30:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/09 17:20 -0800, Alexander Duyck wrote:
> This patch series removes the skb_dma_map and skb_dma_unmap function calls.
> The reason for this change is because the use of skb_dma_map/unmap can lead
> to serious issues when HW IOMMU is enabled.  This is because each mapping
> of the skb with a HW IOMMU enabled results in a new set of DMA mappings.
> This in turn leads to issues when skbs are cloned for uses such as
> bridging or pktgen because each transmitting device will update the skb
> shared info structure resulting in some mappings being overwritten, and others
> being freed multiple times.

If this is the case can the members related to the dma mapping stuff
(skb_shinfo(skb)->dma_maps) be moved out of this shared info structure and
we retain this "good" abstraction provided by this skb_dma_map/unmap api?
> 
> I am looking for input specifically on the tg3, be2net, and bnx2 driver
> patches as I am not very familiar with them and I am not certain if
> additional changes are required.

>       be2net: remove use of skb_dma_map/unmap
> 
>  drivers/net/benet/be_main.c    |   37 ++++++---

We have pulled the be2net specific patch for testing and review.
We will send an update once done with it.

-Ajit
