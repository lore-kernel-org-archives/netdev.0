From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: fix dma map leak when the last chunk is not
 allocated
Date: Mon, 13 May 2013 12:55:10 -0700 (PDT)
Message-ID: <20130513.125510.225110585775124505.davem@davemloft.net>
References: <1368299737-23863-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3EMTzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 15:55:13 -0400
In-Reply-To: <1368299737-23863-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Sat, 11 May 2013 16:15:37 -0300

> qlge allocates chunks from a page that it maps and unmaps that page when
> the last chunk is released. When the driver is unloaded or the card is
> removed, all chunks are released and the page is unmapped for the last
> chunk.
> 
> However, when the last chunk of a page is not allocated and the device
> is removed, that page is not unmapped. In fact, its last reference is
> not put and there's also a page leak. This bug prevents a device from
> being properly hotplugged.
> 
> When the DMA API debug option is enabled, the following messages show
> the pending DMA allocation after we remove the driver.
> 
> This patch fixes the bug by unmapping and putting the page from the ring
> if its last chunk has not been allocated.
....
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied, thanks.
