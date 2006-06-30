From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] IOAT: fix header file kernel-doc
Date: Fri, 30 Jun 2006 16:28:30 -0700
Message-ID: <20060630162830.f6c72a5a.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@osdl.org>,
	christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:56220 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S932289AbWF3XZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:25:45 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 16:25:43 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc problems in include/linux/dmaengine.h:
- add some fields/parameters
- expand some descriptions
- fix typos

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/linux/dmaengine.h |   43 +++++++++++++++++++++++++------------------
 1 files changed, 25 insertions(+), 18 deletions(-)

--- linux-2617-g13.orig/include/linux/dmaengine.h
+++ linux-2617-g13/include/linux/dmaengine.h
@@ -44,7 +44,7 @@ enum dma_event {
 };
 
 /**
- * typedef dma_cookie_t
+ * typedef dma_cookie_t - an opaque DMA cookie
  *
  * if dma_cookie_t is >0 it's a DMA request cookie, <0 it's an error code
  */
@@ -80,14 +80,14 @@ struct dma_chan_percpu {
 
 /**
  * struct dma_chan - devices supply DMA channels, clients use them
- * @client: ptr to the client user of this chan, will be NULL when unused
- * @device: ptr to the dma device who supplies this channel, always !NULL
+ * @client: ptr to the client user of this chan, will be %NULL when unused
+ * @device: ptr to the dma device who supplies this channel, always !%NULL
  * @cookie: last cookie value returned to client
- * @chan_id:
- * @class_dev:
+ * @chan_id: channel ID for sysfs
+ * @class_dev: class device for sysfs
  * @refcount: kref, used in "bigref" slow-mode
- * @slow_ref:
- * @rcu:
+ * @slow_ref: indicates that the DMA channel is free
+ * @rcu: the DMA channel's RCU head
  * @client_node: used to add this to the client chan list
  * @device_node: used to add this to the device chan list
  * @local: per-cpu pointer to a struct dma_chan_percpu
@@ -162,10 +162,17 @@ struct dma_client {
  * @chancnt: how many DMA channels are supported
  * @channels: the list of struct dma_chan
  * @global_node: list_head for global dma_device_list
- * @refcount:
- * @done:
- * @dev_id:
- * Other func ptrs: used to make use of this device's capabilities
+ * @refcount: reference count
+ * @done: IO completion struct
+ * @dev_id: unique device ID
+ * @device_alloc_chan_resources: allocate resources and return the
+ *	number of allocated descriptors
+ * @device_free_chan_resources: release DMA channel's resources
+ * @device_memcpy_buf_to_buf: memcpy buf pointer to buf pointer
+ * @device_memcpy_buf_to_pg: memcpy buf pointer to struct page
+ * @device_memcpy_pg_to_pg: memcpy struct page/offset to struct page/offset
+ * @device_memcpy_complete: poll the status of an IOAT DMA transaction
+ * @device_memcpy_issue_pending: push appended descriptors to hardware
  */
 struct dma_device {
 
@@ -211,7 +218,7 @@ void dma_async_client_chan_request(struc
  * Both @dest and @src must be mappable to a bus address according to the
  * DMA mapping API rules for streaming mappings.
  * Both @dest and @src must stay memory resident (kernel memory or locked
- * user space pages)
+ * user space pages).
  */
 static inline dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
 	void *dest, void *src, size_t len)
@@ -225,7 +232,7 @@ static inline dma_cookie_t dma_async_mem
 }
 
 /**
- * dma_async_memcpy_buf_to_pg - offloaded copy
+ * dma_async_memcpy_buf_to_pg - offloaded copy from address to page
  * @chan: DMA channel to offload copy to
  * @page: destination page
  * @offset: offset in page to copy to
@@ -250,18 +257,18 @@ static inline dma_cookie_t dma_async_mem
 }
 
 /**
- * dma_async_memcpy_buf_to_pg - offloaded copy
+ * dma_async_memcpy_pg_to_pg - offloaded copy from page to page
  * @chan: DMA channel to offload copy to
- * @dest_page: destination page
+ * @dest_pg: destination page
  * @dest_off: offset in page to copy to
- * @src_page: source page
+ * @src_pg: source page
  * @src_off: offset in page to copy from
  * @len: length
  *
  * Both @dest_page/@dest_off and @src_page/@src_off must be mappable to a bus
  * address according to the DMA mapping API rules for streaming mappings.
  * Both @dest_page/@dest_off and @src_page/@src_off must stay memory resident
- * (kernel memory or locked user space pages)
+ * (kernel memory or locked user space pages).
  */
 static inline dma_cookie_t dma_async_memcpy_pg_to_pg(struct dma_chan *chan,
 	struct page *dest_pg, unsigned int dest_off, struct page *src_pg,
@@ -278,7 +285,7 @@ static inline dma_cookie_t dma_async_mem
 
 /**
  * dma_async_memcpy_issue_pending - flush pending copies to HW
- * @chan:
+ * @chan: target DMA channel
  *
  * This allows drivers to push copies to HW in batches,
  * reducing MMIO writes where possible.


---
