From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix DMA API usage
Date: Sun, 28 Jun 2015 20:25:12 -0700 (PDT)
Message-ID: <20150628.202512.1928117925744597073.davem@davemloft.net>
References: <1435333800-22447-1-git-send-email-mschmidt@redhat.com>
	<1435333800-22447-2-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krisman@linux.vnet.ibm.com,
	Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbbF2DZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 23:25:13 -0400
In-Reply-To: <1435333800-22447-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 26 Jun 2015 17:50:00 +0200

> With CONFIG_DMA_API_DEBUG=y bnx2x triggers the error "DMA-API: device
> driver frees DMA memory with wrong function".
> On archs where PAGE_SIZE > SGE_PAGE_SIZE it also triggers "DMA-API:
> device driver frees DMA memory with different size".
> 
> Fix this by making the mapping and unmapping symmetric:
>  - Do not map the whole pool page at once. Instead map the
>    SGE_PAGE_SIZE-sized pieces individually, so they can be unmapped in
>    the same manner.
>  - What's mapped using dma_map_page() must be unmapped using
>    dma_unmap_page().
> 
> Tested on ppc64.
> 
> Fixes: 4cace675d687 ("bnx2x: Alloc 4k fragment for each rx ring buffer element")
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thank you.
