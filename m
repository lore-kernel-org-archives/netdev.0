From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] mlx4_en: Saving mem access on data path
Date: Thu, 23 Feb 2012 14:47:49 -0500 (EST)
Message-ID: <20120223.144749.1718133820851859801.davem@davemloft.net>
References: <4F464074.9050901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942Ab2BWTrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 14:47:55 -0500
In-Reply-To: <4F464074.9050901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 23 Feb 2012 15:34:44 +0200

> 
> Localized the pdev->dev, and using dma_map instead of pci_map
> There are multiple map/unmap operations on data path,
> optimizing those by saving redundant pointer access.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

I doubt you can measure any improvement from this at all, all of the
real cost is going to be in programming the hardware (both the
networking chip and potentially any IOMMU hardware to setup the DMA
mappings).  A pointer deref in of your datastructures will be
unnoticable.

When you make changes like this I want you to justify them with real
data and facts.

I think this entire patch set was in very poor taste and judgment.
