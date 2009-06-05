From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 05/10] ixgbe: Add hardware defines for Flow Director
	for 82599
Date: Thu, 04 Jun 2009 19:01:06 -0700
Message-ID: <20090605020105.8468.15861.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:51067 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752479AbZFECBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:01:22 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Flow Director is a Rx filter mechanism designed to match Rx flows back to
the same CPU that the flow's Tx occurred from.  This patch adds the first
piece, the defines for the hardware registers, to enable this feature in
82599 hardware.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |  147 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 4402552..68cac36 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -231,6 +231,34 @@
 #define IXGBE_RETA(_i)  (0x05C00 + ((_i) * 4))  /* 32 of these (0-31) */
 #define IXGBE_RSSRK(_i) (0x05C80 + ((_i) * 4))  /* 10 of these (0-9) */
 
+/* Flow Director registers */
+#define IXGBE_FDIRCTRL  0x0EE00
+#define IXGBE_FDIRHKEY  0x0EE68
+#define IXGBE_FDIRSKEY  0x0EE6C
+#define IXGBE_FDIRDIP4M 0x0EE3C
+#define IXGBE_FDIRSIP4M 0x0EE40
+#define IXGBE_FDIRTCPM  0x0EE44
+#define IXGBE_FDIRUDPM  0x0EE48
+#define IXGBE_FDIRIP6M  0x0EE74
+#define IXGBE_FDIRM     0x0EE70
+
+/* Flow Director Stats registers */
+#define IXGBE_FDIRFREE  0x0EE38
+#define IXGBE_FDIRLEN   0x0EE4C
+#define IXGBE_FDIRUSTAT 0x0EE50
+#define IXGBE_FDIRFSTAT 0x0EE54
+#define IXGBE_FDIRMATCH 0x0EE58
+#define IXGBE_FDIRMISS  0x0EE5C
+
+/* Flow Director Programming registers */
+#define IXGBE_FDIRSIPv6(_i) (0x0EE0C + ((_i) * 4)) /* 3 of these (0-2) */
+#define IXGBE_FDIRIPSA      0x0EE18
+#define IXGBE_FDIRIPDA      0x0EE1C
+#define IXGBE_FDIRPORT      0x0EE20
+#define IXGBE_FDIRVLAN      0x0EE24
+#define IXGBE_FDIRHASH      0x0EE28
+#define IXGBE_FDIRCMD       0x0EE2C
+
 /* Transmit DMA registers */
 #define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40)) /* 32 of these (0-31)*/
 #define IXGBE_TDBAH(_i) (0x06004 + ((_i) * 0x40))
@@ -1652,6 +1680,9 @@
 #define IXGBE_RXDADV_ERR_SHIFT          20         /* RDESC.ERRORS shift */
 #define IXGBE_RXDADV_ERR_FCEOFE         0x80000000 /* FCoEFe/IPE */
 #define IXGBE_RXDADV_ERR_FCERR          0x00700000 /* FCERR/FDIRERR */
+#define IXGBE_RXDADV_ERR_FDIR_LEN       0x00100000 /* FDIR Length error */
+#define IXGBE_RXDADV_ERR_FDIR_DROP      0x00200000 /* FDIR Drop error */
+#define IXGBE_RXDADV_ERR_FDIR_COLL      0x00400000 /* FDIR Collision error */
 #define IXGBE_RXDADV_ERR_HBO    0x00800000 /*Header Buffer Overflow */
 #define IXGBE_RXDADV_ERR_CE     0x01000000 /* CRC Error */
 #define IXGBE_RXDADV_ERR_LE     0x02000000 /* Length Error */
@@ -1784,6 +1815,82 @@
 
 #endif
 
