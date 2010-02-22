From: gfilip@ee.ethz.ch
Subject: [PATCH 1/5] temac: Add Virtex4 address mappings
Date: Mon, 22 Feb 2010 20:06:57 +0100
Message-ID: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
Cc: glikely@secretlab.ca, Filip Gospodinov <gfilip@ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:56348 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753349Ab0BVTOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:14:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch belongs to a set of patches which extends the temac driver to support Virtex4-FX. It was successfully tested on the ML403 evaluation board.

Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
---
 drivers/net/ll_temac.h |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
index 1af66a1..95dd650 100644
--- a/drivers/net/ll_temac.h
+++ b/drivers/net/ll_temac.h
@@ -56,7 +56,52 @@ This option defaults to enabled (set) */
 	 XTE_OPTION_RXEN)
 
 /* XPS_LL_TEMAC SDMA registers definition */
+#ifdef CONFIG_XILINX_VIRTEX_4_FX
+#define TX_NXTDESC_PTR      0x00            /* r */
+#define TX_CURBUF_ADDR      0x04            /* r */
+#define TX_CURBUF_LENGTH    0x08            /* r */
+#define TX_CURDESC_PTR      0x0C            /* rw */
+#define TX_TAILDESC_PTR     0x10            /* rw */
+#define TX_CHNL_CTRL        0x14            /* rw */
+#define CHNL_CTRL_IRQ_IOE       (1 << 9)
+#define CHNL_CTRL_IRQ_EN        (1 << 7)
+#define CHNL_CTRL_IRQ_ERR_EN    (1 << 2)
+#define CHNL_CTRL_IRQ_DLY_EN    (1 << 1)
+#define CHNL_CTRL_IRQ_COAL_EN   (1 << 0)
+#define TX_IRQ_REG          0x18            /* rw */
+#define TX_CHNL_STS         0x1C            /* r */
+#define RX_NXTDESC_PTR      0x20            /* r */
+#define RX_CURBUF_ADDR      0x24            /* r */
+#define RX_CURBUF_LENGTH    0x28            /* r */
+#define RX_CURDESC_PTR      0x2C            /* rw */
+#define RX_TAILDESC_PTR     0x30            /* rw */
+#define RX_CHNL_CTRL        0x34            /* rw */
+#define RX_IRQ_REG          0x38           /* rw */
+#define IRQ_COAL        (1 << 0)
+#define IRQ_DLY         (1 << 1)
+#define IRQ_ERR         (1 << 2)
+#define IRQ_DMAERR      (1 << 7)            /* this is not documented ??? */
+#define RX_CHNL_STS         0x3C        /* r */
+#define CHNL_STS_ENGBUSY    (1 << 1)
+#define CHNL_STS_EOP        (1 << 2)
+#define CHNL_STS_SOP        (1 << 3)
+#define CHNL_STS_CMPLT      (1 << 4)
+#define CHNL_STS_SOE        (1 << 5)
+#define CHNL_STS_IOE        (1 << 6)
+#define CHNL_STS_ERR        (1 << 7)
+
+#define CHNL_STS_BSYWR      (1 << 16)
+#define CHNL_STS_CURPERR    (1 << 17)
+#define CHNL_STS_NXTPERR    (1 << 18)
+#define CHNL_STS_ADDRERR    (1 << 19)
+#define CHNL_STS_CMPERR     (1 << 20)
+#define CHNL_STS_TAILERR    (1 << 21)
+
+#define DMA_CONTROL_REG             0x40            /* rw */
+#define DMA_CONTROL_RST                 (1 << 0)
+#define DMA_TAIL_ENABLE                 (1 << 2)
 
+#else
 #define TX_NXTDESC_PTR      0x00            /* r */
 #define TX_CURBUF_ADDR      0x01            /* r */
 #define TX_CURBUF_LENGTH    0x02            /* r */
@@ -182,6 +227,7 @@ This option defaults to enabled (set) */
 #define DMA_CONTROL_REG             0x10            /* rw */
 #define DMA_CONTROL_RST                 (1 << 0)
 #define DMA_TAIL_ENABLE                 (1 << 2)
+#endif /*CONFIG_XILINX_VIRTEX_4_FX*/
 
 /* XPS_LL_TEMAC direct registers definition */
 
-- 
1.6.4.4

