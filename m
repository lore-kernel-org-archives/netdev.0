From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 05/10] x86: add check code for map/unmap_single code
Date: Sat, 22 Nov 2008 12:27:41 +0900
Message-ID: <20081122120632M.fujita.tomonori@lab.ntt.co.jp>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	<1227284770-19215-6-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:40039 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbYKVD3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 22:29:44 -0500
In-Reply-To: <1227284770-19215-6-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 17:26:05 +0100
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Impact: detect bugs in map/unmap_single usage
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |    9 +++++-
>  arch/x86/include/asm/dma_debug.h   |   20 +++++++++++++
>  arch/x86/kernel/pci-dma-debug.c    |   55 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 83 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 83d7b7d..c9bead2 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -98,9 +98,14 @@ dma_map_single(struct device *hwdev, void *ptr, size_t size,
>  	       int direction)
>  {
>  	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
> +	dma_addr_t addr;
>  
>  	BUG_ON(!valid_dma_direction(direction));
> -	return ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> +	addr = ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> +
> +	debug_map_single(hwdev, ptr, size, direction, addr);

debug_map_single could fail due to OOM. Then debug_unmap_single in
dma_unmap_single gives a false warning because it can't find the
dma_debug_entry?

