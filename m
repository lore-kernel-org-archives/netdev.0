From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] IOAT: fix kernel-doc in source files
Date: Fri, 30 Jun 2006 17:01:11 -0700
Message-ID: <20060630170111.676d4cec.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, akpm <akpm@osdl.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:48816 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751846AbWF3X61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:58:27 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 16:58:24 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in drivers/dma/:
- use correct function & parameter names
- add descriptions where omitted

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/dma/dmaengine.c |   20 ++++++++++++--------
 drivers/dma/ioatdma.c   |    8 +++++---
 2 files changed, 17 insertions(+), 11 deletions(-)

--- linux-2617-g13.orig/drivers/dma/dmaengine.c
+++ linux-2617-g13/drivers/dma/dmaengine.c
@@ -166,8 +166,8 @@ static struct dma_chan *dma_client_chan_
 }
 
 /**
- * dma_client_chan_free - release a DMA channel
- * @chan: &dma_chan
+ * dma_chan_cleanup - release a DMA channel's resources
+ * @kref: kernel reference structure that contains the DMA channel device
  */
 void dma_chan_cleanup(struct kref *kref)
 {
@@ -199,7 +199,7 @@ static void dma_client_chan_free(struct 
  * dma_chans_rebalance - reallocate channels to clients
  *
  * When the number of DMA channel in the system changes,
- * channels need to be rebalanced among clients
+ * channels need to be rebalanced among clients.
  */
 static void dma_chans_rebalance(void)
 {
@@ -264,7 +264,7 @@ struct dma_client *dma_async_client_regi
 
 /**
  * dma_async_client_unregister - unregister a client and free the &dma_client
- * @client:
+ * @client: &dma_client to free
  *
  * Force frees any allocated DMA channels, frees the &dma_client memory
  */
@@ -306,7 +306,7 @@ void dma_async_client_chan_request(struc
 }
 
 /**
- * dma_async_device_register -
+ * dma_async_device_register - registers DMA devices found
  * @device: &dma_device
  */
 int dma_async_device_register(struct dma_device *device)
@@ -348,8 +348,8 @@ int dma_async_device_register(struct dma
 }
 
 /**
- * dma_async_device_unregister -
- * @device: &dma_device
+ * dma_async_device_cleanup - function called when all references are released
+ * @kref: kernel reference object
  */
 static void dma_async_device_cleanup(struct kref *kref)
 {
@@ -359,7 +359,11 @@ static void dma_async_device_cleanup(str
 	complete(&device->done);
 }
 
-void dma_async_device_unregister(struct dma_device* device)
+/**
+ * dma_async_device_unregister - unregisters DMA devices
+ * @device: &dma_device
+ */
+void dma_async_device_unregister(struct dma_device *device)
 {
 	struct dma_chan *chan;
 	unsigned long flags;
--- linux-2617-g13.orig/drivers/dma/ioatdma.c
+++ linux-2617-g13/drivers/dma/ioatdma.c
@@ -217,7 +217,7 @@ static void ioat_dma_free_chan_resources
 
 /**
  * do_ioat_dma_memcpy - actual function that initiates a IOAT DMA transaction
- * @chan: IOAT DMA channel handle
+ * @ioat_chan: IOAT DMA channel handle
  * @dest: DMA destination address
  * @src: DMA source address
  * @len: transaction length in bytes
@@ -383,7 +383,7 @@ static dma_cookie_t ioat_dma_memcpy_buf_
  * @dest_off: offset into that page
  * @src_pg: pointer to the page to copy from
  * @src_off: offset into that page
- * @len: transaction length in bytes. This is guaranteed to not make a copy
+ * @len: transaction length in bytes. This is guaranteed not to make a copy
  *	 across a page boundary.
  */
 
@@ -407,7 +407,7 @@ static dma_cookie_t ioat_dma_memcpy_pg_t
 }
 
 /**
- * ioat_dma_memcpy_issue_pending - push potentially unrecognoized appended descriptors to hw
+ * ioat_dma_memcpy_issue_pending - push potentially unrecognized appended descriptors to hw
  * @chan: DMA channel handle
  */
 
@@ -510,6 +510,8 @@ static void ioat_dma_memcpy_cleanup(stru
  * ioat_dma_is_complete - poll the status of a IOAT DMA transaction
  * @chan: IOAT DMA channel handle
  * @cookie: DMA transaction identifier
+ * @done: if not %NULL, updated with last completed transaction
+ * @used: if not %NULL, updated with last used transaction
  */
 
 static enum dma_status ioat_dma_is_complete(struct dma_chan *chan,


---
