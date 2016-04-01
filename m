From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 08/13] stmmac: enhance mmc counter management
Date: Fri, 1 Apr 2016 11:37:32 +0200
Message-ID: <1459503457-22569-9-git-send-email-alexandre.torgue@st.com>
References: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:53854 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754491AbcDAJiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:38:22 -0400
In-Reply-To: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For gmac3, the MMC addr map is: 0x100 - 0x2fc
For gmac4, the MMC addr map is: 0x700 - 0x8fc

So instead of adding 0x600 to the IO address when setup the mmc,
the RMON base address is saved inside the private structure and
then used to manage the counters.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 192c249..38a1a56 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -35,6 +35,10 @@
 						 * current value.*/
 #define MMC_CNTRL_PRESET		0x10
 #define MMC_CNTRL_FULL_HALF_PRESET	0x20
+
+#define MMC_GMAC4_OFFSET		0x700
+#define MMC_GMAC3_X_OFFSET		0x100
+
 struct stmmac_counters {
 	unsigned int mmc_tx_octetcount_gb;
 	unsigned int mmc_tx_framecount_gb;
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 3f20bb1..ce9aa79 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -28,12 +28,12 @@
 
 /* MAC Management Counters register offset */
 
-#define MMC_CNTRL		0x00000100	/* MMC Control */
-#define MMC_RX_INTR		0x00000104	/* MMC RX Interrupt */
-#define MMC_TX_INTR		0x00000108	/* MMC TX Interrupt */
-#define MMC_RX_INTR_MASK	0x0000010c	/* MMC Interrupt Mask */
-#define MMC_TX_INTR_MASK	0x00000110	/* MMC Interrupt Mask */
-#define MMC_DEFAULT_MASK		0xffffffff
+#define MMC_CNTRL		0x00	/* MMC Control */
+#define MMC_RX_INTR		0x04	/* MMC RX Interrupt */
+#define MMC_TX_INTR		0x08	/* MMC TX Interrupt */
+#define MMC_RX_INTR_MASK	0x0c	/* MMC Interrupt Mask */
+#define MMC_TX_INTR_MASK	0x10	/* MMC Interrupt Mask */
+#define MMC_DEFAULT_MASK	0xffffffff
 
 /* MMC TX counter registers */
 
@@ -41,115 +41,115 @@
  * _GB register stands for good and bad frames
  * _G is for good only.
  */
-#define MMC_TX_OCTETCOUNT_GB		0x00000114
-#define MMC_TX_FRAMECOUNT_GB		0x00000118
-#define MMC_TX_BROADCASTFRAME_G		0x0000011c
-#define MMC_TX_MULTICASTFRAME_G		0x00000120
-#define MMC_TX_64_OCTETS_GB		0x00000124
-#define MMC_TX_65_TO_127_OCTETS_GB	0x00000128
-#define MMC_TX_128_TO_255_OCTETS_GB	0x0000012c
-#define MMC_TX_256_TO_511_OCTETS_GB	0x00000130
-#define MMC_TX_512_TO_1023_OCTETS_GB	0x00000134
-#define MMC_TX_1024_TO_MAX_OCTETS_GB	0x00000138
-#define MMC_TX_UNICAST_GB		0x0000013c
-#define MMC_TX_MULTICAST_GB		0x00000140
-#define MMC_TX_BROADCAST_GB		0x00000144
-#define MMC_TX_UNDERFLOW_ERROR		0x00000148
-#define MMC_TX_SINGLECOL_G		0x0000014c
-#define MMC_TX_MULTICOL_G		0x00000150
-#define MMC_TX_DEFERRED			0x00000154
-#define MMC_TX_LATECOL			0x00000158
-#define MMC_TX_EXESSCOL			0x0000015c
-#define MMC_TX_CARRIER_ERROR		0x00000160
-#define MMC_TX_OCTETCOUNT_G		0x00000164
-#define MMC_TX_FRAMECOUNT_G		0x00000168
-#define MMC_TX_EXCESSDEF		0x0000016c
-#define MMC_TX_PAUSE_FRAME		0x00000170
-#define MMC_TX_VLAN_FRAME_G		0x00000174
+#define MMC_TX_OCTETCOUNT_GB		0x14
+#define MMC_TX_FRAMECOUNT_GB		0x18
+#define MMC_TX_BROADCASTFRAME_G		0x1c
+#define MMC_TX_MULTICASTFRAME_G		0x20
+#define MMC_TX_64_OCTETS_GB		0x24
+#define MMC_TX_65_TO_127_OCTETS_GB	0x28
+#define MMC_TX_128_TO_255_OCTETS_GB	0x2c
+#define MMC_TX_256_TO_511_OCTETS_GB	0x30
+#define MMC_TX_512_TO_1023_OCTETS_GB	0x34
+#define MMC_TX_1024_TO_MAX_OCTETS_GB	0x38
+#define MMC_TX_UNICAST_GB		0x3c
+#define MMC_TX_MULTICAST_GB		0x40
+#define MMC_TX_BROADCAST_GB		0x44
+#define MMC_TX_UNDERFLOW_ERROR		0x48
+#define MMC_TX_SINGLECOL_G		0x4c
+#define MMC_TX_MULTICOL_G		0x50
+#define MMC_TX_DEFERRED			0x54
+#define MMC_TX_LATECOL			0x58
+#define MMC_TX_EXESSCOL			0x5c
+#define MMC_TX_CARRIER_ERROR		0x60
+#define MMC_TX_OCTETCOUNT_G		0x64
+#define MMC_TX_FRAMECOUNT_G		0x68
+#define MMC_TX_EXCESSDEF		0x6c
+#define MMC_TX_PAUSE_FRAME		0x70
+#define MMC_TX_VLAN_FRAME_G		0x74
 
 /* MMC RX counter registers */
-#define MMC_RX_FRAMECOUNT_GB		0x00000180
-#define MMC_RX_OCTETCOUNT_GB		0x00000184
-#define MMC_RX_OCTETCOUNT_G		0x00000188
-#define MMC_RX_BROADCASTFRAME_G		0x0000018c
-#define MMC_RX_MULTICASTFRAME_G		0x00000190
-#define MMC_RX_CRC_ERROR		0x00000194
-#define MMC_RX_ALIGN_ERROR		0x00000198
-#define MMC_RX_RUN_ERROR		0x0000019C
-#define MMC_RX_JABBER_ERROR		0x000001A0
-#define MMC_RX_UNDERSIZE_G		0x000001A4
-#define MMC_RX_OVERSIZE_G		0x000001A8
-#define MMC_RX_64_OCTETS_GB		0x000001AC
-#define MMC_RX_65_TO_127_OCTETS_GB	0x000001b0
-#define MMC_RX_128_TO_255_OCTETS_GB	0x000001b4
-#define MMC_RX_256_TO_511_OCTETS_GB	0x000001b8
-#define MMC_RX_512_TO_1023_OCTETS_GB	0x000001bc
-#define MMC_RX_1024_TO_MAX_OCTETS_GB	0x000001c0
-#define MMC_RX_UNICAST_G		0x000001c4
-#define MMC_RX_LENGTH_ERROR		0x000001c8
-#define MMC_RX_AUTOFRANGETYPE		0x000001cc
-#define MMC_RX_PAUSE_FRAMES		0x000001d0
-#define MMC_RX_FIFO_OVERFLOW		0x000001d4
-#define MMC_RX_VLAN_FRAMES_GB		0x000001d8
-#define MMC_RX_WATCHDOG_ERROR		0x000001dc
+#define MMC_RX_FRAMECOUNT_GB		0x80
+#define MMC_RX_OCTETCOUNT_GB		0x84
+#define MMC_RX_OCTETCOUNT_G		0x88
+#define MMC_RX_BROADCASTFRAME_G		0x8c
+#define MMC_RX_MULTICASTFRAME_G		0x90
+#define MMC_RX_CRC_ERROR		0x94
+#define MMC_RX_ALIGN_ERROR		0x98
+#define MMC_RX_RUN_ERROR		0x9C
+#define MMC_RX_JABBER_ERROR		0xA0
+#define MMC_RX_UNDERSIZE_G		0xA4
+#define MMC_RX_OVERSIZE_G		0xA8
+#define MMC_RX_64_OCTETS_GB		0xAC
+#define MMC_RX_65_TO_127_OCTETS_GB	0xb0
+#define MMC_RX_128_TO_255_OCTETS_GB	0xb4
+#define MMC_RX_256_TO_511_OCTETS_GB	0xb8
+#define MMC_RX_512_TO_1023_OCTETS_GB	0xbc
+#define MMC_RX_1024_TO_MAX_OCTETS_GB	0xc0
+#define MMC_RX_UNICAST_G		0xc4
+#define MMC_RX_LENGTH_ERROR		0xc8
+#define MMC_RX_AUTOFRANGETYPE		0xcc
+#define MMC_RX_PAUSE_FRAMES		0xd0
+#define MMC_RX_FIFO_OVERFLOW		0xd4
+#define MMC_RX_VLAN_FRAMES_GB		0xd8
+#define MMC_RX_WATCHDOG_ERROR		0xdc
 /* IPC*/
-#define MMC_RX_IPC_INTR_MASK		0x00000200
-#define MMC_RX_IPC_INTR			0x00000208
+#define MMC_RX_IPC_INTR_MASK		0x100
+#define MMC_RX_IPC_INTR			0x108
 /* IPv4*/
-#define MMC_RX_IPV4_GD			0x00000210
-#define MMC_RX_IPV4_HDERR		0x00000214
-#define MMC_RX_IPV4_NOPAY		0x00000218
-#define MMC_RX_IPV4_FRAG		0x0000021C
-#define MMC_RX_IPV4_UDSBL		0x00000220
+#define MMC_RX_IPV4_GD			0x110
+#define MMC_RX_IPV4_HDERR		0x114
+#define MMC_RX_IPV4_NOPAY		0x118
+#define MMC_RX_IPV4_FRAG		0x11C
+#define MMC_RX_IPV4_UDSBL		0x120
 
-#define MMC_RX_IPV4_GD_OCTETS		0x00000250
-#define MMC_RX_IPV4_HDERR_OCTETS	0x00000254
-#define MMC_RX_IPV4_NOPAY_OCTETS	0x00000258
-#define MMC_RX_IPV4_FRAG_OCTETS		0x0000025c
-#define MMC_RX_IPV4_UDSBL_OCTETS	0x00000260
+#define MMC_RX_IPV4_GD_OCTETS		0x150
+#define MMC_RX_IPV4_HDERR_OCTETS	0x154
+#define MMC_RX_IPV4_NOPAY_OCTETS	0x158
+#define MMC_RX_IPV4_FRAG_OCTETS		0x15c
+#define MMC_RX_IPV4_UDSBL_OCTETS	0x160
 
 /* IPV6*/
-#define MMC_RX_IPV6_GD_OCTETS		0x00000264
-#define MMC_RX_IPV6_HDERR_OCTETS	0x00000268
-#define MMC_RX_IPV6_NOPAY_OCTETS	0x0000026c
+#define MMC_RX_IPV6_GD_OCTETS		0x164
+#define MMC_RX_IPV6_HDERR_OCTETS	0x168
+#define MMC_RX_IPV6_NOPAY_OCTETS	0x16c
 
-#define MMC_RX_IPV6_GD			0x00000224
-#define MMC_RX_IPV6_HDERR		0x00000228
-#define MMC_RX_IPV6_NOPAY		0x0000022c
+#define MMC_RX_IPV6_GD			0x124
+#define MMC_RX_IPV6_HDERR		0x128
+#define MMC_RX_IPV6_NOPAY		0x12c
 
 /* Protocols*/
-#define MMC_RX_UDP_GD			0x00000230
-#define MMC_RX_UDP_ERR			0x00000234
-#define MMC_RX_TCP_GD			0x00000238
-#define MMC_RX_TCP_ERR			0x0000023c
-#define MMC_RX_ICMP_GD			0x00000240
-#define MMC_RX_ICMP_ERR			0x00000244
+#define MMC_RX_UDP_GD			0x130
+#define MMC_RX_UDP_ERR			0x134
+#define MMC_RX_TCP_GD			0x138
+#define MMC_RX_TCP_ERR			0x13c
+#define MMC_RX_ICMP_GD			0x140
+#define MMC_RX_ICMP_ERR			0x144
 
-#define MMC_RX_UDP_GD_OCTETS		0x00000270
-#define MMC_RX_UDP_ERR_OCTETS		0x00000274
-#define MMC_RX_TCP_GD_OCTETS		0x00000278
-#define MMC_RX_TCP_ERR_OCTETS		0x0000027c
-#define MMC_RX_ICMP_GD_OCTETS		0x00000280
-#define MMC_RX_ICMP_ERR_OCTETS		0x00000284
+#define MMC_RX_UDP_GD_OCTETS		0x170
+#define MMC_RX_UDP_ERR_OCTETS		0x174
+#define MMC_RX_TCP_GD_OCTETS		0x178
+#define MMC_RX_TCP_ERR_OCTETS		0x17c
+#define MMC_RX_ICMP_GD_OCTETS		0x180
+#define MMC_RX_ICMP_ERR_OCTETS		0x184
 
-void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode)
+void dwmac_mmc_ctrl(void __iomem *mmcaddr, unsigned int mode)
 {
-	u32 value = readl(ioaddr + MMC_CNTRL);
+	u32 value = readl(mmcaddr + MMC_CNTRL);
 
 	value |= (mode & 0x3F);
 
-	writel(value, ioaddr + MMC_CNTRL);
+	writel(value, mmcaddr + MMC_CNTRL);
 
 	pr_debug("stmmac: MMC ctrl register (offset 0x%x): 0x%08x\n",
 		 MMC_CNTRL, value);
 }
 
 /* To mask all all interrupts.*/