+enum ixgbe_fdir_pballoc_type {
+	IXGBE_FDIR_PBALLOC_64K = 0,
+	IXGBE_FDIR_PBALLOC_128K,
+	IXGBE_FDIR_PBALLOC_256K,
+};
+#define IXGBE_FDIR_PBALLOC_SIZE_SHIFT           16
+
+/* Flow Director register values */
+#define IXGBE_FDIRCTRL_PBALLOC_64K              0x00000001
+#define IXGBE_FDIRCTRL_PBALLOC_128K             0x00000002
+#define IXGBE_FDIRCTRL_PBALLOC_256K             0x00000003
+#define IXGBE_FDIRCTRL_INIT_DONE                0x00000008
+#define IXGBE_FDIRCTRL_PERFECT_MATCH            0x00000010
+#define IXGBE_FDIRCTRL_REPORT_STATUS            0x00000020
+#define IXGBE_FDIRCTRL_REPORT_STATUS_ALWAYS     0x00000080
+#define IXGBE_FDIRCTRL_DROP_Q_SHIFT             8
+#define IXGBE_FDIRCTRL_FLEX_SHIFT               16
+#define IXGBE_FDIRCTRL_SEARCHLIM                0x00800000
+#define IXGBE_FDIRCTRL_MAX_LENGTH_SHIFT         24
+#define IXGBE_FDIRCTRL_FULL_THRESH_MASK         0xF0000000
+#define IXGBE_FDIRCTRL_FULL_THRESH_SHIFT        28
+
+#define IXGBE_FDIRTCPM_DPORTM_SHIFT             16
+#define IXGBE_FDIRUDPM_DPORTM_SHIFT             16
+#define IXGBE_FDIRIP6M_DIPM_SHIFT               16
+#define IXGBE_FDIRM_VLANID                      0x00000001
+#define IXGBE_FDIRM_VLANP                       0x00000002
+#define IXGBE_FDIRM_POOL                        0x00000004
+#define IXGBE_FDIRM_L3P                         0x00000008
+#define IXGBE_FDIRM_L4P                         0x00000010
+#define IXGBE_FDIRM_FLEX                        0x00000020
+#define IXGBE_FDIRM_DIPv6                       0x00000040
+
+#define IXGBE_FDIRFREE_FREE_MASK                0xFFFF
+#define IXGBE_FDIRFREE_FREE_SHIFT               0
+#define IXGBE_FDIRFREE_COLL_MASK                0x7FFF0000
+#define IXGBE_FDIRFREE_COLL_SHIFT               16
+#define IXGBE_FDIRLEN_MAXLEN_MASK               0x3F
+#define IXGBE_FDIRLEN_MAXLEN_SHIFT              0
+#define IXGBE_FDIRLEN_MAXHASH_MASK              0x7FFF0000
+#define IXGBE_FDIRLEN_MAXHASH_SHIFT             16
+#define IXGBE_FDIRUSTAT_ADD_MASK                0xFFFF
+#define IXGBE_FDIRUSTAT_ADD_SHIFT               0
+#define IXGBE_FDIRUSTAT_REMOVE_MASK             0xFFFF0000
+#define IXGBE_FDIRUSTAT_REMOVE_SHIFT            16
+#define IXGBE_FDIRFSTAT_FADD_MASK               0x00FF
+#define IXGBE_FDIRFSTAT_FADD_SHIFT              0
+#define IXGBE_FDIRFSTAT_FREMOVE_MASK            0xFF00
+#define IXGBE_FDIRFSTAT_FREMOVE_SHIFT           8
+#define IXGBE_FDIRPORT_DESTINATION_SHIFT        16
+#define IXGBE_FDIRVLAN_FLEX_SHIFT               16
+#define IXGBE_FDIRHASH_BUCKET_VALID_SHIFT       15
+#define IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT       16
+
+#define IXGBE_FDIRCMD_CMD_MASK                  0x00000003
+#define IXGBE_FDIRCMD_CMD_ADD_FLOW              0x00000001
+#define IXGBE_FDIRCMD_CMD_REMOVE_FLOW           0x00000002
+#define IXGBE_FDIRCMD_CMD_QUERY_REM_FILT        0x00000003
+#define IXGBE_FDIRCMD_CMD_QUERY_REM_HASH        0x00000007
+#define IXGBE_FDIRCMD_FILTER_UPDATE             0x00000008
+#define IXGBE_FDIRCMD_IPv6DMATCH                0x00000010
+#define IXGBE_FDIRCMD_L4TYPE_UDP                0x00000020
+#define IXGBE_FDIRCMD_L4TYPE_TCP                0x00000040
+#define IXGBE_FDIRCMD_L4TYPE_SCTP               0x00000060
+#define IXGBE_FDIRCMD_IPV6                      0x00000080
+#define IXGBE_FDIRCMD_CLEARHT                   0x00000100
+#define IXGBE_FDIRCMD_DROP                      0x00000200
+#define IXGBE_FDIRCMD_INT                       0x00000400
+#define IXGBE_FDIRCMD_LAST                      0x00000800
+#define IXGBE_FDIRCMD_COLLISION                 0x00001000
+#define IXGBE_FDIRCMD_QUEUE_EN                  0x00008000
+#define IXGBE_FDIRCMD_RX_QUEUE_SHIFT            16
+#define IXGBE_FDIRCMD_VT_POOL_SHIFT             24
+#define IXGBE_FDIR_INIT_DONE_POLL               10
+#define IXGBE_FDIRCMD_CMD_POLL                  10
+
 /* Transmit Descriptor - Legacy */
 struct ixgbe_legacy_tx_desc {
 	u64 buffer_addr;       /* Address of the descriptor's data buffer */
@@ -1957,6 +2064,45 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_10GBASE_KR   0x0800
 #define IXGBE_PHYSICAL_LAYER_10GBASE_XAUI 0x1000
 
+/* Software ATR hash keys */
+#define IXGBE_ATR_BUCKET_HASH_KEY    0xE214AD3D
+#define IXGBE_ATR_SIGNATURE_HASH_KEY 0x14364D17
+
+/* Software ATR input stream offsets and masks */
+#define IXGBE_ATR_VLAN_OFFSET       0
+#define IXGBE_ATR_SRC_IPV6_OFFSET   2
+#define IXGBE_ATR_SRC_IPV4_OFFSET  14
+#define IXGBE_ATR_DST_IPV6_OFFSET  18
+#define IXGBE_ATR_DST_IPV4_OFFSET  30
+#define IXGBE_ATR_SRC_PORT_OFFSET  34
+#define IXGBE_ATR_DST_PORT_OFFSET  36
+#define IXGBE_ATR_FLEX_BYTE_OFFSET 38
+#define IXGBE_ATR_VM_POOL_OFFSET   40
+#define IXGBE_ATR_L4TYPE_OFFSET    41
+
+#define IXGBE_ATR_L4TYPE_MASK      0x3
+#define IXGBE_ATR_L4TYPE_IPV6_MASK 0x4
+#define IXGBE_ATR_L4TYPE_UDP       0x1
+#define IXGBE_ATR_L4TYPE_TCP       0x2
+#define IXGBE_ATR_L4TYPE_SCTP      0x3
+#define IXGBE_ATR_HASH_MASK     0x7fff
+
+/* Flow Director ATR input struct. */
+struct ixgbe_atr_input {
+	/* Byte layout in order, all values with MSB first:
+	 *
+	 * vlan_id    - 2 bytes
+	 * src_ip     - 16 bytes
+	 * dst_ip     - 16 bytes
+	 * src_port   - 2 bytes
+	 * dst_port   - 2 bytes
+	 * flex_bytes - 2 bytes
+	 * vm_pool    - 1 byte
+	 * l4type     - 1 byte
+	 */
+	u8 byte_stream[42];
+};
+
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,
 	ixgbe_eeprom_spi,
@@ -2348,6 +2494,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_SFP_NOT_SUPPORTED             -19
 #define IXGBE_ERR_SFP_NOT_PRESENT               -20
 #define IXGBE_ERR_SFP_NO_INIT_SEQ_PRESENT       -21
+#define IXGBE_ERR_FDIR_REINIT_FAILED            -23
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */

