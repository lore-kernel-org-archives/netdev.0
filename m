From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 1/9] ioatdma: Push pending transactions to hardware more frequently
Date: Fri, 02 Mar 2007 18:24:17 -0800
Message-ID: <20070303022417.31033.72244.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1463 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992909AbXCCCjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:39:12 -0500
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every 20 descriptors turns out to be to few append commands with
newer/faster CPUs.  Pushing every 4 still cuts down on MMIO writes to an
acceptable level without letting the DMA engine run out of work.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 drivers/dma/ioatdma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 8e87261..0f77a9d 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -310,7 +310,7 @@ static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan,
 	list_splice_init(&new_chain, ioat_chan->used_desc.prev);
 
 	ioat_chan->pending += desc_count;
-	if (ioat_chan->pending >= 20) {
+	if (ioat_chan->pending >= 4) {
 		append = 1;
 		ioat_chan->pending = 0;
 	}
@@ -818,7 +818,7 @@ static void __devexit ioat_remove(struct pci_dev *pdev)
 }
 
 /* MODULE API */
-MODULE_VERSION("1.7");
+MODULE_VERSION("1.9");
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Intel Corporation");
 