-void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
+void dwmac_mmc_intr_all_mask(void __iomem *mmcaddr)
 {
-	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
-	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
-	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_IPC_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, mmcaddr + MMC_RX_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, mmcaddr + MMC_TX_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, mmcaddr + MMC_RX_IPC_INTR_MASK);
 }
 
 /* This reads the MAC core counters (if actaully supported).
@@ -157,111 +157,116 @@ void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
  * counter after a read. So all the field of the mmc struct
  * have to be incremented.
  */
-void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc)
+void dwmac_mmc_read(void __iomem *mmcaddr, struct stmmac_counters *mmc)
 {
-	mmc->mmc_tx_octetcount_gb += readl(ioaddr + MMC_TX_OCTETCOUNT_GB);
-	mmc->mmc_tx_framecount_gb += readl(ioaddr + MMC_TX_FRAMECOUNT_GB);
-	mmc->mmc_tx_broadcastframe_g += readl(ioaddr + MMC_TX_BROADCASTFRAME_G);
-	mmc->mmc_tx_multicastframe_g += readl(ioaddr + MMC_TX_MULTICASTFRAME_G);
-	mmc->mmc_tx_64_octets_gb += readl(ioaddr + MMC_TX_64_OCTETS_GB);
+	mmc->mmc_tx_octetcount_gb += readl(mmcaddr + MMC_TX_OCTETCOUNT_GB);
+	mmc->mmc_tx_framecount_gb += readl(mmcaddr + MMC_TX_FRAMECOUNT_GB);
+	mmc->mmc_tx_broadcastframe_g += readl(mmcaddr +
+					      MMC_TX_BROADCASTFRAME_G);
+	mmc->mmc_tx_multicastframe_g += readl(mmcaddr +
+					      MMC_TX_MULTICASTFRAME_G);
+	mmc->mmc_tx_64_octets_gb += readl(mmcaddr + MMC_TX_64_OCTETS_GB);
 	mmc->mmc_tx_65_to_127_octets_gb +=
-	    readl(ioaddr + MMC_TX_65_TO_127_OCTETS_GB);
+	    readl(mmcaddr + MMC_TX_65_TO_127_OCTETS_GB);
 	mmc->mmc_tx_128_to_255_octets_gb +=
-	    readl(ioaddr + MMC_TX_128_TO_255_OCTETS_GB);
+	    readl(mmcaddr + MMC_TX_128_TO_255_OCTETS_GB);
 	mmc->mmc_tx_256_to_511_octets_gb +=
-	    readl(ioaddr + MMC_TX_256_TO_511_OCTETS_GB);
+	    readl(mmcaddr + MMC_TX_256_TO_511_OCTETS_GB);
 	mmc->mmc_tx_512_to_1023_octets_gb +=
-	    readl(ioaddr + MMC_TX_512_TO_1023_OCTETS_GB);
+	    readl(mmcaddr + MMC_TX_512_TO_1023_OCTETS_GB);
 	mmc->mmc_tx_1024_to_max_octets_gb +=
-	    readl(ioaddr + MMC_TX_1024_TO_MAX_OCTETS_GB);
-	mmc->mmc_tx_unicast_gb += readl(ioaddr + MMC_TX_UNICAST_GB);
-	mmc->mmc_tx_multicast_gb += readl(ioaddr + MMC_TX_MULTICAST_GB);
-	mmc->mmc_tx_broadcast_gb += readl(ioaddr + MMC_TX_BROADCAST_GB);
-	mmc->mmc_tx_underflow_error += readl(ioaddr + MMC_TX_UNDERFLOW_ERROR);
-	mmc->mmc_tx_singlecol_g += readl(ioaddr + MMC_TX_SINGLECOL_G);
-	mmc->mmc_tx_multicol_g += readl(ioaddr + MMC_TX_MULTICOL_G);
-	mmc->mmc_tx_deferred += readl(ioaddr + MMC_TX_DEFERRED);
-	mmc->mmc_tx_latecol += readl(ioaddr + MMC_TX_LATECOL);
-	mmc->mmc_tx_exesscol += readl(ioaddr + MMC_TX_EXESSCOL);
-	mmc->mmc_tx_carrier_error += readl(ioaddr + MMC_TX_CARRIER_ERROR);
-	mmc->mmc_tx_octetcount_g += readl(ioaddr + MMC_TX_OCTETCOUNT_G);
-	mmc->mmc_tx_framecount_g += readl(ioaddr + MMC_TX_FRAMECOUNT_G);
-	mmc->mmc_tx_excessdef += readl(ioaddr + MMC_TX_EXCESSDEF);
-	mmc->mmc_tx_pause_frame += readl(ioaddr + MMC_TX_PAUSE_FRAME);
-	mmc->mmc_tx_vlan_frame_g += readl(ioaddr + MMC_TX_VLAN_FRAME_G);
+	    readl(mmcaddr + MMC_TX_1024_TO_MAX_OCTETS_GB);
+	mmc->mmc_tx_unicast_gb += readl(mmcaddr + MMC_TX_UNICAST_GB);
+	mmc->mmc_tx_multicast_gb += readl(mmcaddr + MMC_TX_MULTICAST_GB);
+	mmc->mmc_tx_broadcast_gb += readl(mmcaddr + MMC_TX_BROADCAST_GB);
+	mmc->mmc_tx_underflow_error += readl(mmcaddr + MMC_TX_UNDERFLOW_ERROR);
+	mmc->mmc_tx_singlecol_g += readl(mmcaddr + MMC_TX_SINGLECOL_G);
+	mmc->mmc_tx_multicol_g += readl(mmcaddr + MMC_TX_MULTICOL_G);
+	mmc->mmc_tx_deferred += readl(mmcaddr + MMC_TX_DEFERRED);
+	mmc->mmc_tx_latecol += readl(mmcaddr + MMC_TX_LATECOL);
+	mmc->mmc_tx_exesscol += readl(mmcaddr + MMC_TX_EXESSCOL);
+	mmc->mmc_tx_carrier_error += readl(mmcaddr + MMC_TX_CARRIER_ERROR);
+	mmc->mmc_tx_octetcount_g += readl(mmcaddr + MMC_TX_OCTETCOUNT_G);
+	mmc->mmc_tx_framecount_g += readl(mmcaddr + MMC_TX_FRAMECOUNT_G);
+	mmc->mmc_tx_excessdef += readl(mmcaddr + MMC_TX_EXCESSDEF);
+	mmc->mmc_tx_pause_frame += readl(mmcaddr + MMC_TX_PAUSE_FRAME);
+	mmc->mmc_tx_vlan_frame_g += readl(mmcaddr + MMC_TX_VLAN_FRAME_G);
 
 	/* MMC RX counter registers */
-	mmc->mmc_rx_framecount_gb += readl(ioaddr + MMC_RX_FRAMECOUNT_GB);
-	mmc->mmc_rx_octetcount_gb += readl(ioaddr + MMC_RX_OCTETCOUNT_GB);
-	mmc->mmc_rx_octetcount_g += readl(ioaddr + MMC_RX_OCTETCOUNT_G);
-	mmc->mmc_rx_broadcastframe_g += readl(ioaddr + MMC_RX_BROADCASTFRAME_G);
-	mmc->mmc_rx_multicastframe_g += readl(ioaddr + MMC_RX_MULTICASTFRAME_G);
-	mmc->mmc_rx_crc_error += readl(ioaddr + MMC_RX_CRC_ERROR);
-	mmc->mmc_rx_align_error += readl(ioaddr + MMC_RX_ALIGN_ERROR);
-	mmc->mmc_rx_run_error += readl(ioaddr + MMC_RX_RUN_ERROR);
-	mmc->mmc_rx_jabber_error += readl(ioaddr + MMC_RX_JABBER_ERROR);
-	mmc->mmc_rx_undersize_g += readl(ioaddr + MMC_RX_UNDERSIZE_G);
-	mmc->mmc_rx_oversize_g += readl(ioaddr + MMC_RX_OVERSIZE_G);
-	mmc->mmc_rx_64_octets_gb += readl(ioaddr + MMC_RX_64_OCTETS_GB);
+	mmc->mmc_rx_framecount_gb += readl(mmcaddr + MMC_RX_FRAMECOUNT_GB);
+	mmc->mmc_rx_octetcount_gb += readl(mmcaddr + MMC_RX_OCTETCOUNT_GB);
+	mmc->mmc_rx_octetcount_g += readl(mmcaddr + MMC_RX_OCTETCOUNT_G);
+	mmc->mmc_rx_broadcastframe_g += readl(mmcaddr +
+					      MMC_RX_BROADCASTFRAME_G);
+	mmc->mmc_rx_multicastframe_g += readl(mmcaddr +
+					      MMC_RX_MULTICASTFRAME_G);
+	mmc->mmc_rx_crc_error += readl(mmcaddr + MMC_RX_CRC_ERROR);
+	mmc->mmc_rx_align_error += readl(mmcaddr + MMC_RX_ALIGN_ERROR);
+	mmc->mmc_rx_run_error += readl(mmcaddr + MMC_RX_RUN_ERROR);
+	mmc->mmc_rx_jabber_error += readl(mmcaddr + MMC_RX_JABBER_ERROR);
+	mmc->mmc_rx_undersize_g += readl(mmcaddr + MMC_RX_UNDERSIZE_G);
+	mmc->mmc_rx_oversize_g += readl(mmcaddr + MMC_RX_OVERSIZE_G);
+	mmc->mmc_rx_64_octets_gb += readl(mmcaddr + MMC_RX_64_OCTETS_GB);
 	mmc->mmc_rx_65_to_127_octets_gb +=
-	    readl(ioaddr + MMC_RX_65_TO_127_OCTETS_GB);
+	    readl(mmcaddr + MMC_RX_65_TO_127_OCTETS_GB);
 	mmc->mmc_rx_128_to_255_octets_gb +=
-	    readl(ioaddr + MMC_RX_128_TO_255_OCTETS_GB);
+	    readl(mmcaddr + MMC_RX_128_TO_255_OCTETS_GB);
 	mmc->mmc_rx_256_to_511_octets_gb +=
-	    readl(ioaddr + MMC_RX_256_TO_511_OCTETS_GB);
+	    readl(mmcaddr + MMC_RX_256_TO_511_OCTETS_GB);
 	mmc->mmc_rx_512_to_1023_octets_gb +=
-	    readl(ioaddr + MMC_RX_512_TO_1023_OCTETS_GB);
+	    readl(mmcaddr + MMC_RX_512_TO_1023_OCTETS_GB);
 	mmc->mmc_rx_1024_to_max_octets_gb +=
-	    readl(ioaddr + MMC_RX_1024_TO_MAX_OCTETS_GB);
-	mmc->mmc_rx_unicast_g += readl(ioaddr + MMC_RX_UNICAST_G);
-	mmc->mmc_rx_length_error += readl(ioaddr + MMC_RX_LENGTH_ERROR);
-	mmc->mmc_rx_autofrangetype += readl(ioaddr + MMC_RX_AUTOFRANGETYPE);
-	mmc->mmc_rx_pause_frames += readl(ioaddr + MMC_RX_PAUSE_FRAMES);
-	mmc->mmc_rx_fifo_overflow += readl(ioaddr + MMC_RX_FIFO_OVERFLOW);
-	mmc->mmc_rx_vlan_frames_gb += readl(ioaddr + MMC_RX_VLAN_FRAMES_GB);
-	mmc->mmc_rx_watchdog_error += readl(ioaddr + MMC_RX_WATCHDOG_ERROR);
+	    readl(mmcaddr + MMC_RX_1024_TO_MAX_OCTETS_GB);
+	mmc->mmc_rx_unicast_g += readl(mmcaddr + MMC_RX_UNICAST_G);
+	mmc->mmc_rx_length_error += readl(mmcaddr + MMC_RX_LENGTH_ERROR);
+	mmc->mmc_rx_autofrangetype += readl(mmcaddr + MMC_RX_AUTOFRANGETYPE);
+	mmc->mmc_rx_pause_frames += readl(mmcaddr + MMC_RX_PAUSE_FRAMES);
+	mmc->mmc_rx_fifo_overflow += readl(mmcaddr + MMC_RX_FIFO_OVERFLOW);
+	mmc->mmc_rx_vlan_frames_gb += readl(mmcaddr + MMC_RX_VLAN_FRAMES_GB);
+	mmc->mmc_rx_watchdog_error += readl(mmcaddr + MMC_RX_WATCHDOG_ERROR);
 	/* IPC */
-	mmc->mmc_rx_ipc_intr_mask += readl(ioaddr + MMC_RX_IPC_INTR_MASK);
-	mmc->mmc_rx_ipc_intr += readl(ioaddr + MMC_RX_IPC_INTR);
+	mmc->mmc_rx_ipc_intr_mask += readl(mmcaddr + MMC_RX_IPC_INTR_MASK);
+	mmc->mmc_rx_ipc_intr += readl(mmcaddr + MMC_RX_IPC_INTR);
 	/* IPv4 */
-	mmc->mmc_rx_ipv4_gd += readl(ioaddr + MMC_RX_IPV4_GD);
-	mmc->mmc_rx_ipv4_hderr += readl(ioaddr + MMC_RX_IPV4_HDERR);
-	mmc->mmc_rx_ipv4_nopay += readl(ioaddr + MMC_RX_IPV4_NOPAY);
-	mmc->mmc_rx_ipv4_frag += readl(ioaddr + MMC_RX_IPV4_FRAG);
-	mmc->mmc_rx_ipv4_udsbl += readl(ioaddr + MMC_RX_IPV4_UDSBL);
+	mmc->mmc_rx_ipv4_gd += readl(mmcaddr + MMC_RX_IPV4_GD);
+	mmc->mmc_rx_ipv4_hderr += readl(mmcaddr + MMC_RX_IPV4_HDERR);
+	mmc->mmc_rx_ipv4_nopay += readl(mmcaddr + MMC_RX_IPV4_NOPAY);
+	mmc->mmc_rx_ipv4_frag += readl(mmcaddr + MMC_RX_IPV4_FRAG);
+	mmc->mmc_rx_ipv4_udsbl += readl(mmcaddr + MMC_RX_IPV4_UDSBL);
 
-	mmc->mmc_rx_ipv4_gd_octets += readl(ioaddr + MMC_RX_IPV4_GD_OCTETS);
+	mmc->mmc_rx_ipv4_gd_octets += readl(mmcaddr + MMC_RX_IPV4_GD_OCTETS);
 	mmc->mmc_rx_ipv4_hderr_octets +=
-	    readl(ioaddr + MMC_RX_IPV4_HDERR_OCTETS);
+	    readl(mmcaddr + MMC_RX_IPV4_HDERR_OCTETS);
 	mmc->mmc_rx_ipv4_nopay_octets +=
-	    readl(ioaddr + MMC_RX_IPV4_NOPAY_OCTETS);
-	mmc->mmc_rx_ipv4_frag_octets += readl(ioaddr + MMC_RX_IPV4_FRAG_OCTETS);
+	    readl(mmcaddr + MMC_RX_IPV4_NOPAY_OCTETS);
+	mmc->mmc_rx_ipv4_frag_octets += readl(mmcaddr +
+					      MMC_RX_IPV4_FRAG_OCTETS);
 	mmc->mmc_rx_ipv4_udsbl_octets +=
-	    readl(ioaddr + MMC_RX_IPV4_UDSBL_OCTETS);
+	    readl(mmcaddr + MMC_RX_IPV4_UDSBL_OCTETS);
 
 	/* IPV6 */
-	mmc->mmc_rx_ipv6_gd_octets += readl(ioaddr + MMC_RX_IPV6_GD_OCTETS);
+	mmc->mmc_rx_ipv6_gd_octets += readl(mmcaddr + MMC_RX_IPV6_GD_OCTETS);
 	mmc->mmc_rx_ipv6_hderr_octets +=
-	    readl(ioaddr + MMC_RX_IPV6_HDERR_OCTETS);
+	    readl(mmcaddr + MMC_RX_IPV6_HDERR_OCTETS);
 	mmc->mmc_rx_ipv6_nopay_octets +=
-	    readl(ioaddr + MMC_RX_IPV6_NOPAY_OCTETS);
+	    readl(mmcaddr + MMC_RX_IPV6_NOPAY_OCTETS);
 
-	mmc->mmc_rx_ipv6_gd += readl(ioaddr + MMC_RX_IPV6_GD);
-	mmc->mmc_rx_ipv6_hderr += readl(ioaddr + MMC_RX_IPV6_HDERR);
-	mmc->mmc_rx_ipv6_nopay += readl(ioaddr + MMC_RX_IPV6_NOPAY);
+	mmc->mmc_rx_ipv6_gd += readl(mmcaddr + MMC_RX_IPV6_GD);
+	mmc->mmc_rx_ipv6_hderr += readl(mmcaddr + MMC_RX_IPV6_HDERR);
+	mmc->mmc_rx_ipv6_nopay += readl(mmcaddr + MMC_RX_IPV6_NOPAY);
 
 	/* Protocols */
-	mmc->mmc_rx_udp_gd += readl(ioaddr + MMC_RX_UDP_GD);
-	mmc->mmc_rx_udp_err += readl(ioaddr + MMC_RX_UDP_ERR);
-	mmc->mmc_rx_tcp_gd += readl(ioaddr + MMC_RX_TCP_GD);
-	mmc->mmc_rx_tcp_err += readl(ioaddr + MMC_RX_TCP_ERR);
-	mmc->mmc_rx_icmp_gd += readl(ioaddr + MMC_RX_ICMP_GD);
-	mmc->mmc_rx_icmp_err += readl(ioaddr + MMC_RX_ICMP_ERR);
+	mmc->mmc_rx_udp_gd += readl(mmcaddr + MMC_RX_UDP_GD);
+	mmc->mmc_rx_udp_err += readl(mmcaddr + MMC_RX_UDP_ERR);
+	mmc->mmc_rx_tcp_gd += readl(mmcaddr + MMC_RX_TCP_GD);
+	mmc->mmc_rx_tcp_err += readl(mmcaddr + MMC_RX_TCP_ERR);
+	mmc->mmc_rx_icmp_gd += readl(mmcaddr + MMC_RX_ICMP_GD);
+	mmc->mmc_rx_icmp_err += readl(mmcaddr + MMC_RX_ICMP_ERR);
 
-	mmc->mmc_rx_udp_gd_octets += readl(ioaddr + MMC_RX_UDP_GD_OCTETS);
-	mmc->mmc_rx_udp_err_octets += readl(ioaddr + MMC_RX_UDP_ERR_OCTETS);
-	mmc->mmc_rx_tcp_gd_octets += readl(ioaddr + MMC_RX_TCP_GD_OCTETS);
-	mmc->mmc_rx_tcp_err_octets += readl(ioaddr + MMC_RX_TCP_ERR_OCTETS);
-	mmc->mmc_rx_icmp_gd_octets += readl(ioaddr + MMC_RX_ICMP_GD_OCTETS);
-	mmc->mmc_rx_icmp_err_octets += readl(ioaddr + MMC_RX_ICMP_ERR_OCTETS);
+	mmc->mmc_rx_udp_gd_octets += readl(mmcaddr + MMC_RX_UDP_GD_OCTETS);
+	mmc->mmc_rx_udp_err_octets += readl(mmcaddr + MMC_RX_UDP_ERR_OCTETS);
+	mmc->mmc_rx_tcp_gd_octets += readl(mmcaddr + MMC_RX_TCP_GD_OCTETS);
+	mmc->mmc_rx_tcp_err_octets += readl(mmcaddr + MMC_RX_TCP_ERR_OCTETS);
+	mmc->mmc_rx_icmp_gd_octets += readl(mmcaddr + MMC_RX_ICMP_GD_OCTETS);
+	mmc->mmc_rx_icmp_err_octets += readl(mmcaddr + MMC_RX_ICMP_ERR_OCTETS);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 8bbab97..26fb855 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -128,6 +128,7 @@ struct stmmac_priv {
 	int use_riwt;
 	int irq_wake;
 	spinlock_t ptp_lock;
+	void __iomem *mmcaddr;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbgfs_dir;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 3c7928e..fb2e7fc85 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -506,7 +506,7 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 	else {
 		/* If supported, for new GMAC chips expose the MMC counters */
 		if (priv->dma_cap.rmon) {
-			dwmac_mmc_read(priv->ioaddr, &priv->mmc);
+			dwmac_mmc_read(priv->mmcaddr, &priv->mmc);
 
 			for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
 				char *p;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2ebee81..977487a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1456,12 +1456,14 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 static void stmmac_mmc_setup(struct stmmac_priv *priv)
 {
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
-	    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
+			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
-	dwmac_mmc_intr_all_mask(priv->ioaddr);
+	priv->mmcaddr = priv->ioaddr + MMC_GMAC3_X_OFFSET;
+
+	dwmac_mmc_intr_all_mask(priv->mmcaddr);
 
 	if (priv->dma_cap.rmon) {
-		dwmac_mmc_ctrl(priv->ioaddr, mode);
+		dwmac_mmc_ctrl(priv->mmcaddr, mode);
 		memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
 	} else
 		pr_info(" No MAC Management Counters available\n");
-- 
1.9.1
