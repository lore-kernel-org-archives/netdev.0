From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: mask LAST_FRAG bit from length field in ring
Date: Mon, 29 Feb 2016 17:04:00 -0500 (EST)
Message-ID: <20160229.170400.1569899372406597708.davem@davemloft.net>
References: <1456423370-22797-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbcB2WEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:04:01 -0500
In-Reply-To: <1456423370-22797-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 25 Feb 2016 13:02:50 -0500

> Recently, I fixed a bug in 3c59x:
> 
> commit 6e144419e4da11a9a4977c8d899d7247d94ca338
> Author: Neil Horman <nhorman@tuxdriver.com>
> Date:   Wed Jan 13 12:43:54 2016 -0500
> 
>     3c59x: fix another page map/single unmap imbalance
> 
> Which correctly rebalanced dma mapping and unmapping types.  Unfortunately it
> introduced a new bug which causes oopses on older systems.
> 
> When mapping dma regions, the last entry for a packet in the 3c59x tx ring
> encodes a LAST_FRAG bit, which is encoded as the high order bit of the buffers
> length field.  When it is unmapped the LAST_FRAG bit is cleared prior to being
> passed to the unmap function.  Unfortunately the commit above fails to do that
> masking.  It was missed in testing because the system on which I tested it had
> an intel iommu, the driver for which ignores the size field, using only the DMA
> address as the token to identify the mapping to be released.  However, on older
> systems that rely on swiotlb (or other dma drivers that key off that length
> field), not masking off that LAST_FRAG high order bit results in parsing a huge
> size to be release, leading to all sorts of odd corruptions and the like.
> 
> Fix is easy, just mask the length with 0xFFF.  It should really be
> &(LAST_FRAG-1), but 0xFFF is the style of the file, and I'd like to make this
> fix minimal and correct before making it prettier.
> 
> Appies to the net tree cleanly.  All testing on both iommu and swiommu based
> systems produce good results
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks.
