From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH] NET_DMA: remove unused dma_memcpy_to_kernel_iovec
Date: Tue, 24 Jul 2007 13:45:44 -0700
Message-ID: <20070724204544.10360.61370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, christopher.leech@intel.com,
	andy.grover@gmail.com, shannon.nelson@intel.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10306 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757270AbXGXUqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:46:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro pointed out that dma_memcpy_to_kernel_iovec() really was
unreachable and thus unused.  The code originally was there to support
in-kernel dma needs, but since it remains unused, we'll pull it out.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
---

 drivers/dma/iovlock.c |   27 ---------------------------
 1 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index d637555..e763d72 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -143,29 +143,6 @@ void dma_unpin_iovec_pages(struct dma_pinned_list *pinned_list)
 	kfree(pinned_list);
 }
 
-static dma_cookie_t dma_memcpy_to_kernel_iovec(struct dma_chan *chan, struct
-	iovec *iov, unsigned char *kdata, size_t len)
-{
-	dma_cookie_t dma_cookie = 0;
-
-	while (len > 0) {
-		if (iov->iov_len) {
-			int copy = min_t(unsigned int, iov->iov_len, len);
-			dma_cookie = dma_async_memcpy_buf_to_buf(
-					chan,
-					iov->iov_base,
-					kdata,
-					copy);
-			kdata += copy;
-			len -= copy;
-			iov->iov_len -= copy;
-			iov->iov_base += copy;
-		}
-		iov++;
-	}
-
-	return dma_cookie;
-}
 
 /*
  * We have already pinned down the pages we will be using in the iovecs.
@@ -187,10 +164,6 @@ dma_cookie_t dma_memcpy_to_iovec(struct dma_chan *chan, struct iovec *iov,
 	if (!chan)
 		return memcpy_toiovec(iov, kdata, len);
 
-	/* -> kernel copies (e.g. smbfs) */
-	if (!pinned_list)
-		return dma_memcpy_to_kernel_iovec(chan, iov, kdata, len);
-
 	iovec_idx = 0;
 	while (iovec_idx < pinned_list->nr_iovecs) {
 		struct dma_page_list *page_list;
