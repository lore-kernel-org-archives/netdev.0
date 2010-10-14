From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/2] stmmac: make function tables const
Date: Wed, 13 Oct 2010 17:51:25 -0700
Message-ID: <20101013175125.6f6a64db@nehalam>
References: <20101013175031.41c29349@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38178 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab0JNAvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 20:51:39 -0400
In-Reply-To: <20101013175031.41c29349@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These tables only contain function pointers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/stmmac/common.h         |    6 +++---
 drivers/net/stmmac/dwmac100.h       |    2 +-
 drivers/net/stmmac/dwmac1000.h      |    2 +-
 drivers/net/stmmac/dwmac1000_core.c |    2 +-
 drivers/net/stmmac/dwmac1000_dma.c  |    2 +-
 drivers/net/stmmac/dwmac100_core.c  |    2 +-
 drivers/net/stmmac/dwmac100_dma.c   |    2 +-
 drivers/net/stmmac/enh_desc.c       |    2 +-
 drivers/net/stmmac/norm_desc.c      |    2 +-
 drivers/net/stmmac/stmmac.h         |    4 ++--
 10 files changed, 13 insertions(+), 13 deletions(-)

--- a/drivers/net/stmmac/common.h	2010-10-13 17:42:30.599219840 -0700
+++ b/drivers/net/stmmac/common.h	2010-10-13 17:43:28.068306957 -0700
@@ -235,9 +235,9 @@ struct mii_regs {
 };
 
 struct mac_device_info {
-	struct stmmac_ops	*mac;
-	struct stmmac_desc_ops	*desc;
-	struct stmmac_dma_ops	*dma;
+	const struct stmmac_ops		*mac;
+	const struct stmmac_desc_ops	*desc;
+	const struct stmmac_dma_ops	*dma;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 };
--- a/drivers/net/stmmac/dwmac1000_core.c	2010-10-13 17:42:30.615217915 -0700
+++ b/drivers/net/stmmac/dwmac1000_core.c	2010-10-13 17:43:05.115068037 -0700
@@ -212,7 +212,7 @@ static void dwmac1000_irq_status(void __
 	}
 }
 
-struct stmmac_ops dwmac1000_ops = {
+static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_coe = dwmac1000_rx_coe_supported,
 	.dump_regs = dwmac1000_dump_regs,
--- a/drivers/net/stmmac/dwmac1000_dma.c	2010-10-13 17:44:34.880269557 -0700
+++ b/drivers/net/stmmac/dwmac1000_dma.c	2010-10-13 17:45:54.670669930 -0700
@@ -138,7 +138,7 @@ static void dwmac1000_dump_dma_regs(void
 	}
 }
 
-struct stmmac_dma_ops dwmac1000_dma_ops = {
+const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
 	.dma_mode = dwmac1000_dma_operation_mode,
--- a/drivers/net/stmmac/dwmac100_core.c	2010-10-13 17:42:30.631215991 -0700
+++ b/drivers/net/stmmac/dwmac100_core.c	2010-10-13 17:42:45.377442238 -0700
@@ -168,7 +168,7 @@ static void dwmac100_pmt(void __iomem *i
 	return;
 }
 
-struct stmmac_ops dwmac100_ops = {
+static const struct stmmac_ops dwmac100_ops = {
 	.core_init = dwmac100_core_init,
 	.rx_coe = dwmac100_rx_coe_supported,
 	.dump_regs = dwmac100_dump_mac_regs,
--- a/drivers/net/stmmac/dwmac100_dma.c	2010-10-13 17:44:45.351009875 -0700
+++ b/drivers/net/stmmac/dwmac100_dma.c	2010-10-13 17:45:26.334079236 -0700
@@ -126,7 +126,7 @@ static void dwmac100_dma_diagnostic_fr(v
 	}
 }
 
-struct stmmac_dma_ops dwmac100_dma_ops = {
+const struct stmmac_dma_ops dwmac100_dma_ops = {
 	.init = dwmac100_dma_init,
 	.dump_regs = dwmac100_dump_dma_regs,
 	.dma_mode = dwmac100_dma_operation_mode,
--- a/drivers/net/stmmac/enh_desc.c	2010-10-13 17:43:40.150853494 -0700
+++ b/drivers/net/stmmac/enh_desc.c	2010-10-13 17:46:25.390973687 -0700
@@ -318,7 +318,7 @@ static int enh_desc_get_rx_frame_len(str
 	return p->des01.erx.frame_length;
 }
 
-struct stmmac_desc_ops enh_desc_ops = {
+const struct stmmac_desc_ops enh_desc_ops = {
 	.tx_status = enh_desc_get_tx_status,
 	.rx_status = enh_desc_get_rx_status,
 	.get_tx_len = enh_desc_get_tx_len,
--- a/drivers/net/stmmac/norm_desc.c	2010-10-13 17:44:05.363820440 -0700
+++ b/drivers/net/stmmac/norm_desc.c	2010-10-13 17:46:28.978542024 -0700
@@ -202,7 +202,7 @@ static int ndesc_get_rx_frame_len(struct
 	return p->des01.rx.frame_length;
 }
 
-struct stmmac_desc_ops ndesc_ops = {
+const struct stmmac_desc_ops ndesc_ops = {
 	.tx_status = ndesc_get_tx_status,
 	.rx_status = ndesc_get_rx_status,
 	.get_tx_len = ndesc_get_tx_len,
--- a/drivers/net/stmmac/dwmac100.h	2010-10-13 17:47:08.289811886 -0700
+++ b/drivers/net/stmmac/dwmac100.h	2010-10-13 17:47:14.477067381 -0700
@@ -118,4 +118,4 @@ enum ttc_control {
 #define DMA_MISSED_FRAME_OVE_M	0x00010000	/* Missed Frame Overflow */
 #define DMA_MISSED_FRAME_M_CNTR	0x0000ffff	/* Missed Frame Couinter */
 
-extern struct stmmac_dma_ops dwmac100_dma_ops;
+extern const struct stmmac_dma_ops dwmac100_dma_ops;
--- a/drivers/net/stmmac/dwmac1000.h	2010-10-13 17:46:53.607578558 -0700
+++ b/drivers/net/stmmac/dwmac1000.h	2010-10-13 17:46:59.630853799 -0700
@@ -205,4 +205,4 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
-extern struct stmmac_dma_ops dwmac1000_dma_ops;
+extern const struct stmmac_dma_ops dwmac1000_dma_ops;
--- a/drivers/net/stmmac/stmmac.h	2010-10-13 17:47:30.415149545 -0700
+++ b/drivers/net/stmmac/stmmac.h	2010-10-13 17:47:40.497936258 -0700
@@ -121,5 +121,5 @@ static inline int stmmac_claim_resource(
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
-extern struct stmmac_desc_ops enh_desc_ops;
-extern struct stmmac_desc_ops ndesc_ops;
+extern const struct stmmac_desc_ops enh_desc_ops;
+extern const struct stmmac_desc_ops ndesc_ops;
