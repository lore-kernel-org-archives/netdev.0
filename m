From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Mon, 26 Jan 2015 16:15:14 -0800 (PST)
Message-ID: <20150126.161514.478172914646189600.davem@davemloft.net>
References: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1421937182-1708-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, netdev@vger.kernel.org,
	B38611@freescale.com, fabio.estevam@freescale.com,
	David.Laight@ACULAB.COM
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691AbbA0APO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:15:14 -0500
In-Reply-To: <1421937182-1708-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Thu, 22 Jan 2015 11:33:02 -0300

> Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
> Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date:   Mon May 19 13:59:59 2014 -0300
> 
>     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
> 
> caused a nasty regression by removing the support for highmem skb
> fragments. By using page_address() to get the address of a fragment's
> page, we are assuming a lowmem page. However, such assumption is incorrect,
> as fragments can be in highmem pages, resulting in very nasty issues.
> 
> This commit fixes this by using the skb_frag_dma_map() helper,
> which takes care of mapping the skb fragment properly. Additionally,
> the type of mapping is now tracked, so it can be unmapped using
> dma_unmap_page or dma_unmap_single when appropriate.
> 
> This commit also fixes the error path in txq_init() to release the
> resources properly.
> 
> Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map the skb fragments")
> Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Applied, thanks.
