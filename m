From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 28/29] dmaengine: kill tx_list
Date: Thu, 03 Sep 2009 19:32:52 -0700
Message-ID: <20090904023252.32667.51136.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6001 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932833AbZIDCcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:32:50 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx_list attribute of struct dma_async_tx_descriptor is common to
most, but not all dma driver implementations.  None of the upper level
code (dmaengine/async_tx) uses it, so allow drivers to implement it
locally if they need it.  This saves sizeof(struct list_head) bytes for
drivers that do not manage descriptors with a linked list (e.g.: ioatdma
v2,3).

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/dmaengine.c   |    1 -
 include/linux/dmaengine.h |    3 ---
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 5a87384..562d182 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -933,7 +933,6 @@ void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
 {
 	tx->chan = chan;
 	spin_lock_init(&tx->lock);
-	INIT_LIST_HEAD(&tx->tx_list);
 }
 EXPORT_SYMBOL(dma_async_tx_descriptor_init);
 
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index ffefba8..f114bc7 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -180,8 +180,6 @@ typedef void (*dma_async_tx_callback)(void *dma_async_param);
  * @flags: flags to augment operation preparation, control completion, and
  * 	communicate status
  * @phys: physical address of the descriptor
- * @tx_list: driver common field for operations that require multiple
- *	descriptors
  * @chan: target channel for this operation
  * @tx_submit: set the prepared descriptor(s) to be executed by the engine
  * @callback: routine to call after this operation is complete
@@ -195,7 +193,6 @@ struct dma_async_tx_descriptor {
 	dma_cookie_t cookie;
 	enum dma_ctrl_flags flags; /* not a 'long' to pack with cookie */
 	dma_addr_t phys;
-	struct list_head tx_list;
 	struct dma_chan *chan;
 	dma_cookie_t (*tx_submit)(struct dma_async_tx_descriptor *tx);
 	dma_async_tx_callback callback;

