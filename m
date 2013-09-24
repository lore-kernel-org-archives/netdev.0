From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: fix invalid value passed to pci_unmap_sigle
Date: Tue, 24 Sep 2013 10:18:28 -0400 (EDT)
Message-ID: <20130924.101828.2183168168532626954.davem@davemloft.net>
References: <alpine.LRH.2.02.1309201352010.1763@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	i.gnatenko.brain@gmail.com, stephen@networkplumber.org
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3IXOSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 10:18:30 -0400
In-Reply-To: <alpine.LRH.2.02.1309201352010.1763@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 20 Sep 2013 13:53:22 -0400 (EDT)

> In my patch c194992cbe71c20bb3623a566af8d11b0bfaa721 I didn't fix the skge

Always refer to commits, not just by SHA ID, but also with the commit
header line text in parenthesis and double quotes, for this you'd say:

c194992cbe71c20bb3623a566af8d11b0bfaa721 ("skge: fix broken driver")

Using just the SHA ID is completely ambiguous, because the SHA ID will
be entirely different if this commit is added to a different tree, such
as -stable.

> bug correctly. The value of the new mapping (not old) was passed to
> pci_unmap_single.
> 
> If we enable CONFIG_DMA_API_DEBUG, it results in this warning:
> WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:986 check_sync+0x4c4/0x580()
> skge 0000:02:07.0: DMA-API: device driver tries to sync DMA memory it has
> not allocated [device address=0x000000023a0096c0] [size=1536 bytes]
> 
> This patch makes the skge driver pass the correct value to
> pci_unmap_single and fixes the warning. It copies the old descriptor to
> on-stack variable "ee" and unmaps it if mapping of the new descriptor
> succeeded.
> 
> This patch should be backported to 3.11-stable.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>

Applied and queued up for -stable, thanks.
