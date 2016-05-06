From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/mlx4: Avoid wrong virtual mappings
Date: Thu, 05 May 2016 23:22:39 -0400 (EDT)
Message-ID: <20160505.232239.927667859977554070.davem@davemloft.net>
References: <1462362615-20238-1-git-send-email-hagaya@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, okaya@codeaurora.org, timur@codeaurora.org,
	eli@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com,
	yishaih@mellanox.com, talal@mellanox.com, saeedm@mellanox.com
To: hagaya@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756186AbcEFDWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 23:22:44 -0400
In-Reply-To: <1462362615-20238-1-git-send-email-hagaya@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramovsky <hagaya@mellanox.com>
Date: Wed,  4 May 2016 14:50:15 +0300

> The dma_alloc_coherent() function returns a virtual address which can
> be used for coherent access to the underlying memory.  On some
> architectures, like arm64, undefined behavior results if this memory is
> also accessed via virtual mappings that are not coherent.  Because of
> their undefined nature, operations like virt_to_page() return garbage
> when passed virtual addresses obtained from dma_alloc_coherent().  Any
> subsequent mappings via vmap() of the garbage page values are unusable
> and result in bad things like bus errors (synchronous aborts in ARM64
> speak).
> 
> The mlx4 driver contains code that does the equivalent of:
> vmap(virt_to_page(dma_alloc_coherent)), this results in an OOPs when the
> device is opened.
> 
> Prevent Ethernet driver to run this problematic code by forcing it to
> allocate contiguous memory. As for the Infiniband driver, at first we
> are trying to allocate contiguous memory, but in case of failure roll
> back to work with fragmented memory.
> 
> Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
> Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
> Reported-by: David Daney <david.daney@cavium.com>
> Tested-by: Sinan Kaya <okaya@codeaurora.org>

Applied, thanks.
