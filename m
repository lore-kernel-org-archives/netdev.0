From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 DMA failure with iommu=off
Date: Fri, 01 May 2015 21:46:06 -0400 (EDT)
Message-ID: <20150501.214606.1559227616669665075.davem@davemloft.net>
References: <20150429165813.5d64daf0@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbEBBqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:46:10 -0400
In-Reply-To: <20150429165813.5d64daf0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Wed, 29 Apr 2015 16:58:13 -0700

> In either case since this is a receive DMA buffer, it should set
> the appropriate GFP_DMA since that may matter on some platforms.

Plain GFP_DMA is really only appropriate when used for ISA DMA
situations where we must have 24-bit addresses or whatever that
restriction was.

Anyways, it is dma_map_single()'s job to restrict DMA addressing if
necessary.  Otherwise, the transmit path would not work at all.
