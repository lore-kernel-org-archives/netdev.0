From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 12969] New: WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tainted)
Date: Mon, 6 Apr 2009 21:52:27 +0200
Message-ID: <200904062152.28233.mb@bu3sch.de>
References: <bug-12969-10286@http.bugzilla.kernel.org/> <20090402114402.a89b956d.akpm@linux-foundation.org> <66E4AD309580E34AA457975F33D2A7473FBC6A3626@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Gary Zambrano" <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:38292 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbZDFTy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 15:54:57 -0400
In-Reply-To: <66E4AD309580E34AA457975F33D2A7473FBC6A3626@IRVEXCHCCR01.corp.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH] b44: Use kernel DMA addresses for the kernel DMA API

We must not use the device DMA addresses for the kernel DMA API, because
device DMA addresses have an additional offset added for the SSB translation.

Use the original dma_addr_t for the sync operation.

Cc: stable@kernel.org
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

I could reproduce the bug on my b44 card and this patch fixes it.
Please apply the patch and close the bug. Thanks.


Index: linux-2.6/drivers/net/b44.c
===================================================================
--- linux-2.6.orig/drivers/net/b44.c	2009-04-06 21:47:55.000000000 +0200
+++ linux-2.6/drivers/net/b44.c	2009-04-06 21:50:18.000000000 +0200
@@ -750,7 +750,7 @@
 					     dest_idx * sizeof(*dest_desc),
 					     DMA_BIDIRECTIONAL);
 
-	ssb_dma_sync_single_for_device(bp->sdev, le32_to_cpu(src_desc->addr),
+	ssb_dma_sync_single_for_device(bp->sdev, dest_map->mapping,
 				       RX_PKT_BUF_SZ,
 				       DMA_FROM_DEVICE);
 }


-- 
Greetings, Michael.
