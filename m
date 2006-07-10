From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ixgb: fix tx unit hang - properly calculate desciptor count
Date: Mon, 10 Jul 2006 08:51:43 -0700
Message-ID: <44B2778F.2030304@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010102030600030408070801"
Cc: Andrew Morton <akpm@osdl.org>, NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46652 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964906AbWGJPwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 11:52:50 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010102030600030408070801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Jeff,

Please apply to #upstream-fixes.

Cheers,

Auke

---

--------------010102030600030408070801
Content-Type: text/x-patch;
 name="ixgb_fix_tx_hang_ring_overrun.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ixgb_fix_tx_hang_ring_overrun.patch"

There were some tso bugs that only showed up with heavy load and 16kB
pages that this patch fixes by making the driver's internal use count
of descriptors match the count that it was estimating it needed using
the DESC_NEEDED macro.  This bug caused NETDEV_WATCHDOG resets aka
tx timeouts.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index b91e082..846e11b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1281,7 +1281,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 
 	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
-		size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
+		size = min(len, IXGB_MAX_DATA_PER_TXD);
 		buffer_info->length = size;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
@@ -1306,7 +1306,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
-			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
+			size = min(len, IXGB_MAX_DATA_PER_TXD);
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,

--------------010102030600030408070801--
