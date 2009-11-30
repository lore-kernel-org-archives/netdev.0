From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Sun, 29 Nov 2009 23:40:37 -0800 (PST)
Message-ID: <20091129.234037.232627669.davem@davemloft.net>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753727AbZK3Hkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:40:31 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 24 Nov 2009 17:20:12 -0800

> This patch series removes the skb_dma_map and skb_dma_unmap function calls.
> The reason for this change is because the use of skb_dma_map/unmap can lead
> to serious issues when HW IOMMU is enabled.  This is because each mapping
> of the skb with a HW IOMMU enabled results in a new set of DMA mappings.
> This in turn leads to issues when skbs are cloned for uses such as
> bridging or pktgen because each transmitting device will update the skb
> shared info structure resulting in some mappings being overwritten, and others
> being freed multiple times.
> 
> I am looking for input specifically on the tg3, be2net, and bnx2 driver
> patches as I am not very familiar with them and I am not certain if
> additional changes are required.
> 
> I have included the changes for the Intel wired Ethernet drivers as a
> reference.

These changes look good, but at least one of them does not apply
to current net-2.6

Can you respin this against current sources?

Thanks a lot for doing this work Alexander.
