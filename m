From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/7] tg3: cleanup pci device table vars
Date: Wed, 9 Mar 2011 18:58:22 -0800
Message-ID: <1299725905-8498-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2009 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 895950c2a6565d9eefda4a38b00fa28537e39fcb, entitled
"tg3: Use DEFINE_PCI_DEVICE_TABLE" moved two pci device tables into the
global address space, but didn't declare them static and didn't prefix
them with "tg3_".  This patch fixes those problems.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ffb0979..73eacbd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13115,7 +13115,7 @@ static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 		return 512;
 }
 
-DEFINE_PCI_DEVICE_TABLE(write_reorder_chipsets) = {
+static DEFINE_PCI_DEVICE_TABLE(tg3_write_reorder_chipsets) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_FE_GATE_700C) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_8131_BRIDGE) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_8385_0) },
@@ -13469,7 +13469,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 * every mailbox register write to force the writes to be
 	 * posted to the chip in order.
 	 */
-	if (pci_dev_present(write_reorder_chipsets) &&
+	if (pci_dev_present(tg3_write_reorder_chipsets) &&
 	    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
 		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
 
@@ -14225,7 +14225,7 @@ static int __devinit tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dm
 
 #define TEST_BUFFER_SIZE	0x2000
 
-DEFINE_PCI_DEVICE_TABLE(dma_wait_state_chipsets) = {
+static DEFINE_PCI_DEVICE_TABLE(tg3_dma_wait_state_chipsets) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_PCI15) },
 	{ },
 };
@@ -14404,7 +14404,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 		 * now look for chipsets that are known to expose the
 		 * DMA bug without failing the test.
 		 */
-		if (pci_dev_present(dma_wait_state_chipsets)) {
+		if (pci_dev_present(tg3_dma_wait_state_chipsets)) {
 			tp->dma_rwctrl &= ~DMA_RWCTRL_WRITE_BNDRY_MASK;
 			tp->dma_rwctrl |= DMA_RWCTRL_WRITE_BNDRY_16;
 		} else {
-- 
1.7.3.4


