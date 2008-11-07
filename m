From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 3/4] I/OAT: fix async_tx.callback checking
Date: Fri, 07 Nov 2008 12:46:55 +0100
Message-ID: <20081107114642.25190.49701.stgit@linux.site>
References: <20081107114325.25190.5419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tom.s.picard@intel.com, mark_rustad@Xiotech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62965 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221AbYKGL6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 06:58:20 -0500
In-Reply-To: <20081107114325.25190.5419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Sosnowski <maciej.sosnowski@intel.com>

async_tx.callback should be checked for the first
not the last descriptor in the chain.

Cc: <stable@kernel.org>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dma/ioat_dma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index 687eef7..c5af17a 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -525,7 +525,7 @@ static dma_cookie_t ioat1_tx_submit(stru
 	}
 
 	hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	if (new->async_tx.callback) {
+	if (first->async_tx.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
 		if (first != new) {
 			/* move callback into to last desc */
@@ -617,7 +617,7 @@ static dma_cookie_t ioat2_tx_submit(stru
 	}
 
 	hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	if (new->async_tx.callback) {
+	if (first->async_tx.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
 		if (first != new) {
 			/* move callback into to last desc */

