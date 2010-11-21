From: Joe Perches <joe@perches.com>
Subject: [PATCH 42/62] tg3: Use static const
Date: Sat, 20 Nov 2010 18:38:43 -0800
Message-ID: <c0ef5b45823fa90cdf1ca498a5a8c830f9cc6b68.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
 168118	    970	  41008	 210096	  334b0	drivers/net/tg3.o.old
 168286	    802	  41008	 210096	  334b0	drivers/net/tg3.o.new

Use DEFINE_PCI_DEVICE_TABLE not direct declarations.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tg3.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30ccbb6..93483a7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13047,17 +13047,15 @@ static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 		return 512;
 }
 
+DEFINE_PCI_DEVICE_TABLE(write_reorder_chipsets) = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_FE_GATE_700C) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_8131_BRIDGE) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_8385_0) },
+	{ },
+};
+
 static int __devinit tg3_get_invariants(struct tg3 *tp)
 {
-	static struct pci_device_id write_reorder_chipsets[] = {
-		{ PCI_DEVICE(PCI_VENDOR_ID_AMD,
-			     PCI_DEVICE_ID_AMD_FE_GATE_700C) },
-		{ PCI_DEVICE(PCI_VENDOR_ID_AMD,
-			     PCI_DEVICE_ID_AMD_8131_BRIDGE) },
-		{ PCI_DEVICE(PCI_VENDOR_ID_VIA,
-			     PCI_DEVICE_ID_VIA_8385_0) },
-		{ },
-	};
 	u32 misc_ctrl_reg;
 	u32 pci_state_reg, grc_misc_cfg;
 	u32 val;
@@ -14153,6 +14151,11 @@ static int __devinit tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dm
 
 #define TEST_BUFFER_SIZE	0x2000
 
+DEFINE_PCI_DEVICE_TABLE(dma_wait_state_chipsets) = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_PCI15) },
+	{ },
+};
+
 static int __devinit tg3_test_dma(struct tg3 *tp)
 {
 	dma_addr_t buf_dma;
@@ -14321,11 +14324,6 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 	}
 	if ((tp->dma_rwctrl & DMA_RWCTRL_WRITE_BNDRY_MASK) !=
 	    DMA_RWCTRL_WRITE_BNDRY_16) {
-		static struct pci_device_id dma_wait_state_chipsets[] = {
-			{ PCI_DEVICE(PCI_VENDOR_ID_APPLE,
-				     PCI_DEVICE_ID_APPLE_UNI_N_PCI15) },
-			{ },
-		};
 
 		/* DMA test passed without adjusting DMA boundary,
 		 * now look for chipsets that are known to expose the
-- 
1.7.3.2.245.g03276.dirty
