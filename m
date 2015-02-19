From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 19 Feb 2015 14:36:10 -0500 (EST)
Message-ID: <20150219.143610.1038570471548445608.davem@davemloft.net>
References: <BY2PR07MB4869D030A180D0147F3580AFE380@BY2PR07MB486.namprd07.prod.outlook.com>
	<1423704042-4026-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbbBSTgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 14:36:13 -0500
In-Reply-To: <1423704042-4026-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 11 Feb 2015 17:20:42 -0800

> +	uint32_t val;

uint32_t, uint64_t, etc. are userspace types, and inside the kernel
one should canonically use u32, u64, etc.

Please update your entire driver wrt. this issue.

> +	pci_unmap_single(lio->oct_dev->pci_dev, finfo->dptr, skb->len,
> +			 PCI_DMA_TODEVICE);

Please use the dma_*() variants of the DMA interfaces for which you
will pass in a reference to the struct device embedded in the pci_dev.

This will allow you to later make use of various generic facilities
we will build for DMA mapping SKBs in the networking, allocating
networknig page frags, etc.

And even more importantly, the pci_*() variants are slowly being
phased out and deprecated.
