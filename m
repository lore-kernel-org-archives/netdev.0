From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/6] igb: remove unused defines
Date: Thu, 12 Feb 2009 20:18:26 -0800
Message-ID: <20090213041826.3848.28973.stgit@lost.foo-projects.org>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:54255
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758850AbZBMESs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:18:48 -0500
In-Reply-To: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes all of the unused defines from the .h files contained in
igb.  For some defines there was a use and so I plugged them into the correct
locations.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h   |   16 +-----
 drivers/net/igb/e1000_defines.h |  113 ---------------------------------------
 drivers/net/igb/e1000_mac.h     |    5 --
 drivers/net/igb/e1000_phy.c     |    3 -
 drivers/net/igb/e1000_regs.h    |   14 -----
 drivers/net/igb/igb.h           |   17 +-----
 drivers/net/igb/igb_ethtool.c   |    6 --
 drivers/net/igb/igb_main.c      |   12 ++--
 8 files changed, 11 insertions(+), 175 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index dd50237..2efbfca 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -58,9 +58,6 @@ extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
     E1000_EICR_RX_QUEUE2 |    \
     E1000_EICR_RX_QUEUE3)
 
-#define E1000_EIMS_RX_QUEUE E1000_EICR_RX_QUEUE
-#define E1000_EIMS_TX_QUEUE E1000_EICR_TX_QUEUE
-
 /* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
 
 /* Receive Descriptor - Advanced */
@@ -95,12 +92,6 @@ union e1000_adv_rx_desc {
 #define E1000_RXDADV_HDRBUFLEN_MASK      0x7FE0
 #define E1000_RXDADV_HDRBUFLEN_SHIFT     5
 
-/* RSS Hash results */
-
-/* RSS Packet Types as indicated in the receive descriptor */
-#define E1000_RXDADV_PKTTYPE_IPV4        0x00000010 /* IPV4 hdr present */
-#define E1000_RXDADV_PKTTYPE_TCP         0x00000100 /* TCP hdr present */
-
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
 	struct {
@@ -149,11 +140,8 @@ struct e1000_adv_tx_context_desc {
 #define E1000_RXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Rx Queue */
 
 /* Direct Cache Access (DCA) definitions */
-#define E1000_DCA_CTRL_DCA_ENABLE  0x00000000 /* DCA Enable */
-#define E1000_DCA_CTRL_DCA_DISABLE 0x00000001 /* DCA Disable */
-
-#define E1000_DCA_CTRL_DCA_MODE_CB1 0x00 /* DCA Mode CB1 */
-#define E1000_DCA_CTRL_DCA_MODE_CB2 0x02 /* DCA Mode CB2 */
+#define E1000_DCA_CTRL_DCA_MODE_DISABLE 0x01 /* DCA Disable */
+#define E1000_DCA_CTRL_DCA_MODE_CB2     0x02 /* DCA Mode CB2 */
 
 #define E1000_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
 #define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 5342e23..6e43385 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -42,33 +42,9 @@
 #define E1000_WUFC_EX   0x00000004 /* Directed Exact Wakeup Enable */
 #define E1000_WUFC_MC   0x00000008 /* Directed Multicast Wakeup Enable */
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
-#define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
-#define E1000_WUFC_IPV4 0x00000040 /* Directed IPv4 Packet Wakeup Enable */
-#define E1000_WUFC_IPV6 0x00000080 /* Directed IPv6 Packet Wakeup Enable */
-#define E1000_WUFC_FLX0 0x00010000 /* Flexible Filter 0 Enable */
-#define E1000_WUFC_FLX1 0x00020000 /* Flexible Filter 1 Enable */
-#define E1000_WUFC_FLX2 0x00040000 /* Flexible Filter 2 Enable */
-#define E1000_WUFC_FLX3 0x00080000 /* Flexible Filter 3 Enable */
-#define E1000_WUFC_FLX_FILTERS 0x000F0000 /* Mask for the 4 flexible filters */
-
-/* Wake Up Status */
-
-/* Wake Up Packet Length */
-
-/* Four Flexible Filters are supported */
-#define E1000_FLEXIBLE_FILTER_COUNT_MAX 4
-
-/* Each Flexible Filter is at most 128 (0x80) bytes in length */
-#define E1000_FLEXIBLE_FILTER_SIZE_MAX  128
-
 
 /* Extended Device Control */
-#define E1000_CTRL_EXT_GPI1_EN   0x00000002 /* Maps SDP5 to GPI1 */
-#define E1000_CTRL_EXT_SDP4_DATA 0x00000010 /* Value of SW Defineable Pin 4 */
-#define E1000_CTRL_EXT_SDP5_DATA 0x00000020 /* Value of SW Defineable Pin 5 */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
-#define E1000_CTRL_EXT_SDP4_DIR  0x00000100 /* Direction of SDP4 0=in 1=out */
-#define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_SGMII   0x00800000
@@ -103,13 +79,6 @@
 #define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
 #define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
-#define E1000_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
-#define E1000_RXD_ERR_CE        0x01    /* CRC Error */
-#define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
-#define E1000_RXD_ERR_SEQ       0x04    /* Sequence Error */
-#define E1000_RXD_ERR_CXE       0x10    /* Carrier Extension Error */
-#define E1000_RXD_ERR_RXE       0x80    /* Rx Data Error */
-#define E1000_RXD_SPC_VLAN_MASK 0x0FFF  /* VLAN ID is in lower 12 bits */
 
 #define E1000_RXDEXT_STATERR_CE    0x01000000
 #define E1000_RXDEXT_STATERR_SE    0x02000000
@@ -119,14 +88,6 @@
 #define E1000_RXDEXT_STATERR_IPE   0x40000000
 #define E1000_RXDEXT_STATERR_RXE   0x80000000
 
-/* mask to determine if packets should be dropped due to frame errors */
-#define E1000_RXD_ERR_FRAME_ERR_MASK ( \
-    E1000_RXD_ERR_CE  |                \
-    E1000_RXD_ERR_SE  |                \
-    E1000_RXD_ERR_SEQ |                \
-    E1000_RXD_ERR_CXE |                \
-    E1000_RXD_ERR_RXE)
-
 /* Same mask, but for extended and packet split descriptors */
 #define E1000_RXDEXT_ERR_FRAME_ERR_MASK ( \
     E1000_RXDEXT_STATERR_CE  |            \
@@ -145,16 +106,11 @@
 /* Management Control */
 #define E1000_MANC_SMBUS_EN      0x00000001 /* SMBus Enabled - RO */
 #define E1000_MANC_ASF_EN        0x00000002 /* ASF Enabled - RO */
-#define E1000_MANC_ARP_EN        0x00002000 /* Enable ARP Request Filtering */
 /* Enable Neighbor Discovery Filtering */
 #define E1000_MANC_RCV_TCO_EN    0x00020000 /* Receive TCO Packets Enabled */
 #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000 /* Block phy resets */
 /* Enable MAC address filtering */
 #define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000
-/* Enable MNG packets to host memory */
-#define E1000_MANC_EN_MNG2HOST   0x00200000
-/* Enable IP address filtering */
-
 
 /* Receive Control */
 #define E1000_RCTL_EN             0x00000002    /* enable */
@@ -162,14 +118,11 @@
 #define E1000_RCTL_UPE            0x00000008    /* unicast promiscuous enable */
 #define E1000_RCTL_MPE            0x00000010    /* multicast promiscuous enab */
 #define E1000_RCTL_LPE            0x00000020    /* long packet enable */
-#define E1000_RCTL_LBM_NO         0x00000000    /* no loopback mode */
 #define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
 #define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
 #define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
 #define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
 #define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
-#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
-#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
 #define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
 #define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
@@ -226,11 +179,7 @@
 /* enable link status from external LINK_0 and LINK_1 pins */
 #define E1000_CTRL_SWDPIN0  0x00040000  /* SWDPIN 0 value */
 #define E1000_CTRL_SWDPIN1  0x00080000  /* SWDPIN 1 value */
-#define E1000_CTRL_SWDPIN2  0x00100000  /* SWDPIN 2 value */
-#define E1000_CTRL_SWDPIN3  0x00200000  /* SWDPIN 3 value */
 #define E1000_CTRL_SWDPIO0  0x00400000  /* SWDPIN 0 Input or output */
-#define E1000_CTRL_SWDPIO2  0x01000000  /* SWDPIN 2 input or output */
-#define E1000_CTRL_SWDPIO3  0x02000000  /* SWDPIN 3 input or output */
 #define E1000_CTRL_RST      0x04000000  /* Global reset */
 #define E1000_CTRL_RFCE     0x08000000  /* Receive Flow Control enable */
 #define E1000_CTRL_TFCE     0x10000000  /* Transmit flow control enable */
@@ -308,9 +257,7 @@
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
 
 /* LED Control */
-#define E1000_LEDCTL_LED0_MODE_MASK       0x0000000F
 #define E1000_LEDCTL_LED0_MODE_SHIFT      0
-#define E1000_LEDCTL_LED0_IVRT            0x00000040
 #define E1000_LEDCTL_LED0_BLINK           0x00000080
 
 #define E1000_LEDCTL_MODE_LED_ON        0xE
@@ -357,12 +304,7 @@
 
 #define MAX_JUMBO_FRAME_SIZE    0x3F00
 
-/* Extended Configuration Control and Size */
-#define E1000_PHY_CTRL_GBE_DISABLE        0x00000040
-
 /* PBA constants */
-#define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
-#define E1000_PBA_24K 0x0018
 #define E1000_PBA_34K 0x0022
 #define E1000_PBA_64K 0x0040    /* 64KB */
 
@@ -378,41 +320,13 @@
 
 /* Interrupt Cause Read */
 #define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
-#define E1000_ICR_TXQE          0x00000002 /* Transmit Queue empty */
 #define E1000_ICR_LSC           0x00000004 /* Link Status Change */
 #define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
 #define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
-#define E1000_ICR_RXO           0x00000040 /* rx overrun */
 #define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
-#define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
-#define E1000_ICR_RXCFG         0x00000400 /* Rx /c/ ordered set */
-#define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
-#define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
-#define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
-#define E1000_ICR_GPI_EN3       0x00004000 /* GP Int 3 */
-#define E1000_ICR_TXD_LOW       0x00008000
-#define E1000_ICR_SRPD          0x00010000
-#define E1000_ICR_ACK           0x00020000 /* Receive Ack frame */
-#define E1000_ICR_MNG           0x00040000 /* Manageability event */
-#define E1000_ICR_DOCK          0x00080000 /* Dock/Undock */
 /* If this bit asserted, the driver should claim the interrupt */
 #define E1000_ICR_INT_ASSERTED  0x80000000
-/* queue 0 Rx descriptor FIFO parity error */
-#define E1000_ICR_RXD_FIFO_PAR0 0x00100000
-/* queue 0 Tx descriptor FIFO parity error */
-#define E1000_ICR_TXD_FIFO_PAR0 0x00200000
-/* host arb read buffer parity error */
-#define E1000_ICR_HOST_ARB_PAR  0x00400000
-#define E1000_ICR_PB_PAR        0x00800000 /* packet buffer parity error */
-/* queue 1 Rx descriptor FIFO parity error */
-#define E1000_ICR_RXD_FIFO_PAR1 0x01000000
-/* queue 1 Tx descriptor FIFO parity error */
-#define E1000_ICR_TXD_FIFO_PAR1 0x02000000
-/* FW changed the status of DISSW bit in the FWSM */
-#define E1000_ICR_DSW           0x00000020
 /* LAN connected device generates an interrupt */
-#define E1000_ICR_PHYINT        0x00001000
-#define E1000_ICR_EPRST         0x00100000 /* ME handware reset occurs */
 #define E1000_ICR_DOUTSYNC      0x10000000 /* NIC DMA out of sync */
 
 /* Extended Interrupt Cause Read */
@@ -424,7 +338,6 @@
 #define E1000_EICR_TX_QUEUE1    0x00000200 /* Tx Queue 1 Interrupt */
 #define E1000_EICR_TX_QUEUE2    0x00000400 /* Tx Queue 2 Interrupt */
 #define E1000_EICR_TX_QUEUE3    0x00000800 /* Tx Queue 3 Interrupt */
-#define E1000_EICR_TCP_TIMER    0x40000000 /* TCP Timer */
 #define E1000_EICR_OTHER        0x80000000 /* Interrupt Cause Active */
 /* TCP Timer */
 
@@ -454,13 +367,11 @@
 #define E1000_IMS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
 
 /* Extended Interrupt Mask Set */
-#define E1000_EIMS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
 #define E1000_EIMS_OTHER        E1000_EICR_OTHER   /* Interrupt Cause Active */
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
-#define E1000_ICS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
 
 /* Extended Interrupt Cause Set */
 
@@ -496,7 +407,6 @@
 #define E1000_ERR_MAC_INIT 5
 #define E1000_ERR_RESET   9
 #define E1000_ERR_MASTER_REQUESTS_PENDING 10
-#define E1000_ERR_HOST_INTERFACE_COMMAND 11
 #define E1000_BLK_PHY_RESET   12
 #define E1000_ERR_SWFW_SYNC 13
 #define E1000_NOT_IMPLEMENTED 14
@@ -516,30 +426,9 @@
 /* Flow Control */
 #define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
 
-/* Transmit Configuration Word */
-#define E1000_TXCW_ANE        0x80000000        /* Auto-neg enable */
-
-/* Receive Configuration Word */
-
-/* PCI Express Control */
-#define E1000_GCR_RXD_NO_SNOOP          0x00000001
-#define E1000_GCR_RXDSCW_NO_SNOOP       0x00000002
-#define E1000_GCR_RXDSCR_NO_SNOOP       0x00000004
-#define E1000_GCR_TXD_NO_SNOOP          0x00000008
-#define E1000_GCR_TXDSCW_NO_SNOOP       0x00000010
-#define E1000_GCR_TXDSCR_NO_SNOOP       0x00000020
-
-#define PCIE_NO_SNOOP_ALL (E1000_GCR_RXD_NO_SNOOP         | \
-			   E1000_GCR_RXDSCW_NO_SNOOP      | \
-			   E1000_GCR_RXDSCR_NO_SNOOP      | \
-			   E1000_GCR_TXD_NO_SNOOP         | \
-			   E1000_GCR_TXDSCW_NO_SNOOP      | \
-			   E1000_GCR_TXDSCR_NO_SNOOP)
-
 /* PHY Control Register */
 #define MII_CR_FULL_DUPLEX      0x0100  /* FDX =1, half duplex =0 */
 #define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
-#define MII_CR_POWER_DOWN       0x0800  /* Power down */
 #define MII_CR_AUTO_NEG_EN      0x1000  /* Auto Neg Enable */
 #define MII_CR_LOOPBACK         0x4000  /* 0 = normal, 1 = loopback */
 #define MII_CR_RESET            0x8000  /* 0 = normal, 1 = PHY reset */
@@ -669,10 +558,8 @@
 #define IGP_LED3_MODE           0x07000000
 
 /* PCI/PCI-X/PCI-EX Config space */
-#define PCI_HEADER_TYPE_REGISTER     0x0E
 #define PCIE_LINK_STATUS             0x12
 
-#define PCI_HEADER_TYPE_MULTIFUNC    0x80
 #define PCIE_LINK_WIDTH_MASK         0x3F0
 #define PCIE_LINK_WIDTH_SHIFT        4
 
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 91461de..e5200de 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -82,13 +82,8 @@ enum e1000_mng_mode {
 #define E1000_FWSM_MODE_MASK  0xE
 #define E1000_FWSM_MODE_SHIFT 1
 
-#define E1000_MNG_DHCP_COMMAND_TIMEOUT       10
 #define E1000_MNG_DHCP_COOKIE_STATUS_VLAN    0x2
 
-#define E1000_HICR_EN              0x01  /* Enable bit - RO */
-/* Driver sets this bit when done to put command in RAM */
-#define E1000_HICR_C               0x02
-
 extern void e1000_init_function_pointers_82575(struct e1000_hw *hw);
 extern u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index ff0050e..de2d486 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -39,9 +39,6 @@ static s32  igb_wait_autoneg(struct e1000_hw *hw);
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
 	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
-#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
-		(sizeof(e1000_m88_cable_length_table) / \
-		 sizeof(e1000_m88_cable_length_table[0]))
 
 static const u16 e1000_igp_2_cable_length_table[] =
     { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 5038b73..4e3826a 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -73,7 +73,6 @@
 #define E1000_TCPTIMER 0x0104C  /* TCP Timer - RW */
 #define E1000_FCRTL    0x02160  /* Flow Control Receive Threshold Low - RW */
 #define E1000_FCRTH    0x02168  /* Flow Control Receive Threshold High - RW */
-#define E1000_RDFPCQ(_n)  (0x02430 + (0x4 * (_n)))
 #define E1000_FCRTV    0x02460  /* Flow Control Refresh Timer Value - RW */
 /* Split and Replication RX Control - RW */
 /*
@@ -110,7 +109,6 @@
 				    : (0x0E018 + ((_n) * 0x40)))
 #define E1000_TXDCTL(_n)  ((_n) < 4 ? (0x03828 + ((_n) * 0x100)) \
 				    : (0x0E028 + ((_n) * 0x40)))
-#define E1000_TARC(_n)    (0x03840 + (_n << 8))
 #define E1000_DCA_TXCTRL(_n) (0x03814 + (_n << 8))
 #define E1000_DCA_RXCTRL(_n) (0x02814 + (_n << 8))
 #define E1000_TDWBAL(_n)  ((_n) < 4 ? (0x03838 + ((_n) * 0x100)) \
@@ -233,9 +231,7 @@
 #define E1000_MANC     0x05820  /* Management Control - RW */
 #define E1000_IPAV     0x05838  /* IP Address Valid - RW */
 #define E1000_WUPL     0x05900  /* Wakeup Packet Length - RW */
-#define E1000_HOST_IF  0x08800  /* Host Interface */
 
-#define E1000_MANC2H      0x05860 /* Management Control To Host - RW */
 #define E1000_SW_FW_SYNC  0x05B5C /* Software-Firmware Synchronization - RW */
 #define E1000_CCMCTL      0x05B48 /* CCM Control Register */
 #define E1000_GIOCTL      0x05B44 /* GIO Analog Control Register */
@@ -243,9 +239,7 @@
 #define E1000_FACTPS    0x05B30 /* Function Active and Power State to MNG */
 #define E1000_SWSM      0x05B50 /* SW Semaphore */
 #define E1000_FWSM      0x05B54 /* FW Semaphore */
-#define E1000_DCA_ID    0x05B70 /* DCA Requester ID Information - RO */
 #define E1000_DCA_CTRL  0x05B74 /* DCA Control - RW */
-#define E1000_HICR      0x08F00 /* Host Inteface Control */
 
 /* RSS registers */
 #define E1000_MRQC      0x05818 /* Multiple Receive Control - RW */
@@ -254,14 +248,6 @@
 #define E1000_IMIRVP    0x05AC0 /* Immediate Interrupt RX VLAN Priority - RW */
 /* MSI-X Allocation Register (_i) - RW */
 #define E1000_MSIXBM(_i)    (0x01600 + ((_i) * 4))
-/* MSI-X Table entry addr low reg 0 - RW */
-#define E1000_MSIXTADD(_i)  (0x0C000 + ((_i) * 0x10))
-/* MSI-X Table entry addr upper reg 0 - RW */
-#define E1000_MSIXTUADD(_i) (0x0C004 + ((_i) * 0x10))
-/* MSI-X Table entry message reg 0 - RW */
-#define E1000_MSIXTMSG(_i)  (0x0C008 + ((_i) * 0x10))
-/* MSI-X Table entry vector ctrl reg 0 - RW */
-#define E1000_MSIXVCTRL(_i) (0x0C00C + ((_i) * 0x10))
 /* Redirection Table - RW Array */
 #define E1000_RETA(_i)  (0x05C00 + ((_i) * 4))
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index e507449..a07d809 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -36,17 +36,9 @@
 
 struct igb_adapter;
 
-/* Interrupt defines */
-#define IGB_MIN_DYN_ITR 3000
-#define IGB_MAX_DYN_ITR 96000
-
 /* ((1000000000ns / (6000ints/s * 1024ns)) << 2 = 648 */
 #define IGB_START_ITR 648
 
-#define IGB_DYN_ITR_PACKET_THRESHOLD 2
-#define IGB_DYN_ITR_LENGTH_LOW 200
-#define IGB_DYN_ITR_LENGTH_HIGH 1000
-
 /* TX/RX descriptor defines */
 #define IGB_DEFAULT_TXD                  256
 #define IGB_MIN_TXD                       80
@@ -88,8 +80,6 @@ struct igb_adapter;
 #define IGB_RXBUFFER_512   512
 #define IGB_RXBUFFER_1024  1024
 #define IGB_RXBUFFER_2048  2048
-#define IGB_RXBUFFER_4096  4096
-#define IGB_RXBUFFER_8192  8192
 #define IGB_RXBUFFER_16384 16384
 
 /* Packet Buffer allocations */
@@ -278,10 +268,9 @@ struct igb_adapter {
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
-#define IGB_FLAG_MSI_ENABLE        (1 << 1)
-#define IGB_FLAG_DCA_ENABLED       (1 << 2)
-#define IGB_FLAG_QUAD_PORT_A       (1 << 3)
-#define IGB_FLAG_NEED_CTX_IDX      (1 << 4)
+#define IGB_FLAG_DCA_ENABLED       (1 << 1)
+#define IGB_FLAG_QUAD_PORT_A       (1 << 2)
+#define IGB_FLAG_NEED_CTX_IDX      (1 << 3)
 
 enum e1000_state_t {
 	__IGB_TESTING,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index bd050b1..30b7bc0 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1366,8 +1366,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 	wr32(E1000_RDH(0), 0);
 	wr32(E1000_RDT(0), 0);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
-	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
-		E1000_RCTL_RDMTS_HALF |
+	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 	wr32(E1000_RCTL, rctl);
 	wr32(E1000_SRRCTL(0), 0);
@@ -1855,9 +1854,6 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-/* toggle LED 4 times per second = 2 "blinks" per second */
-#define IGB_ID_INTERVAL		(HZ/4)
-
 /* bit defines for adapter->led_status */
 #define IGB_LED_ON		0
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 712cfd6..c188371 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1232,7 +1232,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	hw->fc.original_type = e1000_fc_default;
 	hw->fc.type = e1000_fc_default;
 
-	adapter->itr_setting = 3;
+	adapter->itr_setting = IGB_DEFAULT_ITR;
 	adapter->itr = IGB_START_ITR;
 
 	igb_validate_mdi_setting(hw);
@@ -1293,7 +1293,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		dev_info(&pdev->dev, "DCA enabled\n");
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
-		wr32(E1000_DCA_CTRL, 2);
+		wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
 		igb_setup_dca(adapter);
 	}
 #endif
@@ -1373,7 +1373,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 		dev_info(&pdev->dev, "DCA disabled\n");
 		dca_remove_requester(&pdev->dev);
 		adapter->flags &= ~IGB_FLAG_DCA_ENABLED;
-		wr32(E1000_DCA_CTRL, 1);
+		wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_DISABLE);
 	}
 #endif
 
@@ -2929,8 +2929,6 @@ static int igb_maybe_stop_tx(struct net_device *netdev,
 	return __igb_maybe_stop_tx(netdev, tx_ring, size);
 }
 
-#define TXD_USE_COUNT(S) (((S) >> (IGB_MAX_TXD_PWR)) + 1)
-
 static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				   struct net_device *netdev,
 				   struct igb_ring *tx_ring)
@@ -3434,7 +3432,7 @@ static int __igb_notify_dca(struct device *dev, void *data)
 			break;
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
-		wr32(E1000_DCA_CTRL, 2);
+		wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
 		if (dca_add_requester(dev) == 0) {
 			adapter->flags |= IGB_FLAG_DCA_ENABLED;
 			dev_info(&adapter->pdev->dev, "DCA enabled\n");
@@ -3449,7 +3447,7 @@ static int __igb_notify_dca(struct device *dev, void *data)
 			dca_remove_requester(dev);
 			dev_info(&adapter->pdev->dev, "DCA disabled\n");
 			adapter->flags &= ~IGB_FLAG_DCA_ENABLED;
-			wr32(E1000_DCA_CTRL, 1);
+			wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_DISABLE);
 		}
 		break;
 	}

