From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .28
Date: Wed, 3 Sep 2008 10:37:45 -0400
Message-ID: <20080903143745.GA29171@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43098 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbYICOhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:37:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git dave=
m-next

to receive the following updates:

 drivers/net/8139cp.c                    |   14 +-
 drivers/net/8139too.c                   |    4 +-
 drivers/net/Makefile                    |    2 +-
 drivers/net/bonding/bond_alb.c          |    4 +-
 drivers/net/bonding/bond_main.c         |    6 +-
 drivers/net/e1000e/82571.c              |  153 ++++++-
 drivers/net/e1000e/defines.h            |   15 +
 drivers/net/e1000e/e1000.h              |   31 ++-
 drivers/net/e1000e/es2lan.c             |    2 +-
 drivers/net/e1000e/ethtool.c            |   60 ++-
 drivers/net/e1000e/hw.h                 |   15 +-
 drivers/net/e1000e/ich8lan.c            |  173 +++++++-
 drivers/net/e1000e/lib.c                |    7 +-
 drivers/net/e1000e/netdev.c             |  435 ++++++++++++++++--
 drivers/net/e1000e/param.c              |   27 ++
 drivers/net/e1000e/phy.c                |  194 ++++++++-
 drivers/net/ibm_newemac/mal.h           |    4 +-
 drivers/net/igb/igb_main.c              |   12 +-
 drivers/net/ixgbe/ixgbe.h               |   43 ++-
 drivers/net/ixgbe/ixgbe_82598.c         |    6 +-
 drivers/net/ixgbe/ixgbe_common.c        |  140 ++++++-
 drivers/net/ixgbe/ixgbe_common.h        |    4 +-
 drivers/net/ixgbe/ixgbe_ethtool.c       |    6 +-
 drivers/net/ixgbe/ixgbe_main.c          |  721 +++++++++++++++++------=
------
 drivers/net/ixgbe/ixgbe_type.h          |   47 +-
 drivers/net/myri10ge/myri10ge.c         |    1 -
 drivers/net/netxen/netxen_nic_ethtool.c |    1 -
 drivers/net/r8169.c                     |  401 ++++++++++++++---
 drivers/net/s2io.c                      |    4 +-
 drivers/net/sfc/bitfield.h              |  178 +++++---
 drivers/net/sfc/boards.c                |   12 +-
 drivers/net/sfc/boards.h                |    2 -
 drivers/net/sfc/efx.c                   |  471 ++++++++-----------
 drivers/net/sfc/efx.h                   |   14 +-
 drivers/net/sfc/enum.h                  |    9 +-
 drivers/net/sfc/ethtool.c               |  184 ++++----
 drivers/net/sfc/falcon.c                |  767 ++++++++++++++++++++++-=
--------
 drivers/net/sfc/falcon.h                |   16 +-
 drivers/net/sfc/falcon_hwdefs.h         |   79 +++-
 drivers/net/sfc/falcon_xmac.c           |  330 ++++++--------
 drivers/net/sfc/mac.h                   |    4 -
 drivers/net/sfc/mdio_10g.c              |   16 +-
 drivers/net/sfc/mdio_10g.h              |   13 +-
 drivers/net/sfc/net_driver.h            |  136 +++---
 drivers/net/sfc/phy.h                   |   10 +-
 drivers/net/sfc/rx.c                    |   78 ++--
 drivers/net/sfc/rx.h                    |    4 +-
 drivers/net/sfc/selftest.c              |  391 +++++++++-------
 drivers/net/sfc/selftest.h              |   13 +-
 drivers/net/sfc/sfe4001.c               |  244 ++++++----
 drivers/net/sfc/spi.h                   |   89 ++--
 drivers/net/sfc/tenxpress.c             |   90 ++---
 drivers/net/sfc/tx.c                    |  383 ++++++++--------
 drivers/net/sfc/tx.h                    |    2 +-
 drivers/net/sfc/workarounds.h           |    2 -
 drivers/net/sfc/xfp_phy.c               |   11 +-
 drivers/net/sky2.c                      |  170 +++++--
 drivers/net/tokenring/lanstreamer.c     |    1 -
 drivers/net/via-rhine.c                 |    8 +-
 59 files changed, 4084 insertions(+), 2175 deletions(-)

Alexander Duyck (3):
      igb: remove unneeded cleaned variable in clean_tx_irq path
      igb: clean up a stray fake netdev code left in rx path
      ixgbe: change config srrctl to only program one register per VMDq=
/RSS id

Ben Hutchings (38):
      sfc: Replace net_dev->priv with netdev_priv(net_dev)
      sfc: Change first parameter type of {set,clear}_bit_le() to unsig=
ned
      sfc: Use separate hardware TX queues to select checksum generatio=
n
      sfc: Avoid mangling error codes in efx_test_loopback()
      sfc: Reduce delays in SFE4001 initialisation
      sfc: Remove mistaken hardware workaround
      sfc: XMAC statistics fix-ups
      sfc: Remove inclusion of workarounds.h from efx.c
      sfc: Reverse the XOFF/XON pause frame control fifo thresholds
      sfc: Reduce log level for XGXS lane status
      sfc: Self-test reporting cleanup
      sfc: Speed up loopback self-test
      sfc: Don't leak PCI DMA maps in the TSO code when the queue fills=
 up
      sfc: Use pci_map_single() to map the skb header when doing TSO
      sfc: Reduce the size of struct efx_tx_buffer
      sfc: Use explicit bool for boolean variables, parameters and retu=
rn values
      sfc: Set net_device::vlan_features appropriately
      sfc: Cleaned up struct tso_state fields
      sfc: Removed forced inlining of long functions
      sfc: Export boot configuration in EEPROM through ethtool
      sfc: Move CPU counting for RSS into a separate function, efx_want=
ed_rx_queues()
      sfc: Remove efx_channel::has_interrupt
      sfc: Cleanup RX queue information
      sfc: Remove initialisation of RX_FILTER_CTL_REG.NUM_KER
      sfc: Make efx_for_each_channel_rx_queue() more efficient
      sfc: Remove efx_channel::evqnum field
      sfc: Cleanup RX event processing
      sfc: Implement get_sset_count, replacing get_stats_count and self=
_test_count
      sfc: Make PHY flash mode a device attribute, not a module paramet=
er
      sfc: Enable TSO for 802.1q VLAN devices
      sfc: Remove efx_nic_dummy_op_int() as redundant with efx_port_dum=
my_op_int()
      sfc: Remove remnants of multi-port abstraction for MAC registers
      sfc: Remove some unreachable error paths
      sfc: Cleanup reset code
      sfc: Rework the bitfield header so that we can identify fields by=
 bit number
      sfc: Extend self-tests
      sfc: Remove the STATE_RESETTING flag
      sfc: Rework efx_set_multicast_hash()

Brian Haley (1):
      bonding: change some __constant_htons() to htons()

Bruce Allan (3):
      e1000e: add support for the 82567LM-4 device
      e1000e: add support for 82567LM-3 and 82567LF-3 (ICH10D) parts
      e1000e: add support for new 82574L part

Christopher Leech (1):
      ixgbe: Implement HAVE_SET_RX_MODE

=46rancois Romieu (6):
      r8169: get ethtool settings through the generic mii helper
      r8169: Tx performance tweak helper
      r8169: use pci_find_capability for the PCI-E features
      r8169: add 8168/8101 registers description
      r8169: add hw start helpers for the 8168 and the 8101
      r8169: additional 8101 and 8102 support

Huang Weiyi (1):
      [netdrvr] removed unused #include <version.h>

Ilpo J=E4rvinen (1):
      s2io: reindented misleading for loop

Jesse Brandeburg (11):
      ixgbe: fix rx csum return status misinterpretation
      ixgbe: add little endian annotations for sparse
      ixgbe: do not update stats twice each receive
      ixgbe: Cleanup references to Tx and Rx rings to becommon across t=
he driver
      ixgbe: disable flow control by default
      ixgbe: Implement Tx Head Writeback
      ixgbe: Lock RSS seed, move rx_buf_len to the rx_ring
      ixgbe: should not use HW_CSUM, should use IP* flags
      ixgbe: update dca to new interface, fix CONFIG_DCA_MODULE
      ixgbe: fix bug where lro settings are per ring
      ixgbe: fix dca hints going to wrong processor

Kevin Lo (3):
      via-rhine: changed to use netdev_alloc_skb() from dev_alloc_skb
      8139cp: use netdev_alloc_skb
      8139too: use netdev_alloc_skb

PJ Waskiewicz (1):
      ixgbe: use different context for tso and offload

Randy Dunlap (1):
      hp-plus: fix link objects

Stephen Hemminger (2):
      sky2: EEPROM read/write bug fixes
      sky2: display product info on boot.

Steve Hodgson (2):
      sfc: Remove unused field efx_channel::reset_work
      sfc: Do not call netif_{stop,wake}_queue() before register_netdev

roel kluin (1):
      ibm_newemac: MAL[12]_IER_EVENTS definition: 2x *_OTE -> *_DE

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 6011d6f..85fa40a 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -127,7 +127,6 @@ MODULE_PARM_DESC (multicast_filter_limit, "8139cp: =
maximum number of filtered mu
 	  (CP)->tx_tail - (CP)->tx_head - 1)
=20
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
-#define RX_OFFSET		2
 #define CP_INTERNAL_PHY		32
=20
 /* The following settings are log_2(bytes)-4:  0 =3D=3D 16 bytes .. 6=3D=
=3D1024, 7=3D=3Dend of packet. */
@@ -552,14 +551,14 @@ rx_status_loop:
 			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d\n",
 			       dev->name, rx_tail, status, len);
=20
-		buflen =3D cp->rx_buf_sz + RX_OFFSET;
-		new_skb =3D dev_alloc_skb (buflen);
+		buflen =3D cp->rx_buf_sz + NET_IP_ALIGN;
+		new_skb =3D netdev_alloc_skb(dev, buflen);
 		if (!new_skb) {
 			dev->stats.rx_dropped++;
 			goto rx_next;
 		}
=20
-		skb_reserve(new_skb, RX_OFFSET);
+		skb_reserve(new_skb, NET_IP_ALIGN);
=20
 		dma_unmap_single(&cp->pdev->dev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
@@ -1051,19 +1050,20 @@ static void cp_init_hw (struct cp_private *cp)
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 }
=20
-static int cp_refill_rx (struct cp_private *cp)
+static int cp_refill_rx(struct cp_private *cp)
 {
+	struct net_device *dev =3D cp->dev;
 	unsigned i;
=20
 	for (i =3D 0; i < CP_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 		dma_addr_t mapping;
=20
-		skb =3D dev_alloc_skb(cp->rx_buf_sz + RX_OFFSET);
+		skb =3D netdev_alloc_skb(dev, cp->rx_buf_sz + NET_IP_ALIGN);
 		if (!skb)
 			goto err_out;
=20
-		skb_reserve(skb, RX_OFFSET);
+		skb_reserve(skb, NET_IP_ALIGN);
=20
 		mapping =3D dma_map_single(&cp->pdev->dev, skb->data,
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 8a5b0d2..f6ca997 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2009,9 +2009,9 @@ no_early_rx:
 		/* Malloc up new buffer, compatible with net-2e. */
 		/* Omit the four octet CRC from the length. */
=20
-		skb =3D dev_alloc_skb (pkt_size + 2);
+		skb =3D netdev_alloc_skb(dev, pkt_size + NET_IP_ALIGN);
 		if (likely(skb)) {
-			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
+			skb_reserve (skb, NET_IP_ALIGN);	/* 16 byte align the IP fields. */
 #if RX_BUF_IDX =3D=3D 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
 #else
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7629c90..f66b79b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -111,7 +111,7 @@ obj-$(CONFIG_EL2) +=3D 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) +=3D ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) +=3D ne2.o 8390p.o
 obj-$(CONFIG_HPLAN) +=3D hp.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) +=3D hp-plus.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) +=3D hp-plus.o 8390.o
 obj-$(CONFIG_ULTRA) +=3D smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) +=3D smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) +=3D smc-ultra32.o 8390.o
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index b211486..3d39278 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -710,7 +710,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *s=
kb, struct bonding *bond)
 	struct arp_pkt *arp =3D arp_pkt(skb);
 	struct slave *tx_slave =3D NULL;
=20
-	if (arp->op_code =3D=3D __constant_htons(ARPOP_REPLY)) {
+	if (arp->op_code =3D=3D htons(ARPOP_REPLY)) {
 		/* the arp must be sent on the selected
 		* rx channel
 		*/
@@ -719,7 +719,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *s=
kb, struct bonding *bond)
 			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
 		}
 		dprintk("Server sent ARP Reply packet\n");
-	} else if (arp->op_code =3D=3D __constant_htons(ARPOP_REQUEST)) {
+	} else if (arp->op_code =3D=3D htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
 		 * place holder.
 		 * When the arp reply is received the entry will be updated
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index c792138..babe461 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3702,7 +3702,7 @@ static int bond_xmit_hash_policy_l23(struct sk_bu=
ff *skb,
 	struct ethhdr *data =3D (struct ethhdr *)skb->data;
 	struct iphdr *iph =3D ip_hdr(skb);
=20
-	if (skb->protocol =3D=3D __constant_htons(ETH_P_IP)) {
+	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
 	}
@@ -3723,8 +3723,8 @@ static int bond_xmit_hash_policy_l34(struct sk_bu=
ff *skb,
 	__be16 *layer4hdr =3D (__be16 *)((u32 *)iph + iph->ihl);
 	int layer4_xor =3D 0;
=20
-	if (skb->protocol =3D=3D __constant_htons(ETH_P_IP)) {
-		if (!(iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) &&
+	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
+		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol =3D=3D IPPROTO_TCP ||
 		     iph->protocol =3D=3D IPPROTO_UDP)) {
 			layer4_xor =3D ntohs((*layer4hdr ^ *(layer4hdr + 1)));
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 462351c..b2c910c 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -38,6 +38,7 @@
  * 82573V Gigabit Ethernet Controller (Copper)
  * 82573E Gigabit Ethernet Controller (Copper)
  * 82573L Gigabit Ethernet Controller
+ * 82574L Gigabit Network Connection
  */
=20
 #include <linux/netdevice.h>
@@ -54,6 +55,8 @@
=20
 #define E1000_GCR_L1_ACT_WITHOUT_L0S_RX 0x08000000
=20
+#define E1000_NVM_INIT_CTRL2_MNGM 0x6000 /* Manageability Operation Mo=
de mask */
+
 static s32 e1000_get_phy_id_82571(struct e1000_hw *hw);
 static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw);
 static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw);
@@ -63,6 +66,8 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_=
hw *hw);
 static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw);
 static s32 e1000_setup_link_82571(struct e1000_hw *hw);
 static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw);
+static bool e1000_check_mng_mode_82574(struct e1000_hw *hw);
+static s32 e1000_led_on_82574(struct e1000_hw *hw);
=20
 /**
  *  e1000_init_phy_params_82571 - Init PHY func ptrs.
@@ -92,6 +97,9 @@ static s32 e1000_init_phy_params_82571(struct e1000_h=
w *hw)
 	case e1000_82573:
 		phy->type		 =3D e1000_phy_m88;
 		break;
+	case e1000_82574:
+		phy->type		 =3D e1000_phy_bm;
+		break;
 	default:
 		return -E1000_ERR_PHY;
 		break;
@@ -111,6 +119,10 @@ static s32 e1000_init_phy_params_82571(struct e100=
0_hw *hw)
 		if (phy->id !=3D M88E1111_I_PHY_ID)
 			return -E1000_ERR_PHY;
 		break;
+	case e1000_82574:
+		if (phy->id !=3D BME1000_E_PHY_ID_R2)
+			return -E1000_ERR_PHY;
+		break;
 	default:
 		return -E1000_ERR_PHY;
 		break;
@@ -150,6 +162,7 @@ static s32 e1000_init_nvm_params_82571(struct e1000=
_hw *hw)
=20
 	switch (hw->mac.type) {
 	case e1000_82573:
+	case e1000_82574:
 		if (((eecd >> 15) & 0x3) =3D=3D 0x3) {
 			nvm->type =3D e1000_nvm_flash_hw;
 			nvm->word_size =3D 2048;
@@ -245,6 +258,17 @@ static s32 e1000_init_mac_params_82571(struct e100=
0_adapter *adapter)
 		break;
 	}
=20
+	switch (hw->mac.type) {
+	case e1000_82574:
+		func->check_mng_mode =3D e1000_check_mng_mode_82574;
+		func->led_on =3D e1000_led_on_82574;
+		break;
+	default:
+		func->check_mng_mode =3D e1000e_check_mng_mode_generic;
+		func->led_on =3D e1000e_led_on_generic;
+		break;
+	}
+
 	return 0;
 }
=20
@@ -330,6 +354,8 @@ static s32 e1000_get_variants_82571(struct e1000_ad=
apter *adapter)
 static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy =3D &hw->phy;
+	s32 ret_val;
+	u16 phy_id =3D 0;
=20
 	switch (hw->mac.type) {
 	case e1000_82571:
@@ -345,6 +371,20 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw =
*hw)
 	case e1000_82573:
 		return e1000e_get_phy_id(hw);
 		break;
+	case e1000_82574:
+		ret_val =3D e1e_rphy(hw, PHY_ID1, &phy_id);
+		if (ret_val)
+			return ret_val;
+
+		phy->id =3D (u32)(phy_id << 16);
+		udelay(20);
+		ret_val =3D e1e_rphy(hw, PHY_ID2, &phy_id);
+		if (ret_val)
+			return ret_val;
+
+		phy->id |=3D (u32)(phy_id);
+		phy->revision =3D (u32)(phy_id & ~PHY_REVISION_MASK);
+		break;
 	default:
 		return -E1000_ERR_PHY;
 		break;
@@ -421,7 +461,7 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw =
*hw)
 	if (ret_val)
 		return ret_val;
=20
-	if (hw->mac.type !=3D e1000_82573)
+	if (hw->mac.type !=3D e1000_82573 && hw->mac.type !=3D e1000_82574)
 		ret_val =3D e1000e_acquire_nvm(hw);
=20
 	if (ret_val)
@@ -461,6 +501,7 @@ static s32 e1000_write_nvm_82571(struct e1000_hw *h=
w, u16 offset, u16 words,
=20
 	switch (hw->mac.type) {
 	case e1000_82573:
+	case e1000_82574:
 		ret_val =3D e1000_write_nvm_eewr_82571(hw, offset, words, data);
 		break;
 	case e1000_82571:
@@ -735,7 +776,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw=
)
 	 * Must acquire the MDIO ownership before MAC reset.
 	 * Ownership defaults to firmware after a reset.
 	 */
-	if (hw->mac.type =3D=3D e1000_82573) {
+	if (hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_8257=
4) {
 		extcnf_ctrl =3D er32(EXTCNF_CTRL);
 		extcnf_ctrl |=3D E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
=20
@@ -776,7 +817,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw=
)
 	 * Need to wait for Phy configuration completion before accessing
 	 * NVM and Phy.
 	 */
-	if (hw->mac.type =3D=3D e1000_82573)
+	if (hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_8257=
4)
 		msleep(25);
=20
 	/* Clear any pending interrupt events. */
@@ -843,7 +884,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	ew32(TXDCTL(0), reg_data);
=20
 	/* ...for both queues. */
-	if (mac->type !=3D e1000_82573) {
+	if (mac->type !=3D e1000_82573 && mac->type !=3D e1000_82574) {
 		reg_data =3D er32(TXDCTL(1));
 		reg_data =3D (reg_data & ~E1000_TXDCTL_WTHRESH) |
 			   E1000_TXDCTL_FULL_TX_DESC_WB |
@@ -918,19 +959,28 @@ static void e1000_initialize_hw_bits_82571(struct=
 e1000_hw *hw)
 	}
=20
 	/* Device Control */
-	if (hw->mac.type =3D=3D e1000_82573) {
+	if (hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_8257=
4) {
 		reg =3D er32(CTRL);
 		reg &=3D ~(1 << 29);
 		ew32(CTRL, reg);
 	}
=20
 	/* Extended Device Control */
-	if (hw->mac.type =3D=3D e1000_82573) {
+	if (hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_8257=
4) {
 		reg =3D er32(CTRL_EXT);
 		reg &=3D ~(1 << 23);
 		reg |=3D (1 << 22);
 		ew32(CTRL_EXT, reg);
 	}
+
+	/* PCI-Ex Control Register */
+	if (hw->mac.type =3D=3D e1000_82574) {
+		reg =3D er32(GCR);
+		reg |=3D (1 << 22);
+		ew32(GCR, reg);
+	}
+
+	return;
 }
=20
 /**
@@ -947,7 +997,7 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 	u32 vfta_offset =3D 0;
 	u32 vfta_bit_in_reg =3D 0;
=20
-	if (hw->mac.type =3D=3D e1000_82573) {
+	if (hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_8257=
4) {
 		if (hw->mng_cookie.vlan_id !=3D 0) {
 			/*
 			 * The VFTA is a 4096b bit-field, each identifying
@@ -976,6 +1026,48 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 }
=20
 /**
+ *  e1000_check_mng_mode_82574 - Check manageability is enabled
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the NVM Initialization Control Word 2 and returns true
+ *  (>0) if any manageability is enabled, else false (0).
+ **/
+static bool e1000_check_mng_mode_82574(struct e1000_hw *hw)
+{
+	u16 data;
+
+	e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &data);
+	return (data & E1000_NVM_INIT_CTRL2_MNGM) !=3D 0;
+}
+
+/**
+ *  e1000_led_on_82574 - Turn LED on
+ *  @hw: pointer to the HW structure
+ *
+ *  Turn LED on.
+ **/
+static s32 e1000_led_on_82574(struct e1000_hw *hw)
+{
+	u32 ctrl;
+	u32 i;
+
+	ctrl =3D hw->mac.ledctl_mode2;
+	if (!(E1000_STATUS_LU & er32(STATUS))) {
+		/*
+		 * If no link, then turn LED on by setting the invert bit
+		 * for each LED that's "on" (0x0E) in ledctl_mode2.
+		 */
+		for (i =3D 0; i < 4; i++)
+			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) =3D=3D
+			    E1000_LEDCTL_MODE_LED_ON)
+				ctrl |=3D (E1000_LEDCTL_LED0_IVRT << (i * 8));
+	}
+	ew32(LEDCTL, ctrl);
+
+	return 0;
+}
+
+/**
  *  e1000_update_mc_addr_list_82571 - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
@@ -1018,7 +1110,8 @@ static s32 e1000_setup_link_82571(struct e1000_hw=
 *hw)
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
-	if (hw->mac.type =3D=3D e1000_82573)
+	if ((hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_825=
74) &&
+	    hw->fc.type =3D=3D e1000_fc_default)
 		hw->fc.type =3D e1000_fc_full;
=20
 	return e1000e_setup_link(hw);
@@ -1045,6 +1138,7 @@ static s32 e1000_setup_copper_link_82571(struct e=
1000_hw *hw)
=20
 	switch (hw->phy.type) {
 	case e1000_phy_m88:
+	case e1000_phy_bm:
 		ret_val =3D e1000e_copper_link_setup_m88(hw);
 		break;
 	case e1000_phy_igp_2:
@@ -1114,11 +1208,10 @@ static s32 e1000_valid_led_default_82571(struct=
 e1000_hw *hw, u16 *data)
 		return ret_val;
 	}
=20
-	if (hw->mac.type =3D=3D e1000_82573 &&
+	if ((hw->mac.type =3D=3D e1000_82573 || hw->mac.type =3D=3D e1000_825=
74) &&
 	    *data =3D=3D ID_LED_RESERVED_F746)
 		*data =3D ID_LED_DEFAULT_82573;
-	else if (*data =3D=3D ID_LED_RESERVED_0000 ||
-		 *data =3D=3D ID_LED_RESERVED_FFFF)
+	else if (*data =3D=3D ID_LED_RESERVED_0000 || *data =3D=3D ID_LED_RES=
ERVED_FFFF)
 		*data =3D ID_LED_DEFAULT;
=20
 	return 0;
@@ -1265,13 +1358,13 @@ static void e1000_clear_hw_cntrs_82571(struct e=
1000_hw *hw)
 }
=20
 static struct e1000_mac_operations e82571_mac_ops =3D {
-	.mng_mode_enab		=3D E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
+	/* .check_mng_mode: mac type dependent */
 	/* .check_for_link: media type dependent */
 	.cleanup_led		=3D e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		=3D e1000_clear_hw_cntrs_82571,
 	.get_bus_info		=3D e1000e_get_bus_info_pcie,
 	/* .get_link_up_info: media type dependent */
-	.led_on			=3D e1000e_led_on_generic,
+	/* .led_on: mac type dependent */
 	.led_off		=3D e1000e_led_off_generic,
 	.update_mc_addr_list	=3D e1000_update_mc_addr_list_82571,
 	.reset_hw		=3D e1000_reset_hw_82571,
@@ -1312,6 +1405,22 @@ static struct e1000_phy_operations e82_phy_ops_m=
88 =3D {
 	.write_phy_reg		=3D e1000e_write_phy_reg_m88,
 };
=20
+static struct e1000_phy_operations e82_phy_ops_bm =3D {
+	.acquire_phy		=3D e1000_get_hw_semaphore_82571,
+	.check_reset_block	=3D e1000e_check_reset_block_generic,
+	.commit_phy		=3D e1000e_phy_sw_reset,
+	.force_speed_duplex	=3D e1000e_phy_force_speed_duplex_m88,
+	.get_cfg_done		=3D e1000e_get_cfg_done,
+	.get_cable_length	=3D e1000e_get_cable_length_m88,
+	.get_phy_info		=3D e1000e_get_phy_info_m88,
+	.read_phy_reg		=3D e1000e_read_phy_reg_bm2,
+	.release_phy		=3D e1000_put_hw_semaphore_82571,
+	.reset_phy		=3D e1000e_phy_hw_reset_generic,
+	.set_d0_lplu_state	=3D e1000_set_d0_lplu_state_82571,
+	.set_d3_lplu_state	=3D e1000e_set_d3_lplu_state,
+	.write_phy_reg		=3D e1000e_write_phy_reg_bm2,
+};
+
 static struct e1000_nvm_operations e82571_nvm_ops =3D {
 	.acquire_nvm		=3D e1000_acquire_nvm_82571,
 	.read_nvm		=3D e1000e_read_nvm_eerd,
@@ -1375,3 +1484,21 @@ struct e1000_info e1000_82573_info =3D {
 	.nvm_ops		=3D &e82571_nvm_ops,
 };
=20
+struct e1000_info e1000_82574_info =3D {
+	.mac			=3D e1000_82574,
+	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
+				  | FLAG_HAS_MSIX
+				  | FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_HAS_WOL
+				  | FLAG_APME_IN_CTRL3
+				  | FLAG_RX_CSUM_ENABLED
+				  | FLAG_HAS_SMART_POWER_DOWN
+				  | FLAG_HAS_AMT
+				  | FLAG_HAS_CTRLEXT_ON_LOAD,
+	.pba			=3D 20,
+	.get_variants		=3D e1000_get_variants_82571,
+	.mac_ops		=3D &e82571_mac_ops,
+	.phy_ops		=3D &e82_phy_ops_bm,
+	.nvm_ops		=3D &e82571_nvm_ops,
+};
+
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.=
h
index 14b0e6c..48f79ec 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -71,9 +71,11 @@
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disabl=
e */
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
+#define E1000_CTRL_EXT_EIAME          0x01000000
 #define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit =
for FW */
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowle=
dge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt ti=
mers after IMS clear */
+#define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
=20
 /* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
@@ -299,6 +301,7 @@
 #define E1000_RXCSUM_IPPCSE    0x00001000   /* IP payload checksum ena=
ble */
=20
 /* Header split receive */
+#define E1000_RFCTL_ACK_DIS             0x00001000
 #define E1000_RFCTL_EXTEN               0x00008000
 #define E1000_RFCTL_IPV6_EX_DIS         0x00010000
 #define E1000_RFCTL_NEW_IPV6_EXT_DIS    0x00020000
@@ -363,6 +366,11 @@
 #define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (=
0) */
 #define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) *=
/
 #define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, th=
e driver should claim the interrupt */
+#define E1000_ICR_RXQ0          0x00100000 /* Rx Queue 0 Interrupt */
+#define E1000_ICR_RXQ1          0x00200000 /* Rx Queue 1 Interrupt */
+#define E1000_ICR_TXQ0          0x00400000 /* Tx Queue 0 Interrupt */
+#define E1000_ICR_TXQ1          0x00800000 /* Tx Queue 1 Interrupt */
+#define E1000_ICR_OTHER         0x01000000 /* Other Interrupts */
=20
 /*
  * This defines the bits that are set in the Interrupt Mask
@@ -386,6 +394,11 @@
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* Rx sequence error *=
/
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. thresh=
old */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* Rx timer intr */
+#define E1000_IMS_RXQ0      E1000_ICR_RXQ0      /* Rx Queue 0 Interrup=
t */
+#define E1000_IMS_RXQ1      E1000_ICR_RXQ1      /* Rx Queue 1 Interrup=
t */
+#define E1000_IMS_TXQ0      E1000_ICR_TXQ0      /* Tx Queue 0 Interrup=
t */
+#define E1000_IMS_TXQ1      E1000_ICR_TXQ1      /* Tx Queue 1 Interrup=
t */
+#define E1000_IMS_OTHER     E1000_ICR_OTHER     /* Other Interrupts */
=20
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change =
*/
@@ -505,6 +518,7 @@
 #define NWAY_LPAR_ASM_DIR        0x0800 /* LP Asymmetric Pause Directi=
on bit */
=20
 /* Autoneg Expansion Register */
+#define NWAY_ER_LP_NWAY_CAPS     0x0001 /* LP has Auto Neg Capability =
*/
=20
 /* 1000BASE-T Control Register */
 #define CR_1000T_HD_CAPS         0x0100 /* Advertise 1000T HD capabili=
ty */
@@ -540,6 +554,7 @@
 #define E1000_EECD_DO        0x00000008 /* NVM Data Out */
 #define E1000_EECD_REQ       0x00000040 /* NVM Access Request */
 #define E1000_EECD_GNT       0x00000080 /* NVM Access Grant */
+#define E1000_EECD_PRES      0x00000100 /* NVM Present */
 #define E1000_EECD_SIZE      0x00000200 /* NVM Size (0=3D64 word 1=3D2=
56 word) */
 /* NVM Addressing bits based on type (0-small, 1-large) */
 #define E1000_EECD_ADDR_BITS 0x00000400
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index ac4e506..0a1916b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -62,6 +62,11 @@ struct e1000_info;
 	e_printk(KERN_NOTICE, adapter, format, ## arg)
=20
=20
+/* Interrupt modes, as used by the IntMode paramter */
+#define E1000E_INT_MODE_LEGACY		0
+#define E1000E_INT_MODE_MSI		1
+#define E1000E_INT_MODE_MSIX		2
+
 /* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
@@ -95,9 +100,11 @@ enum e1000_boards {
 	board_82571,
 	board_82572,
 	board_82573,
+	board_82574,
 	board_80003es2lan,
 	board_ich8lan,
 	board_ich9lan,
+	board_ich10lan,
 };
=20
 struct e1000_queue_stats {
@@ -146,6 +153,12 @@ struct e1000_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
=20
+	char name[IFNAMSIZ + 5];
+	u32 ims_val;
+	u32 itr_val;
+	u16 itr_register;
+	int set_itr;
+
 	struct sk_buff *rx_skb_top;
=20
 	struct e1000_queue_stats stats;
@@ -274,6 +287,9 @@ struct e1000_adapter {
 	u32 test_icr;
=20
 	u32 msg_enable;
+	struct msix_entry *msix_entries;
+	int int_mode;
+	u32 eiac_mask;
=20
 	u32 eeprom_wol;
 	u32 wol;
@@ -306,6 +322,7 @@ struct e1000_info {
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
 #define FLAG_IS_ICH                       (1 << 9)
+#define FLAG_HAS_MSIX                     (1 << 10)
 #define FLAG_HAS_SMART_POWER_DOWN         (1 << 11)
 #define FLAG_IS_QUAD_PORT_A               (1 << 12)
 #define FLAG_IS_QUAD_PORT                 (1 << 13)
@@ -364,6 +381,8 @@ extern int e1000e_setup_tx_resources(struct e1000_a=
dapter *adapter);
 extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_update_stats(struct e1000_adapter *adapter);
+extern void e1000e_set_interrupt_capability(struct e1000_adapter *adap=
ter);
+extern void e1000e_reset_interrupt_capability(struct e1000_adapter *ad=
apter);
=20
 extern unsigned int copybreak;
=20
@@ -372,8 +391,10 @@ extern char *e1000e_get_hw_dev_name(struct e1000_h=
w *hw);
 extern struct e1000_info e1000_82571_info;
 extern struct e1000_info e1000_82572_info;
 extern struct e1000_info e1000_82573_info;
+extern struct e1000_info e1000_82574_info;
 extern struct e1000_info e1000_ich8_info;
 extern struct e1000_info e1000_ich9_info;
+extern struct e1000_info e1000_ich10_info;
 extern struct e1000_info e1000_es2_info;
=20
 extern s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num);
@@ -446,10 +467,13 @@ extern s32 e1000e_get_cable_length_m88(struct e10=
00_hw *hw);
 extern s32 e1000e_get_phy_info_m88(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u1=
6 *data);
 extern s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u=
16 data);
+extern s32 e1000e_phy_init_script_igp3(struct e1000_hw *hw);
 extern enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id);
 extern s32 e1000e_determine_phy_address(struct e1000_hw *hw);
 extern s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u1=
6 data);
 extern s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16=
 *data);
+extern s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u1=
6 *data);
+extern s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u=
16 data);
 extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u=
16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 =
data);
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *=
data);
@@ -520,7 +544,12 @@ static inline s32 e1000_get_phy_info(struct e1000_=
hw *hw)
 	return hw->phy.ops.get_phy_info(hw);
 }
=20
-extern bool e1000e_check_mng_mode(struct e1000_hw *hw);
+static inline s32 e1000e_check_mng_mode(struct e1000_hw *hw)
+{
+	return hw->mac.ops.check_mng_mode(hw);
+}
+
+extern bool e1000e_check_mng_mode_generic(struct e1000_hw *hw);
 extern bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw);
 extern s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,=
 u16 length);
=20
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index dc552d7..da9c09c 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1247,7 +1247,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(stru=
ct e1000_hw *hw)
 }
=20
 static struct e1000_mac_operations es2_mac_ops =3D {
-	.mng_mode_enab		=3D E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
+	.check_mng_mode		=3D e1000e_check_mng_mode_generic,
 	/* check_for_link dependent on media type */
 	.cleanup_led		=3D e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		=3D e1000_clear_hw_cntrs_80003es2lan,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index e21c9e0..52b762e 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -568,6 +568,7 @@ static int e1000_set_eeprom(struct net_device *netd=
ev,
 	 * and flush shadow RAM for 82573 controllers
 	 */
 	if ((ret_val =3D=3D 0) && ((first_word <=3D NVM_CHECKSUM_REG) ||
+			       (hw->mac.type =3D=3D e1000_82574) ||
 			       (hw->mac.type =3D=3D e1000_82573)))
 		e1000e_update_nvm_checksum(hw);
=20
@@ -779,8 +780,10 @@ static int e1000_reg_test(struct e1000_adapter *ad=
apter, u64 *data)
 		toggle =3D 0x7FFFF3FF;
 		break;
 	case e1000_82573:
+	case e1000_82574:
 	case e1000_ich8lan:
 	case e1000_ich9lan:
+	case e1000_ich10lan:
 		toggle =3D 0x7FFFF033;
 		break;
 	default:
@@ -833,7 +836,9 @@ static int e1000_reg_test(struct e1000_adapter *ada=
pter, u64 *data)
 	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
 	for (i =3D 0; i < mac->rar_entry_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
-				       0x8003FFFF, 0xFFFFFFFF);
+				       ((mac->type =3D=3D e1000_ich10lan) ?
+					   0x8007FFFF : 0x8003FFFF),
+				       0xFFFFFFFF);
=20
 	for (i =3D 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_MTA, i, 0xFFFFFFFF, 0xFFFFFFFF);
@@ -884,10 +889,18 @@ static int e1000_intr_test(struct e1000_adapter *=
adapter, u64 *data)
 	u32 shared_int =3D 1;
 	u32 irq =3D adapter->pdev->irq;
 	int i;
+	int ret_val =3D 0;
+	int int_mode =3D E1000E_INT_MODE_LEGACY;
=20
 	*data =3D 0;
=20
-	/* NOTE: we don't test MSI interrupts here, yet */
+	/* NOTE: we don't test MSI/MSI-X interrupts here, yet */
+	if (adapter->int_mode =3D=3D E1000E_INT_MODE_MSIX) {
+		int_mode =3D adapter->int_mode;
+		e1000e_reset_interrupt_capability(adapter);
+		adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
+		e1000e_set_interrupt_capability(adapter);
+	}
 	/* Hook up test interrupt handler just for this test */
 	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->na=
me,
 			 netdev)) {
@@ -895,7 +908,8 @@ static int e1000_intr_test(struct e1000_adapter *ad=
apter, u64 *data)
 	} else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
 		 netdev->name, netdev)) {
 		*data =3D 1;
-		return -1;
+		ret_val =3D -1;
+		goto out;
 	}
 	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared")=
);
=20
@@ -905,12 +919,23 @@ static int e1000_intr_test(struct e1000_adapter *=
adapter, u64 *data)
=20
 	/* Test each interrupt */
 	for (i =3D 0; i < 10; i++) {
-		if ((adapter->flags & FLAG_IS_ICH) && (i =3D=3D 8))
-			continue;
-
 		/* Interrupt to test */
 		mask =3D 1 << i;
=20
+		if (adapter->flags & FLAG_IS_ICH) {
+			switch (mask) {
+			case E1000_ICR_RXSEQ:
+				continue;
+			case 0x00000100:
+				if (adapter->hw.mac.type =3D=3D e1000_ich8lan ||
+				    adapter->hw.mac.type =3D=3D e1000_ich9lan)
+					continue;
+				break;
+			default:
+				break;
+			}
+		}
+
 		if (!shared_int) {
 			/*
 			 * Disable the interrupt to be reported in
@@ -974,7 +999,14 @@ static int e1000_intr_test(struct e1000_adapter *a=
dapter, u64 *data)
 	/* Unhook test interrupt handler */
 	free_irq(irq, netdev);
=20
-	return *data;
+out:
+	if (int_mode =3D=3D E1000E_INT_MODE_MSIX) {
+		e1000e_reset_interrupt_capability(adapter);
+		adapter->int_mode =3D int_mode;
+		e1000e_set_interrupt_capability(adapter);
+	}
+
+	return ret_val;
 }
=20
 static void e1000_free_desc_rings(struct e1000_adapter *adapter)
@@ -1755,11 +1787,13 @@ static void e1000_led_blink_callback(unsigned l=
ong data)
 static int e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
=20
 	if (!data)
 		data =3D INT_MAX;
=20
-	if (adapter->hw.phy.type =3D=3D e1000_phy_ife) {
+	if ((hw->phy.type =3D=3D e1000_phy_ife) ||
+	    (hw->mac.type =3D=3D e1000_82574)) {
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function =3D
@@ -1769,16 +1803,16 @@ static int e1000_phys_id(struct net_device *net=
dev, u32 data)
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
 		del_timer_sync(&adapter->blink_timer);
-		e1e_wphy(&adapter->hw,
-				    IFE_PHY_SPECIAL_CONTROL_LED, 0);
+		if (hw->phy.type =3D=3D e1000_phy_ife)
+			e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
 	} else {
-		e1000e_blink_led(&adapter->hw);
+		e1000e_blink_led(hw);
 		msleep_interruptible(data * 1000);
 	}
=20
-	adapter->hw.mac.ops.led_off(&adapter->hw);
+	hw->mac.ops.led_off(hw);
 	clear_bit(E1000_LED_ON, &adapter->led_status);
-	adapter->hw.mac.ops.cleanup_led(&adapter->hw);
+	hw->mac.ops.cleanup_led(hw);
=20
 	return 0;
 }
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 74f263a..f66ed37 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -65,7 +65,11 @@ enum e1e_registers {
 	E1000_ICS      =3D 0x000C8, /* Interrupt Cause Set - WO */
 	E1000_IMS      =3D 0x000D0, /* Interrupt Mask Set - RW */
 	E1000_IMC      =3D 0x000D8, /* Interrupt Mask Clear - WO */
+	E1000_EIAC_82574 =3D 0x000DC, /* Ext. Interrupt Auto Clear - RW */
 	E1000_IAM      =3D 0x000E0, /* Interrupt Acknowledge Auto Mask */
+	E1000_IVAR     =3D 0x000E4, /* Interrupt Vector Allocation - RW */
+	E1000_EITR_82574_BASE =3D 0x000E8, /* Interrupt Throttling - RW */
+#define E1000_EITR_82574(_n) (E1000_EITR_82574_BASE + (_n << 2))
 	E1000_RCTL     =3D 0x00100, /* Rx Control - RW */
 	E1000_FCTTV    =3D 0x00170, /* Flow Control Transmit Timer Value - RW=
 */
 	E1000_TXCW     =3D 0x00178, /* Tx Configuration Word - RW */
@@ -332,6 +336,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_82573E			0x108B
 #define E1000_DEV_ID_82573E_IAMT		0x108C
 #define E1000_DEV_ID_82573L			0x109A
+#define E1000_DEV_ID_82574L			0x10D3
=20
 #define E1000_DEV_ID_80003ES2LAN_COPPER_DPT	0x1096
 #define E1000_DEV_ID_80003ES2LAN_SERDES_DPT	0x1098
@@ -346,6 +351,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH8_IFE_G			0x10C5
 #define E1000_DEV_ID_ICH8_IGP_M			0x104D
 #define E1000_DEV_ID_ICH9_IGP_AMT		0x10BD
+#define E1000_DEV_ID_ICH9_BM			0x10E5
 #define E1000_DEV_ID_ICH9_IGP_M_AMT		0x10F5
 #define E1000_DEV_ID_ICH9_IGP_M			0x10BF
 #define E1000_DEV_ID_ICH9_IGP_M_V		0x10CB
@@ -356,6 +362,10 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH10_R_BM_LM		0x10CC
 #define E1000_DEV_ID_ICH10_R_BM_LF		0x10CD
 #define E1000_DEV_ID_ICH10_R_BM_V		0x10CE
+#define E1000_DEV_ID_ICH10_D_BM_LM		0x10DE
+#define E1000_DEV_ID_ICH10_D_BM_LF		0x10DF
+
+#define E1000_REVISION_4 4
=20
 #define E1000_FUNC_1 1
=20
@@ -363,9 +373,11 @@ enum e1000_mac_type {
 	e1000_82571,
 	e1000_82572,
 	e1000_82573,
+	e1000_82574,
 	e1000_80003es2lan,
 	e1000_ich8lan,
 	e1000_ich9lan,
+	e1000_ich10lan,
 };
=20
 enum e1000_media_type {
@@ -696,8 +708,7 @@ struct e1000_host_mng_command_info {
=20
 /* Function pointers and static data for the MAC. */
 struct e1000_mac_operations {
-	u32			mng_mode_enab;
-
+	bool (*check_mng_mode)(struct e1000_hw *);
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*cleanup_led)(struct e1000_hw *);
 	void (*clear_hw_cntrs)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.=
c
index 9e38452..019b9c0 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -43,7 +43,9 @@
  * 82567LM-2 Gigabit Network Connection
  * 82567LF-2 Gigabit Network Connection
  * 82567V-2 Gigabit Network Connection
- * 82562GT-3 10/100 Network Connection
+ * 82567LF-3 Gigabit Network Connection
+ * 82567LM-3 Gigabit Network Connection
+ * 82567LM-4 Gigabit Network Connection
  */
=20
 #include <linux/netdevice.h>
@@ -157,12 +159,15 @@ static s32 e1000_check_polarity_ife_ich8lan(struc=
t e1000_hw *hw);
 static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 ban=
k);
 static s32 e1000_retry_write_flash_byte_ich8lan(struct e1000_hw *hw,
 						u32 offset, u8 byte);
+static s32 e1000_read_flash_byte_ich8lan(struct e1000_hw *hw, u32 offs=
et,
+					 u8 *data);
 static s32 e1000_read_flash_word_ich8lan(struct e1000_hw *hw, u32 offs=
et,
 					 u16 *data);
 static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offs=
et,
 					 u8 size, u16 *data);
 static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw);
 static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw=
);
+static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw);
=20
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -417,6 +422,22 @@ static void e1000_release_swflag_ich8lan(struct e1=
000_hw *hw)
 }
=20
 /**
+ *  e1000_check_mng_mode_ich8lan - Checks management mode
+ *  @hw: pointer to the HW structure
+ *
+ *  This checks if the adapter has manageability enabled.
+ *  This is a function pointer entry point only called by read/write
+ *  routines for the PHY and NVM parts.
+ **/
+static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw)
+{
+	u32 fwsm =3D er32(FWSM);
+
+	return (fwsm & E1000_FWSM_MODE_MASK) =3D=3D
+		(E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
+}
+
+/**
  *  e1000_check_reset_block_ich8lan - Check if PHY reset is blocked
  *  @hw: pointer to the HW structure
  *
@@ -897,6 +918,56 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct =
e1000_hw *hw, bool active)
 }
=20
 /**
+ *  e1000_valid_nvm_bank_detect_ich8lan - finds out the valid bank 0 o=
r 1
+ *  @hw: pointer to the HW structure
+ *  @bank:  pointer to the variable that returns the active bank
+ *
+ *  Reads signature byte from the NVM using the flash access registers=
=2E
+ **/
+static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u3=
2 *bank)
+{
+	struct e1000_nvm_info *nvm =3D &hw->nvm;
+	/* flash bank size is in words */
+	u32 bank1_offset =3D nvm->flash_bank_size * sizeof(u16);
+	u32 act_offset =3D E1000_ICH_NVM_SIG_WORD * 2 + 1;
+	u8 bank_high_byte =3D 0;
+
+	if (hw->mac.type !=3D e1000_ich10lan) {
+		if (er32(EECD) & E1000_EECD_SEC1VAL)
+			*bank =3D 1;
+		else
+			*bank =3D 0;
+	} else {
+		/*
+		 * Make sure the signature for bank 0 is valid,
+		 * if not check for bank1
+		 */
+		e1000_read_flash_byte_ich8lan(hw, act_offset, &bank_high_byte);
+		if ((bank_high_byte & 0xC0) =3D=3D 0x80) {
+			*bank =3D 0;
+		} else {
+			/*
+			 * find if segment 1 is valid by verifying
+			 * bit 15:14 =3D 10b in word 0x13
+			 */
+			e1000_read_flash_byte_ich8lan(hw,
+						      act_offset + bank1_offset,
+						      &bank_high_byte);
+
+			/* bank1 has a valid signature equivalent to SEC1V */
+			if ((bank_high_byte & 0xC0) =3D=3D 0x80) {
+				*bank =3D 1;
+			} else {
+				hw_dbg(hw, "ERROR: EEPROM not present\n");
+				return -E1000_ERR_NVM;
+			}
+		}
+	}
+
+	return 0;
+}
+
+/**
  *  e1000_read_nvm_ich8lan - Read word(s) from the NVM
  *  @hw: pointer to the HW structure
  *  @offset: The offset (in bytes) of the word(s) to read.
@@ -912,6 +983,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *=
hw, u16 offset, u16 words,
 	struct e1000_dev_spec_ich8lan *dev_spec =3D &hw->dev_spec.ich8lan;
 	u32 act_offset;
 	s32 ret_val;
+	u32 bank =3D 0;
 	u16 i, word;
=20
 	if ((offset >=3D nvm->word_size) || (words > nvm->word_size - offset)=
 ||
@@ -924,10 +996,11 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw=
 *hw, u16 offset, u16 words,
 	if (ret_val)
 		return ret_val;
=20
-	/* Start with the bank offset, then add the relative offset. */
-	act_offset =3D (er32(EECD) & E1000_EECD_SEC1VAL)
-		     ? nvm->flash_bank_size
-		     : 0;
+	ret_val =3D e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
+	if (ret_val)
+		return ret_val;
+
+	act_offset =3D (bank) ? nvm->flash_bank_size : 0;
 	act_offset +=3D offset;
=20
 	for (i =3D 0; i < words; i++) {
@@ -1075,6 +1148,29 @@ static s32 e1000_read_flash_word_ich8lan(struct =
e1000_hw *hw, u32 offset,
 }
=20
 /**
+ *  e1000_read_flash_byte_ich8lan - Read byte from flash
+ *  @hw: pointer to the HW structure
+ *  @offset: The offset of the byte to read.
+ *  @data: Pointer to a byte to store the value read.
+ *
+ *  Reads a single byte from the NVM using the flash access registers.
+ **/
+static s32 e1000_read_flash_byte_ich8lan(struct e1000_hw *hw, u32 offs=
et,
+					 u8 *data)
+{
+	s32 ret_val;
+	u16 word =3D 0;
+
+	ret_val =3D e1000_read_flash_data_ich8lan(hw, offset, 1, &word);
+	if (ret_val)
+		return ret_val;
+
+	*data =3D (u8)word;
+
+	return 0;
+}
+
+/**
  *  e1000_read_flash_data_ich8lan - Read byte or word from NVM
  *  @hw: pointer to the HW structure
  *  @offset: The offset (in bytes) of the byte or word to read.
@@ -1205,7 +1301,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(stru=
ct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm =3D &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec =3D &hw->dev_spec.ich8lan;
-	u32 i, act_offset, new_bank_offset, old_bank_offset;
+	u32 i, act_offset, new_bank_offset, old_bank_offset, bank;
 	s32 ret_val;
 	u16 data;
=20
@@ -1225,7 +1321,11 @@ static s32 e1000_update_nvm_checksum_ich8lan(str=
uct e1000_hw *hw)
 	 * write to bank 0 etc.  We also need to erase the segment that
 	 * is going to be written
 	 */
-	if (!(er32(EECD) & E1000_EECD_SEC1VAL)) {
+	ret_val =3D  e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
+	if (ret_val)
+		return ret_val;
+
+	if (bank =3D=3D 0) {
 		new_bank_offset =3D nvm->flash_bank_size;
 		old_bank_offset =3D 0;
 		e1000_erase_flash_bank_ich8lan(hw, 1);
@@ -2189,13 +2289,14 @@ void e1000e_gig_downshift_workaround_ich8lan(st=
ruct e1000_hw *hw)
  *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
  *  to a lower speed.
  *
- *  Should only be called for ICH9 devices.
+ *  Should only be called for ICH9 and ICH10 devices.
  **/
 void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 {
 	u32 phy_ctrl;
=20
-	if (hw->mac.type =3D=3D e1000_ich9lan) {
+	if ((hw->mac.type =3D=3D e1000_ich10lan) ||
+	    (hw->mac.type =3D=3D e1000_ich9lan)) {
 		phy_ctrl =3D er32(PHY_CTRL);
 		phy_ctrl |=3D E1000_PHY_CTRL_D0A_LPLU |
 		            E1000_PHY_CTRL_GBE_DISABLE;
@@ -2253,6 +2354,39 @@ static s32 e1000_led_off_ich8lan(struct e1000_hw=
 *hw)
 }
=20
 /**
+ *  e1000_get_cfg_done_ich8lan - Read config done bit
+ *  @hw: pointer to the HW structure
+ *
+ *  Read the management control register for the config done bit for
+ *  completion status.  NOTE: silicon which is EEPROM-less will fail t=
rying
+ *  to read the config done bit, so an error is *ONLY* logged and retu=
rns
+ *  E1000_SUCCESS.  If we were to return with error, EEPROM-less silic=
on
+ *  would not be able to be reset or change link.
+ **/
+static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
+{
+	u32 bank =3D 0;
+
+	e1000e_get_cfg_done(hw);
+
+	/* If EEPROM is not marked present, init the IGP 3 PHY manually */
+	if (hw->mac.type !=3D e1000_ich10lan) {
+		if (((er32(EECD) & E1000_EECD_PRES) =3D=3D 0) &&
+		    (hw->phy.type =3D=3D e1000_phy_igp_3)) {
+			e1000e_phy_init_script_igp3(hw);
+		}
+	} else {
+		if (e1000_valid_nvm_bank_detect_ich8lan(hw, &bank)) {
+			/* Maybe we should do a basic PHY config */
+			hw_dbg(hw, "EEPROM not present\n");
+			return -E1000_ERR_CONFIG;
+		}
+	}
+
+	return 0;
+}
+
+/**
  *  e1000_clear_hw_cntrs_ich8lan - Clear statistical counters
  *  @hw: pointer to the HW structure
  *
@@ -2282,7 +2416,7 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e=
1000_hw *hw)
 }
=20
 static struct e1000_mac_operations ich8_mac_ops =3D {
-	.mng_mode_enab		=3D E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
+	.check_mng_mode		=3D e1000_check_mng_mode_ich8lan,
 	.check_for_link		=3D e1000e_check_for_copper_link,
 	.cleanup_led		=3D e1000_cleanup_led_ich8lan,
 	.clear_hw_cntrs		=3D e1000_clear_hw_cntrs_ich8lan,
@@ -2302,7 +2436,7 @@ static struct e1000_phy_operations ich8_phy_ops =3D=
 {
 	.check_reset_block	=3D e1000_check_reset_block_ich8lan,
 	.commit_phy		=3D NULL,
 	.force_speed_duplex	=3D e1000_phy_force_speed_duplex_ich8lan,
-	.get_cfg_done		=3D e1000e_get_cfg_done,
+	.get_cfg_done		=3D e1000_get_cfg_done_ich8lan,
 	.get_cable_length	=3D e1000e_get_cable_length_igp_2,
 	.get_phy_info		=3D e1000_get_phy_info_ich8lan,
 	.read_phy_reg		=3D e1000e_read_phy_reg_igp,
@@ -2357,3 +2491,20 @@ struct e1000_info e1000_ich9_info =3D {
 	.nvm_ops		=3D &ich8_nvm_ops,
 };
=20
+struct e1000_info e1000_ich10_info =3D {
+	.mac			=3D e1000_ich10lan,
+	.flags			=3D FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_IS_ICH
+				  | FLAG_HAS_WOL
+				  | FLAG_RX_CSUM_ENABLED
+				  | FLAG_HAS_CTRLEXT_ON_LOAD
+				  | FLAG_HAS_AMT
+				  | FLAG_HAS_ERT
+				  | FLAG_HAS_FLASH
+				  | FLAG_APME_IN_WUC,
+	.pba			=3D 10,
+	.get_variants		=3D e1000_get_variants_ich8lan,
+	.mac_ops		=3D &ich8_mac_ops,
+	.phy_ops		=3D &ich8_phy_ops,
+	.nvm_ops		=3D &ich8_nvm_ops,
+};
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index f1f4e9d..c733730 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2222,17 +2222,18 @@ static s32 e1000_mng_enable_host_if(struct e100=
0_hw *hw)
 }
=20
 /**
- *  e1000e_check_mng_mode - check management mode
+ *  e1000e_check_mng_mode_generic - check management mode
  *  @hw: pointer to the HW structure
  *
  *  Reads the firmware semaphore register and returns true (>0) if
  *  manageability is enabled, else false (0).
  **/
-bool e1000e_check_mng_mode(struct e1000_hw *hw)
+bool e1000e_check_mng_mode_generic(struct e1000_hw *hw)
 {
 	u32 fwsm =3D er32(FWSM);
=20
-	return (fwsm & E1000_FWSM_MODE_MASK) =3D=3D hw->mac.ops.mng_mode_enab=
;
+	return (fwsm & E1000_FWSM_MODE_MASK) =3D=3D
+		(E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
 }
=20
 /**
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..0925204 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -55,9 +55,11 @@ static const struct e1000_info *e1000_info_tbl[] =3D=
 {
 	[board_82571]		=3D &e1000_82571_info,
 	[board_82572]		=3D &e1000_82572_info,
 	[board_82573]		=3D &e1000_82573_info,
+	[board_82574]		=3D &e1000_82574_info,
 	[board_80003es2lan]	=3D &e1000_es2_info,
 	[board_ich8lan]		=3D &e1000_ich8_info,
 	[board_ich9lan]		=3D &e1000_ich9_info,
+	[board_ich10lan]	=3D &e1000_ich10_info,
 };
=20
 #ifdef DEBUG
@@ -1179,8 +1181,8 @@ static irqreturn_t e1000_intr(int irq, void *data=
)
 	struct net_device *netdev =3D data;
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
-
 	u32 rctl, icr =3D er32(ICR);
+
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
=20
@@ -1236,6 +1238,263 @@ static irqreturn_t e1000_intr(int irq, void *da=
ta)
 	return IRQ_HANDLED;
 }
=20
+static irqreturn_t e1000_msix_other(int irq, void *data)
+{
+	struct net_device *netdev =3D data;
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	u32 icr =3D er32(ICR);
+
+	if (!(icr & E1000_ICR_INT_ASSERTED)) {
+		ew32(IMS, E1000_IMS_OTHER);
+		return IRQ_NONE;
+	}
+
+	if (icr & adapter->eiac_mask)
+		ew32(ICS, (icr & adapter->eiac_mask));
+
+	if (icr & E1000_ICR_OTHER) {
+		if (!(icr & E1000_ICR_LSC))
+			goto no_link_interrupt;
+		hw->mac.get_link_status =3D 1;
+		/* guard against interrupt when we're going down */
+		if (!test_bit(__E1000_DOWN, &adapter->state))
+			mod_timer(&adapter->watchdog_timer, jiffies + 1);
+	}
+
+no_link_interrupt:
+	ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
+
+	return IRQ_HANDLED;
+}
+
+
+static irqreturn_t e1000_intr_msix_tx(int irq, void *data)
+{
+	struct net_device *netdev =3D data;
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	struct e1000_ring *tx_ring =3D adapter->tx_ring;
+
+
+	adapter->total_tx_bytes =3D 0;
+	adapter->total_tx_packets =3D 0;
+
+	if (!e1000_clean_tx_irq(adapter))
+		/* Ring was not completely cleaned, so fire another interrupt */
+		ew32(ICS, tx_ring->ims_val);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t e1000_intr_msix_rx(int irq, void *data)
+{
+	struct net_device *netdev =3D data;
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+
+	/* Write the ITR value calculated at the end of the
+	 * previous interrupt.
+	 */
+	if (adapter->rx_ring->set_itr) {
+		writel(1000000000 / (adapter->rx_ring->itr_val * 256),
+		       adapter->hw.hw_addr + adapter->rx_ring->itr_register);
+		adapter->rx_ring->set_itr =3D 0;
+	}
+
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+		adapter->total_rx_bytes =3D 0;
+		adapter->total_rx_packets =3D 0;
+		__netif_rx_schedule(netdev, &adapter->napi);
+	}
+	return IRQ_HANDLED;
+}
+
+/**
+ * e1000_configure_msix - Configure MSI-X hardware
+ *
+ * e1000_configure_msix sets up the hardware to properly
+ * generate MSI-X interrupts.
+ **/
+static void e1000_configure_msix(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw =3D &adapter->hw;
+	struct e1000_ring *rx_ring =3D adapter->rx_ring;
+	struct e1000_ring *tx_ring =3D adapter->tx_ring;
+	int vector =3D 0;
+	u32 ctrl_ext, ivar =3D 0;
+
+	adapter->eiac_mask =3D 0;
+
+	/* Workaround issue with spurious interrupts on 82574 in MSI-X mode *=
/
+	if (hw->mac.type =3D=3D e1000_82574) {
+		u32 rfctl =3D er32(RFCTL);
+		rfctl |=3D E1000_RFCTL_ACK_DIS;
+		ew32(RFCTL, rfctl);
+	}
+
+#define E1000_IVAR_INT_ALLOC_VALID	0x8
+	/* Configure Rx vector */
+	rx_ring->ims_val =3D E1000_IMS_RXQ0;
+	adapter->eiac_mask |=3D rx_ring->ims_val;
+	if (rx_ring->itr_val)
+		writel(1000000000 / (rx_ring->itr_val * 256),
+		       hw->hw_addr + rx_ring->itr_register);
+	else
+		writel(1, hw->hw_addr + rx_ring->itr_register);
+	ivar =3D E1000_IVAR_INT_ALLOC_VALID | vector;
+
+	/* Configure Tx vector */
+	tx_ring->ims_val =3D E1000_IMS_TXQ0;
+	vector++;
+	if (tx_ring->itr_val)
+		writel(1000000000 / (tx_ring->itr_val * 256),
+		       hw->hw_addr + tx_ring->itr_register);
+	else
+		writel(1, hw->hw_addr + tx_ring->itr_register);
+	adapter->eiac_mask |=3D tx_ring->ims_val;
+	ivar |=3D ((E1000_IVAR_INT_ALLOC_VALID | vector) << 8);
+
+	/* set vector for Other Causes, e.g. link changes */
+	vector++;
+	ivar |=3D ((E1000_IVAR_INT_ALLOC_VALID | vector) << 16);
+	if (rx_ring->itr_val)
+		writel(1000000000 / (rx_ring->itr_val * 256),
+		       hw->hw_addr + E1000_EITR_82574(vector));
+	else
+		writel(1, hw->hw_addr + E1000_EITR_82574(vector));
+
+	/* Cause Tx interrupts on every write back */
+	ivar |=3D (1 << 31);
+
+	ew32(IVAR, ivar);
+
+	/* enable MSI-X PBA support */
+	ctrl_ext =3D er32(CTRL_EXT);
+	ctrl_ext |=3D E1000_CTRL_EXT_PBA_CLR;
+
+	/* Auto-Mask Other interrupts upon ICR read */
+#define E1000_EIAC_MASK_82574   0x01F00000
+	ew32(IAM, ~E1000_EIAC_MASK_82574 | E1000_IMS_OTHER);
+	ctrl_ext |=3D E1000_CTRL_EXT_EIAME;
+	ew32(CTRL_EXT, ctrl_ext);
+	e1e_flush();
+}
+
+void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter)
+{
+	if (adapter->msix_entries) {
+		pci_disable_msix(adapter->pdev);
+		kfree(adapter->msix_entries);
+		adapter->msix_entries =3D NULL;
+	} else if (adapter->flags & FLAG_MSI_ENABLED) {
+		pci_disable_msi(adapter->pdev);
+		adapter->flags &=3D ~FLAG_MSI_ENABLED;
+	}
+
+	return;
+}
+
+/**
+ * e1000e_set_interrupt_capability - set MSI or MSI-X if supported
+ *
+ * Attempt to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
+void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
+{
+	int err;
+	int numvecs, i;
+
+
+	switch (adapter->int_mode) {
+	case E1000E_INT_MODE_MSIX:
+		if (adapter->flags & FLAG_HAS_MSIX) {
+			numvecs =3D 3; /* RxQ0, TxQ0 and other */
+			adapter->msix_entries =3D kcalloc(numvecs,
+						      sizeof(struct msix_entry),
+						      GFP_KERNEL);
+			if (adapter->msix_entries) {
+				for (i =3D 0; i < numvecs; i++)
+					adapter->msix_entries[i].entry =3D i;
+
+				err =3D pci_enable_msix(adapter->pdev,
+						      adapter->msix_entries,
+						      numvecs);
+				if (err =3D=3D 0)
+					return;
+			}
+			/* MSI-X failed, so fall through and try MSI */
+			e_err("Failed to initialize MSI-X interrupts.  "
+			      "Falling back to MSI interrupts.\n");
+			e1000e_reset_interrupt_capability(adapter);
+		}
+		adapter->int_mode =3D E1000E_INT_MODE_MSI;
+		/* Fall through */
+	case E1000E_INT_MODE_MSI:
+		if (!pci_enable_msi(adapter->pdev)) {
+			adapter->flags |=3D FLAG_MSI_ENABLED;
+		} else {
+			adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
+			e_err("Failed to initialize MSI interrupts.  Falling "
+			      "back to legacy interrupts.\n");
+		}
+		/* Fall through */
+	case E1000E_INT_MODE_LEGACY:
+		/* Don't do anything; this is the system default */
+		break;
+	}
+
+	return;
+}
+
+/**
+ * e1000_request_msix - Initialize MSI-X interrupts
+ *
+ * e1000_request_msix allocates MSI-X vectors and requests interrupts =
from the
+ * kernel.
+ **/
+static int e1000_request_msix(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev =3D adapter->netdev;
+	int err =3D 0, vector =3D 0;
+
+	if (strlen(netdev->name) < (IFNAMSIZ - 5))
+		sprintf(adapter->rx_ring->name, "%s-rx0", netdev->name);
+	else
+		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
+	err =3D request_irq(adapter->msix_entries[vector].vector,
+			  &e1000_intr_msix_rx, 0, adapter->rx_ring->name,
+			  netdev);
+	if (err)
+		goto out;
+	adapter->rx_ring->itr_register =3D E1000_EITR_82574(vector);
+	adapter->rx_ring->itr_val =3D adapter->itr;
+	vector++;
+
+	if (strlen(netdev->name) < (IFNAMSIZ - 5))
+		sprintf(adapter->tx_ring->name, "%s-tx0", netdev->name);
+	else
+		memcpy(adapter->tx_ring->name, netdev->name, IFNAMSIZ);
+	err =3D request_irq(adapter->msix_entries[vector].vector,
+			  &e1000_intr_msix_tx, 0, adapter->tx_ring->name,
+			  netdev);
+	if (err)
+		goto out;
+	adapter->tx_ring->itr_register =3D E1000_EITR_82574(vector);
+	adapter->tx_ring->itr_val =3D adapter->itr;
+	vector++;
+
+	err =3D request_irq(adapter->msix_entries[vector].vector,
+			  &e1000_msix_other, 0, netdev->name, netdev);
+	if (err)
+		goto out;
+
+	e1000_configure_msix(adapter);
+	return 0;
+out:
+	return err;
+}
+
 /**
  * e1000_request_irq - initialize interrupts
  *
@@ -1245,28 +1504,32 @@ static irqreturn_t e1000_intr(int irq, void *da=
ta)
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev =3D adapter->netdev;
-	int irq_flags =3D IRQF_SHARED;
 	int err;
=20
-	if (!(adapter->flags & FLAG_MSI_TEST_FAILED)) {
-		err =3D pci_enable_msi(adapter->pdev);
-		if (!err) {
-			adapter->flags |=3D FLAG_MSI_ENABLED;
-			irq_flags =3D 0;
-		}
+	if (adapter->msix_entries) {
+		err =3D e1000_request_msix(adapter);
+		if (!err)
+			return err;
+		/* fall back to MSI */
+		e1000e_reset_interrupt_capability(adapter);
+		adapter->int_mode =3D E1000E_INT_MODE_MSI;
+		e1000e_set_interrupt_capability(adapter);
+	}
+	if (adapter->flags & FLAG_MSI_ENABLED) {
+		err =3D request_irq(adapter->pdev->irq, &e1000_intr_msi, 0,
+				  netdev->name, netdev);
+		if (!err)
+			return err;
+
+		/* fall back to legacy interrupt */
+		e1000e_reset_interrupt_capability(adapter);
+		adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
 	}
=20
-	err =3D request_irq(adapter->pdev->irq,
-			  ((adapter->flags & FLAG_MSI_ENABLED) ?
-				&e1000_intr_msi : &e1000_intr),
-			  irq_flags, netdev->name, netdev);
-	if (err) {
-		if (adapter->flags & FLAG_MSI_ENABLED) {
-			pci_disable_msi(adapter->pdev);
-			adapter->flags &=3D ~FLAG_MSI_ENABLED;
-		}
+	err =3D request_irq(adapter->pdev->irq, &e1000_intr, IRQF_SHARED,
+			  netdev->name, netdev);
+	if (err)
 		e_err("Unable to allocate interrupt, Error: %d\n", err);
-	}
=20
 	return err;
 }
@@ -1275,11 +1538,21 @@ static void e1000_free_irq(struct e1000_adapter=
 *adapter)
 {
 	struct net_device *netdev =3D adapter->netdev;
=20
-	free_irq(adapter->pdev->irq, netdev);
-	if (adapter->flags & FLAG_MSI_ENABLED) {
-		pci_disable_msi(adapter->pdev);
-		adapter->flags &=3D ~FLAG_MSI_ENABLED;
+	if (adapter->msix_entries) {
+		int vector =3D 0;
+
+		free_irq(adapter->msix_entries[vector].vector, netdev);
+		vector++;
+
+		free_irq(adapter->msix_entries[vector].vector, netdev);
+		vector++;
+
+		/* Other Causes interrupt vector */
+		free_irq(adapter->msix_entries[vector].vector, netdev);
+		return;
 	}
+
+	free_irq(adapter->pdev->irq, netdev);
 }
=20
 /**
@@ -1290,6 +1563,8 @@ static void e1000_irq_disable(struct e1000_adapte=
r *adapter)
 	struct e1000_hw *hw =3D &adapter->hw;
=20
 	ew32(IMC, ~0);
+	if (adapter->msix_entries)
+		ew32(EIAC_82574, 0);
 	e1e_flush();
 	synchronize_irq(adapter->pdev->irq);
 }
@@ -1301,7 +1576,12 @@ static void e1000_irq_enable(struct e1000_adapte=
r *adapter)
 {
 	struct e1000_hw *hw =3D &adapter->hw;
=20
-	ew32(IMS, IMS_ENABLE_MASK);
+	if (adapter->msix_entries) {
+		ew32(EIAC_82574, adapter->eiac_mask & E1000_EIAC_MASK_82574);
+		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER | E1000_IMS_LSC);
+	} else {
+		ew32(IMS, IMS_ENABLE_MASK);
+	}
 	e1e_flush();
 }
=20
@@ -1551,9 +1831,8 @@ void e1000e_free_rx_resources(struct e1000_adapte=
r *adapter)
  *      traffic pattern.  Constants in this function were computed
  *      based on theoretical maximum wire speed and thresholds were se=
t based
  *      on testing data as well as attempting to minimize response tim=
e
- *      while increasing bulk throughput.
- *      this functionality is controlled by the InterruptThrottleRate =
module
- *      parameter (see e1000_param.c)
+ *      while increasing bulk throughput.  This functionality is contr=
olled
+ *      by the InterruptThrottleRate module parameter.
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 				     u16 itr_setting, int packets,
@@ -1661,11 +1940,37 @@ set_itr_now:
 			     min(adapter->itr + (new_itr >> 2), new_itr) :
 			     new_itr;
 		adapter->itr =3D new_itr;
-		ew32(ITR, 1000000000 / (new_itr * 256));
+		adapter->rx_ring->itr_val =3D new_itr;
+		if (adapter->msix_entries)
+			adapter->rx_ring->set_itr =3D 1;
+		else
+			ew32(ITR, 1000000000 / (new_itr * 256));
 	}
 }
=20
 /**
+ * e1000_alloc_queues - Allocate memory for all rings
+ * @adapter: board private structure to initialize
+ **/
+static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
+{
+	adapter->tx_ring =3D kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	if (!adapter->tx_ring)
+		goto err;
+
+	adapter->rx_ring =3D kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	if (!adapter->rx_ring)
+		goto err;
+
+	return 0;
+err:
+	e_err("Unable to allocate memory for queues\n");
+	kfree(adapter->rx_ring);
+	kfree(adapter->tx_ring);
+	return -ENOMEM;
+}
+
+/**
  * e1000_clean - NAPI Rx polling callback
  * @napi: struct associated with this polling callback
  * @budget: amount of packets driver is allowed to process this poll
@@ -1673,12 +1978,17 @@ set_itr_now:
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter =3D container_of(napi, struct e1000_ada=
pter, napi);
+	struct e1000_hw *hw =3D &adapter->hw;
 	struct net_device *poll_dev =3D adapter->netdev;
 	int tx_cleaned =3D 0, work_done =3D 0;
=20
 	/* Must NOT use netdev_priv macro here. */
 	adapter =3D poll_dev->priv;
=20
+	if (adapter->msix_entries &&
+	    !(adapter->rx_ring->ims_val & adapter->tx_ring->ims_val))
+		goto clean_rx;
+
 	/*
 	 * e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring from being cleaned by multiple cpus
@@ -1690,6 +2000,7 @@ static int e1000_clean(struct napi_struct *napi, =
int budget)
 		spin_unlock(&adapter->tx_queue_lock);
 	}
=20
+clean_rx:
 	adapter->clean_rx(adapter, &work_done, budget);
=20
 	if (tx_cleaned)
@@ -1700,7 +2011,10 @@ static int e1000_clean(struct napi_struct *napi,=
 int budget)
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
-		e1000_irq_enable(adapter);
+		if (adapter->msix_entries)
+			ew32(IMS, adapter->rx_ring->ims_val);
+		else
+			e1000_irq_enable(adapter);
 	}
=20
 	return work_done;
@@ -2496,6 +2810,8 @@ int e1000e_up(struct e1000_adapter *adapter)
 	clear_bit(__E1000_DOWN, &adapter->state);
=20
 	napi_enable(&adapter->napi);
+	if (adapter->msix_entries)
+		e1000_configure_msix(adapter);
 	e1000_irq_enable(adapter);
=20
 	/* fire a link change interrupt to start the watchdog */
@@ -2579,13 +2895,10 @@ static int __devinit e1000_sw_init(struct e1000=
_adapter *adapter)
 	adapter->max_frame_size =3D netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size =3D ETH_ZLEN + ETH_FCS_LEN;
=20
-	adapter->tx_ring =3D kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
-	if (!adapter->tx_ring)
-		goto err;
+	e1000e_set_interrupt_capability(adapter);
=20
-	adapter->rx_ring =3D kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
-	if (!adapter->rx_ring)
-		goto err;
+	if (e1000_alloc_queues(adapter))
+		return -ENOMEM;
=20
 	spin_lock_init(&adapter->tx_queue_lock);
=20
@@ -2596,12 +2909,6 @@ static int __devinit e1000_sw_init(struct e1000_=
adapter *adapter)
=20
 	set_bit(__E1000_DOWN, &adapter->state);
 	return 0;
-
-err:
-	e_err("Unable to allocate memory for queues\n");
-	kfree(adapter->rx_ring);
-	kfree(adapter->tx_ring);
-	return -ENOMEM;
 }
=20
 /**
@@ -2643,6 +2950,7 @@ static int e1000_test_msi_interrupt(struct e1000_=
adapter *adapter)
=20
 	/* free the real vector and request a test handler */
 	e1000_free_irq(adapter);
+	e1000e_reset_interrupt_capability(adapter);
=20
 	/* Assume that the test fails, if it succeeds then the test
 	 * MSI irq handler will unset this flag */
@@ -2673,6 +2981,7 @@ static int e1000_test_msi_interrupt(struct e1000_=
adapter *adapter)
 	rmb();
=20
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
+		adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
 		err =3D -EIO;
 		e_info("MSI interrupt test failed!\n");
 	}
@@ -2686,7 +2995,7 @@ static int e1000_test_msi_interrupt(struct e1000_=
adapter *adapter)
 	/* okay so the test worked, restore settings */
 	e_dbg("%s: MSI interrupt test succeeded!\n", netdev->name);
 msi_test_failed:
-	/* restore the original vector, even if it failed */
+	e1000e_set_interrupt_capability(adapter);
 	e1000_request_irq(adapter);
 	return err;
 }
@@ -2796,7 +3105,7 @@ static int e1000_open(struct net_device *netdev)
 	 * ignore e1000e MSI messages, which means we need to test our MSI
 	 * interrupt now
 	 */
-	{
+	if (adapter->int_mode !=3D E1000E_INT_MODE_LEGACY) {
 		err =3D e1000_test_msi(adapter);
 		if (err) {
 			e_err("Interrupt allocation failed\n");
@@ -2988,7 +3297,8 @@ void e1000e_update_stats(struct e1000_adapter *ad=
apter)
=20
 	adapter->stats.algnerrc +=3D er32(ALGNERRC);
 	adapter->stats.rxerrc +=3D er32(RXERRC);
-	adapter->stats.tncrs +=3D er32(TNCRS);
+	if (hw->mac.type !=3D e1000_82574)
+		adapter->stats.tncrs +=3D er32(TNCRS);
 	adapter->stats.cexterr +=3D er32(CEXTERR);
 	adapter->stats.tsctc +=3D er32(TSCTC);
 	adapter->stats.tsctfc +=3D er32(TSCTFC);
@@ -3201,6 +3511,27 @@ static void e1000_watchdog_task(struct work_stru=
ct *work)
 						   &adapter->link_duplex);
 			e1000_print_link_info(adapter);
 			/*
+			 * On supported PHYs, check for duplex mismatch only
+			 * if link has autonegotiated at 10/100 half
+			 */
+			if ((hw->phy.type =3D=3D e1000_phy_igp_3 ||
+			     hw->phy.type =3D=3D e1000_phy_bm) &&
+			    (hw->mac.autoneg =3D=3D true) &&
+			    (adapter->link_speed =3D=3D SPEED_10 ||
+			     adapter->link_speed =3D=3D SPEED_100) &&
+			    (adapter->link_duplex =3D=3D HALF_DUPLEX)) {
+				u16 autoneg_exp;
+
+				e1e_rphy(hw, PHY_AUTONEG_EXP, &autoneg_exp);
+
+				if (!(autoneg_exp & NWAY_ER_LP_NWAY_CAPS))
+					e_info("Autonegotiated half duplex but"
+					       " link partner cannot autoneg. "
+					       " Try forcing full duplex if "
+					       "link gets many collisions.\n");
+			}
+
+			/*
 			 * tweak tx_queue_len according to speed/duplex
 			 * and adjust the timeout factor
 			 */
@@ -3315,7 +3646,10 @@ link_up:
 	}
=20
 	/* Cause software interrupt to ensure Rx ring is cleaned */
-	ew32(ICS, E1000_ICS_RXDMT0);
+	if (adapter->msix_entries)
+		ew32(ICS, adapter->rx_ring->ims_val);
+	else
+		ew32(ICS, E1000_ICS_RXDMT0);
=20
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung =3D 1;
@@ -4032,6 +4366,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm=
_message_t state)
 		e1000e_down(adapter);
 		e1000_free_irq(adapter);
 	}
+	e1000e_reset_interrupt_capability(adapter);
=20
 	retval =3D pci_save_state(pdev);
 	if (retval)
@@ -4158,6 +4493,7 @@ static int e1000_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
=20
+	e1000e_set_interrupt_capability(adapter);
 	if (netif_running(netdev)) {
 		err =3D e1000_request_irq(adapter);
 		if (err)
@@ -4467,6 +4803,8 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
=20
 	adapter->bd_number =3D cards_found++;
=20
+	e1000e_check_options(adapter);
+
 	/* setup adapter struct */
 	err =3D e1000_sw_init(adapter);
 	if (err)
@@ -4573,8 +4911,6 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
=20
-	e1000e_check_options(adapter);
-
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg =3D 1;
 	adapter->fc_autoneg =3D 1;
@@ -4704,6 +5040,7 @@ static void __devexit e1000_remove(struct pci_dev=
 *pdev)
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
=20
+	e1000e_reset_interrupt_capability(adapter);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
=20
@@ -4745,6 +5082,8 @@ static struct pci_device_id e1000_pci_tbl[] =3D {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573E_IAMT), board_82573 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573L), board_82573 },
=20
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82574L), board_82574 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_DPT),
 	  board_80003es2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_SPT),
@@ -4767,6 +5106,7 @@ static struct pci_device_id e1000_pci_tbl[] =3D {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_C), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_BM), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_V), board_ich9lan },
@@ -4775,6 +5115,9 @@ static struct pci_device_id e1000_pci_tbl[] =3D {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_LF), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_V), board_ich9lan },
=20
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LM), board_ich10lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LF), board_ich10lan },
+
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index ed912e0..f46db6c 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -114,6 +114,15 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Thro=
ttling Rate");
 #define DEFAULT_ITR 3
 #define MAX_ITR 100000
 #define MIN_ITR 100
+/* IntMode (Interrupt Mode)
+ *
+ * Valid Range: 0 - 2
+ *
+ * Default Value: 2 (MSI-X)
+ */
+E1000_PARAM(IntMode, "Interrupt Mode");
+#define MAX_INTMODE	2
+#define MIN_INTMODE	0
=20
 /*
  * Enable Smart Power Down of the PHY
@@ -352,6 +361,24 @@ void __devinit e1000e_check_options(struct e1000_a=
dapter *adapter)
 			adapter->itr =3D 20000;
 		}
 	}
+	{ /* Interrupt Mode */
+		struct e1000_option opt =3D {
+			.type =3D range_option,
+			.name =3D "Interrupt Mode",
+			.err  =3D "defaulting to 2 (MSI-X)",
+			.def  =3D E1000E_INT_MODE_MSIX,
+			.arg  =3D { .r =3D { .min =3D MIN_INTMODE,
+					 .max =3D MAX_INTMODE } }
+		};
+
+		if (num_IntMode > bd) {
+			unsigned int int_mode =3D IntMode[bd];
+			e1000_validate_option(&int_mode, &opt, adapter);
+			adapter->int_mode =3D int_mode;
+		} else {
+			adapter->int_mode =3D opt.def;
+		}
+	}
 	{ /* Smart Power Down */
 		const struct e1000_option opt =3D {
 			.type =3D enable_option,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index b133dcf..6cd333a 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -476,7 +476,9 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *h=
w)
 	if (ret_val)
 		return ret_val;
=20
-	if ((phy->type =3D=3D e1000_phy_m88) && (phy->revision < 4)) {
+	if ((phy->type =3D=3D e1000_phy_m88) &&
+	    (phy->revision < E1000_REVISION_4) &&
+	    (phy->id !=3D BME1000_E_PHY_ID_R2)) {
 		/*
 		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
@@ -504,6 +506,18 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *=
hw)
 			return ret_val;
 	}
=20
+	if ((phy->type =3D=3D e1000_phy_bm) && (phy->id =3D=3D BME1000_E_PHY_=
ID_R2)) {
+		/* Set PHY page 0, register 29 to 0x0003 */
+		ret_val =3D e1e_wphy(hw, 29, 0x0003);
+		if (ret_val)
+			return ret_val;
+
+		/* Set PHY page 0, register 30 to 0x0000 */
+		ret_val =3D e1e_wphy(hw, 30, 0x0000);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/* Commit the changes. */
 	ret_val =3D e1000e_commit_phy(hw);
 	if (ret_val)
@@ -1720,6 +1734,91 @@ s32 e1000e_get_cfg_done(struct e1000_hw *hw)
 	return 0;
 }
=20
+/**
+ *  e1000e_phy_init_script_igp3 - Inits the IGP3 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes a Intel Gigabit PHY3 when an EEPROM is not present.
+ **/
+s32 e1000e_phy_init_script_igp3(struct e1000_hw *hw)
+{
+	hw_dbg(hw, "Running IGP 3 PHY init script\n");
+
+	/* PHY init IGP 3 */
+	/* Enable rise/fall, 10-mode work in class-A */
+	e1e_wphy(hw, 0x2F5B, 0x9018);
+	/* Remove all caps from Replica path filter */
+	e1e_wphy(hw, 0x2F52, 0x0000);
+	/* Bias trimming for ADC, AFE and Driver (Default) */
+	e1e_wphy(hw, 0x2FB1, 0x8B24);
+	/* Increase Hybrid poly bias */
+	e1e_wphy(hw, 0x2FB2, 0xF8F0);
+	/* Add 4% to Tx amplitude in Gig mode */
+	e1e_wphy(hw, 0x2010, 0x10B0);
+	/* Disable trimming (TTT) */
+	e1e_wphy(hw, 0x2011, 0x0000);
+	/* Poly DC correction to 94.6% + 2% for all channels */
+	e1e_wphy(hw, 0x20DD, 0x249A);
+	/* ABS DC correction to 95.9% */
+	e1e_wphy(hw, 0x20DE, 0x00D3);
+	/* BG temp curve trim */
+	e1e_wphy(hw, 0x28B4, 0x04CE);
+	/* Increasing ADC OPAMP stage 1 currents to max */
+	e1e_wphy(hw, 0x2F70, 0x29E4);
+	/* Force 1000 ( required for enabling PHY regs configuration) */
+	e1e_wphy(hw, 0x0000, 0x0140);
+	/* Set upd_freq to 6 */
+	e1e_wphy(hw, 0x1F30, 0x1606);
+	/* Disable NPDFE */
+	e1e_wphy(hw, 0x1F31, 0xB814);
+	/* Disable adaptive fixed FFE (Default) */
+	e1e_wphy(hw, 0x1F35, 0x002A);
+	/* Enable FFE hysteresis */
+	e1e_wphy(hw, 0x1F3E, 0x0067);
+	/* Fixed FFE for short cable lengths */
+	e1e_wphy(hw, 0x1F54, 0x0065);
+	/* Fixed FFE for medium cable lengths */
+	e1e_wphy(hw, 0x1F55, 0x002A);
+	/* Fixed FFE for long cable lengths */
+	e1e_wphy(hw, 0x1F56, 0x002A);
+	/* Enable Adaptive Clip Threshold */
+	e1e_wphy(hw, 0x1F72, 0x3FB0);
+	/* AHT reset limit to 1 */
+	e1e_wphy(hw, 0x1F76, 0xC0FF);
+	/* Set AHT master delay to 127 msec */
+	e1e_wphy(hw, 0x1F77, 0x1DEC);
+	/* Set scan bits for AHT */
+	e1e_wphy(hw, 0x1F78, 0xF9EF);
+	/* Set AHT Preset bits */
+	e1e_wphy(hw, 0x1F79, 0x0210);
+	/* Change integ_factor of channel A to 3 */
+	e1e_wphy(hw, 0x1895, 0x0003);
+	/* Change prop_factor of channels BCD to 8 */
+	e1e_wphy(hw, 0x1796, 0x0008);
+	/* Change cg_icount + enable integbp for channels BCD */
+	e1e_wphy(hw, 0x1798, 0xD008);
+	/*
+	 * Change cg_icount + enable integbp + change prop_factor_master
+	 * to 8 for channel A
+	 */
+	e1e_wphy(hw, 0x1898, 0xD918);
+	/* Disable AHT in Slave mode on channel A */
+	e1e_wphy(hw, 0x187A, 0x0800);
+	/*
+	 * Enable LPLU and disable AN to 1000 in non-D0a states,
+	 * Enable SPD+B2B
+	 */
+	e1e_wphy(hw, 0x0019, 0x008D);
+	/* Enable restart AN on an1000_dis change */
+	e1e_wphy(hw, 0x001B, 0x2080);
+	/* Enable wh_fifo read clock in 10/100 modes */
+	e1e_wphy(hw, 0x0014, 0x0045);
+	/* Restart AN, Speed selection is 1000 */
+	e1e_wphy(hw, 0x0000, 0x1340);
+
+	return 0;
+}
+
 /* Internal function pointers */
=20
 /**
@@ -1969,6 +2068,99 @@ out:
 }
=20
 /**
+ *  e1000e_read_phy_reg_bm2 - Read BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at o=
ffset
+ *  and storing the retrieved information in data.  Release any acquir=
ed
+ *  semaphores before exiting.
+ **/
+s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data=
)
+{
+	s32 ret_val;
+	u16 page =3D (u16)(offset >> IGP_PAGE_SHIFT);
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page =3D=3D BM_WUC_PAGE) {
+		ret_val =3D e1000_access_phy_wakeup_reg_bm(hw, offset, data,
+							 true);
+		return ret_val;
+	}
+
+	ret_val =3D hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
+	hw->phy.addr =3D 1;
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val =3D e1000e_write_phy_reg_mdic(hw, BM_PHY_PAGE_SELECT,
+						    page);
+
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			return ret_val;
+		}
+	}
+
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset=
,
+					   data);
+	hw->phy.ops.release_phy(hw);
+
+	return ret_val;
+}
+
+/**
+ *  e1000e_write_phy_reg_bm2 - Write BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY regi=
ster
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data=
)
+{
+	s32 ret_val;
+	u16 page =3D (u16)(offset >> IGP_PAGE_SHIFT);
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page =3D=3D BM_WUC_PAGE) {
+		ret_val =3D e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
+							 false);
+		return ret_val;
+	}
+
+	ret_val =3D hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
+	hw->phy.addr =3D 1;
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val =3D e1000e_write_phy_reg_mdic(hw, BM_PHY_PAGE_SELECT,
+						    page);
+
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			return ret_val;
+		}
+	}
+
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offse=
t,
+					    data);
+
+	hw->phy.ops.release_phy(hw);
+
+	return ret_val;
+}
+
+/**
  *  e1000_access_phy_wakeup_reg_bm - Read BM PHY wakeup register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read or written
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/ma=
l.h
index eaa7262..717dc38 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -102,7 +102,7 @@
 /* MAL V1 IER bits */
 #define   MAL1_IER_NWE		0x00000008
 #define   MAL1_IER_SOC_EVENTS	MAL1_IER_NWE
-#define   MAL1_IER_EVENTS	(MAL1_IER_SOC_EVENTS | MAL_IER_OTE | \
+#define   MAL1_IER_EVENTS	(MAL1_IER_SOC_EVENTS | MAL_IER_DE | \
 				 MAL_IER_OTE | MAL_IER_OE | MAL_IER_PE)
=20
 /* MAL V2 IER bits */
@@ -110,7 +110,7 @@
 #define   MAL2_IER_PRE		0x00000040
 #define   MAL2_IER_PWE		0x00000020
 #define   MAL2_IER_SOC_EVENTS	(MAL2_IER_PT | MAL2_IER_PRE | MAL2_IER_P=
WE)
-#define   MAL2_IER_EVENTS	(MAL2_IER_SOC_EVENTS | MAL_IER_OTE | \
+#define   MAL2_IER_EVENTS	(MAL2_IER_SOC_EVENTS | MAL_IER_DE | \
 				 MAL_IER_OTE | MAL_IER_OE | MAL_IER_PE)
=20
=20
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 634c4c9..93d02ef 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3563,10 +3563,6 @@ static int igb_clean_rx_ring_msix(struct napi_st=
ruct *napi, int budget)
 	struct net_device *netdev =3D adapter->netdev;
 	int work_done =3D 0;
=20
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
-
 #ifdef CONFIG_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
@@ -3576,7 +3572,6 @@ static int igb_clean_rx_ring_msix(struct napi_str=
uct *napi, int budget)
=20
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done =3D=3D 0) || !netif_running(netdev)) {
-quit_polling:
 		netif_rx_complete(netdev, napi);
=20
 		if (adapter->itr_setting & 3) {
@@ -3617,16 +3612,14 @@ static bool igb_clean_tx_irq(struct igb_ring *t=
x_ring)
 	unsigned int i;
 	u32 head, oldhead;
 	unsigned int count =3D 0;
-	bool cleaned =3D false;
-	bool retval =3D true;
 	unsigned int total_bytes =3D 0, total_packets =3D 0;
+	bool retval =3D true;
=20
 	rmb();
 	head =3D get_head(tx_ring);
 	i =3D tx_ring->next_to_clean;
 	while (1) {
 		while (i !=3D head) {
-			cleaned =3D true;
 			tx_desc =3D E1000_TX_DESC(*tx_ring, i);
 			buffer_info =3D &tx_ring->buffer_info[i];
 			skb =3D buffer_info->skb;
@@ -3643,7 +3636,6 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_=
ring)
 			}
=20
 			igb_unmap_and_free_tx_resource(adapter, buffer_info);
-			tx_desc->upper.data =3D 0;
=20
 			i++;
 			if (i =3D=3D tx_ring->count)
@@ -3665,7 +3657,7 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_=
ring)
 done_cleaning:
 	tx_ring->next_to_clean =3D i;
=20
-	if (unlikely(cleaned &&
+	if (unlikely(count &&
 		     netif_carrier_ok(netdev) &&
 		     IGB_DESC_UNUSED(tx_ring) >=3D IGB_TX_QUEUE_WAKE)) {
 		/* Make sure that anybody stopping the queue after this
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 956914a..90b5383 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -37,7 +37,7 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 #include <linux/dca.h>
 #endif
=20
@@ -69,12 +69,12 @@
=20
 /* flow control */
 #define IXGBE_DEFAULT_FCRTL		0x10000
-#define IXGBE_MIN_FCRTL			      0
+#define IXGBE_MIN_FCRTL			   0x40
 #define IXGBE_MAX_FCRTL			0x7FF80
 #define IXGBE_DEFAULT_FCRTH		0x20000
-#define IXGBE_MIN_FCRTH			      0
+#define IXGBE_MIN_FCRTH			  0x600
 #define IXGBE_MAX_FCRTH			0x7FFF0
-#define IXGBE_DEFAULT_FCPAUSE		 0x6800  /* may be too long */
+#define IXGBE_DEFAULT_FCPAUSE		 0xFFFF
 #define IXGBE_MIN_FCPAUSE		      0
 #define IXGBE_MAX_FCPAUSE		 0xFFFF
=20
@@ -150,7 +150,7 @@ struct ixgbe_ring {
 		      * offset associated with this ring, which is different
 		      * for DCE and RSS modes */
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	/* cpu for tx queue */
 	int cpu;
 #endif
@@ -166,6 +166,7 @@ struct ixgbe_ring {
=20
 	char name[IFNAMSIZ + 5];
 	u16 work_limit;                /* max work per interrupt */
+	u16 rx_buf_len;
 };
=20
 #define RING_F_VMDQ 1
@@ -228,7 +229,6 @@ struct ixgbe_adapter {
 	struct timer_list watchdog_timer;
 	struct vlan_group *vlgrp;
 	u16 bd_number;
-	u16 rx_buf_len;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
@@ -267,15 +267,28 @@ struct ixgbe_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1 << 0)
-#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 2)
-#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 3)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 4)
-#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 5)
-#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 6)
-#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 7)
-#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
+#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
+#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
+#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
+#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
+#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 4)
+#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 6)
+#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 7)
+#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 8)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 9)
+#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 10)
+#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
+#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
+#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
+#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
+#define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
+#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
+#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
+#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
+#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
+
+/* default to trying for four seconds */
+#define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
=20
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_=
82598.c
index f96358b..ba09063 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -36,6 +36,8 @@
 #define IXGBE_82598_MAX_TX_QUEUES 32
 #define IXGBE_82598_MAX_RX_QUEUES 64
 #define IXGBE_82598_RAR_ENTRIES   16
+#define IXGBE_82598_MC_TBL_SIZE  128
+#define IXGBE_82598_VFT_TBL_SIZE 128
=20
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
 static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *spe=
ed,
@@ -60,7 +62,9 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw=
 *hw)
 {
 	hw->mac.num_rx_queues =3D IXGBE_82598_MAX_RX_QUEUES;
 	hw->mac.num_tx_queues =3D IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.num_rx_addrs =3D IXGBE_82598_RAR_ENTRIES;
+	hw->mac.mcft_size =3D IXGBE_82598_MC_TBL_SIZE;
+	hw->mac.vft_size =3D IXGBE_82598_VFT_TBL_SIZE;
+	hw->mac.num_rar_entries =3D IXGBE_82598_RAR_ENTRIES;
=20
 	/* PHY ops are filled in by default properly for Fiber only */
 	if (hw->mac.ops.get_media_type(hw) =3D=3D ixgbe_media_type_copper) {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe=
_common.c
index 7fd6aeb..9c0d0a1 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -661,7 +661,7 @@ s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u=
8 *addr, u32 vind,
 static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 {
 	u32 i;
-	u32 rar_entries =3D hw->mac.num_rx_addrs;
+	u32 rar_entries =3D hw->mac.num_rar_entries;
=20
 	/*
 	 * If the current mac address is valid, assume it is a software overr=
ide
@@ -705,13 +705,114 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *=
hw)
 	IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
=20
 	hw_dbg(hw, " Clearing MTA\n");
-	for (i =3D 0; i < IXGBE_MC_TBL_SIZE; i++)
+	for (i =3D 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
=20
 	return 0;
 }
=20
 /**
+ *  ixgbe_add_uc_addr - Adds a secondary unicast address.
+ *  @hw: pointer to hardware structure
+ *  @addr: new address
+ *
+ *  Adds it to unused receive address register or goes into promiscuou=
s mode.
+ **/
+void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
+{
+	u32 rar_entries =3D hw->mac.num_rar_entries;
+	u32 rar;
+
+	hw_dbg(hw, " UC Addr =3D %.2X %.2X %.2X %.2X %.2X %.2X\n",
+	          addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+	/*
+	 * Place this address in the RAR if there is room,
+	 * else put the controller into promiscuous mode
+	 */
+	if (hw->addr_ctrl.rar_used_count < rar_entries) {
+		rar =3D hw->addr_ctrl.rar_used_count -
+		      hw->addr_ctrl.mc_addr_in_rar_count;
+		ixgbe_set_rar(hw, rar, addr, 0, IXGBE_RAH_AV);
+		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
+		hw->addr_ctrl.rar_used_count++;
+	} else {
+		hw->addr_ctrl.overflow_promisc++;
+	}
+
+	hw_dbg(hw, "ixgbe_add_uc_addr Complete\n");
+}
+
+/**
+ *  ixgbe_update_uc_addr_list - Updates MAC list of secondary addresse=
s
+ *  @hw: pointer to hardware structure
+ *  @addr_list: the list of new addresses
+ *  @addr_count: number of addresses
+ *  @next: iterator function to walk the address list
+ *
+ *  The given list replaces any existing list.  Clears the secondary a=
ddrs from
+ *  receive address registers.  Uses unused receive address registers =
for the
+ *  first secondary addresses, and falls back to promiscuous mode as n=
eeded.
+ *
+ *  Drivers using secondary unicast addresses must set user_set_promis=
c when
+ *  manually putting the device into promiscuous mode.
+ **/
+s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
+                              u32 addr_count, ixgbe_mc_addr_itr next)
+{
+	u8 *addr;
+	u32 i;
+	u32 old_promisc_setting =3D hw->addr_ctrl.overflow_promisc;
+	u32 uc_addr_in_use;
+	u32 fctrl;
+	u32 vmdq;
+
+	/*
+	 * Clear accounting of old secondary address list,
+	 * don't count RAR[0]
+	 */
+	uc_addr_in_use =3D hw->addr_ctrl.rar_used_count -
+	                 hw->addr_ctrl.mc_addr_in_rar_count - 1;
+	hw->addr_ctrl.rar_used_count -=3D uc_addr_in_use;
+	hw->addr_ctrl.overflow_promisc =3D 0;
+
+	/* Zero out the other receive addresses */
+	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use);
+	for (i =3D 1; i <=3D uc_addr_in_use; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
+	}
+
+	/* Add the new addresses */
+	for (i =3D 0; i < addr_count; i++) {
+		hw_dbg(hw, " Adding the secondary addresses:\n");
+		addr =3D next(hw, &addr_list, &vmdq);
+		ixgbe_add_uc_addr(hw, addr);
+	}
+
+	if (hw->addr_ctrl.overflow_promisc) {
+		/* enable promisc if not already in overflow or set by user */
+		if (!old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
+			hw_dbg(hw, " Entering address overflow promisc mode\n");
+			fctrl =3D IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			fctrl |=3D IXGBE_FCTRL_UPE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+		}
+	} else {
+		/* only disable if set by overflow, not by user */
+		if (old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
+			hw_dbg(hw, " Leaving address overflow promisc mode\n");
+			fctrl =3D IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			fctrl &=3D ~IXGBE_FCTRL_UPE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+		}
+	}
+
+	hw_dbg(hw, "ixgbe_update_uc_addr_list Complete\n");
+	return 0;
+}
+
+/**
  *  ixgbe_mta_vector - Determines bit-vector in multicast table to set
  *  @hw: pointer to hardware structure
  *  @mc_addr: the multicast address
@@ -794,7 +895,7 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *=
mc_addr)
  **/
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 {
-	u32 rar_entries =3D hw->mac.num_rx_addrs;
+	u32 rar_entries =3D hw->mac.num_rar_entries;
=20
 	hw_dbg(hw, " MC Addr =3D%.2X %.2X %.2X %.2X %.2X %.2X\n",
 		  mc_addr[0], mc_addr[1], mc_addr[2],
@@ -823,7 +924,7 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, =
u8 *mc_addr)
  *  @hw: pointer to hardware structure
  *  @mc_addr_list: the list of new multicast addresses
  *  @mc_addr_count: number of addresses
- *  @pad: number of bytes between addresses in the list
+ *  @next: iterator function to walk the multicast address list
  *
  *  The given list replaces any existing list. Clears the MC addrs fro=
m receive
  *  address registers and the multicast table. Uses unsed receive addr=
ess
@@ -831,10 +932,11 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw=
, u8 *mc_addr)
  *  multicast table.
  **/
 s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, u32 pad)
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
-	u32 rar_entries =3D hw->mac.num_rx_addrs;
+	u32 rar_entries =3D hw->mac.num_rar_entries;
+	u32 vmdq;
=20
 	/*
 	 * Set the new number of MC addresses that we are being requested to
@@ -854,14 +956,13 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw=
, u8 *mc_addr_list,
=20
 	/* Clear the MTA */
 	hw_dbg(hw, " Clearing MTA\n");
-	for (i =3D 0; i < IXGBE_MC_TBL_SIZE; i++)
+	for (i =3D 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
=20
 	/* Add the new addresses */
 	for (i =3D 0; i < mc_addr_count; i++) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
-		ixgbe_add_mc_addr(hw, mc_addr_list +
-				  (i * (IXGBE_ETH_LENGTH_OF_ADDRESS + pad)));
+		ixgbe_add_mc_addr(hw, next(hw, &mc_addr_list, &vmdq));
 	}
=20
 	/* Enable mta */
@@ -884,11 +985,11 @@ static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw)
 	u32 offset;
 	u32 vlanbyte;
=20
-	for (offset =3D 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+	for (offset =3D 0; offset < hw->mac.vft_size; offset++)
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
=20
 	for (vlanbyte =3D 0; vlanbyte < 4; vlanbyte++)
-		for (offset =3D 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+		for (offset =3D 0; offset < hw->mac.vft_size; offset++)
 			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
 					0);
=20
@@ -964,6 +1065,13 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packe=
tbuf_num)
 	rmcs_reg &=3D ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
=20
 	/*
+	 * 10 gig parts do not have a word in the EEPROM to determine the
+	 * default flow control setting, so we explicitly set it to full.
+	 */
+	if (hw->fc.type =3D=3D ixgbe_fc_default)
+		hw->fc.type =3D ixgbe_fc_full;
+
+	/*
 	 * We want to save off the original Flow Control configuration just i=
n
 	 * case we get disconnected and then reconnected into a different hub
 	 * or switch with different Flow Control capabilities.
@@ -1016,6 +1124,16 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 pack=
etbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
=20
 	/*
+	 * Check for invalid software configuration, zeros are completely
+	 * invalid for all parameters used past this point, and if we enable
+	 * flow control with zero water marks, we blast flow control packets.
+	 */
+	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
+		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
+		return IXGBE_ERR_INVALID_LINK_SETTINGS;
+	}
+
+	/*
 	 * We need to set up the Receive Threshold high and low water
 	 * marks as well as (optionally) enabling the transmission of
 	 * XON frames.
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe=
_common.h
index de6ddd5..c75ecba 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -47,7 +47,9 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *h=
w, u16 *checksum_val);
 s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
 		  u32 enable_addr);
 s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, u32 pad);
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
+s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *uc_addr_list,
+			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
 s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind, bool vlan_=
on);
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
=20
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 3efe5dd..61c000e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -233,15 +233,15 @@ static int ixgbe_set_rx_csum(struct net_device *n=
etdev, u32 data)
=20
 static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 {
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
+	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
 }
=20
 static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
+		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
+		netdev->features &=3D ~NETIF_F_IP_CSUM;
=20
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 53f41b6..99e0b34 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -80,7 +80,7 @@ static struct pci_device_id ixgbe_pci_tbl[] =3D {
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long eve=
nt,
 			    void *p);
 static struct notifier_block dca_notifier =3D {
@@ -148,8 +148,7 @@ static void ixgbe_unmap_and_free_tx_resource(struct=
 ixgbe_adapter *adapter,
 					     *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
-		pci_unmap_page(adapter->pdev,
-			       tx_buffer_info->dma,
+		pci_unmap_page(adapter->pdev, tx_buffer_info->dma,
 			       tx_buffer_info->length, PCI_DMA_TODEVICE);
 		tx_buffer_info->dma =3D 0;
 	}
@@ -162,32 +161,35 @@ static void ixgbe_unmap_and_free_tx_resource(stru=
ct ixgbe_adapter *adapter,
=20
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 				       struct ixgbe_ring *tx_ring,
-				       unsigned int eop,
-				       union ixgbe_adv_tx_desc *eop_desc)
+				       unsigned int eop)
 {
+	struct ixgbe_hw *hw =3D &adapter->hw;
+	u32 head, tail;
+
 	/* Detect a transmit hang in hardware, this serializes the
-	 * check with the clearing of time_stamp and movement of i */
+	 * check with the clearing of time_stamp and movement of eop */
+	head =3D IXGBE_READ_REG(hw, tx_ring->head);
+	tail =3D IXGBE_READ_REG(hw, tx_ring->tail);
 	adapter->detect_tx_hung =3D false;
-	if (tx_ring->tx_buffer_info[eop].dma &&
+	if ((head !=3D tail) &&
+	    tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ)=
 &&
 	    !(IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & IXGBE_TFCS_TXOFF)) {
 		/* detected Tx unit hang */
+		union ixgbe_adv_tx_desc *tx_desc;
+		tx_desc =3D IXGBE_TX_DESC_ADV(*tx_ring, eop);
 		DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
-			"  TDH                  <%x>\n"
-			"  TDT                  <%x>\n"
+			"  Tx Queue             <%d>\n"
+			"  TDH, TDT             <%x>, <%x>\n"
 			"  next_to_use          <%x>\n"
 			"  next_to_clean        <%x>\n"
 			"tx_buffer_info[next_to_clean]\n"
 			"  time_stamp           <%lx>\n"
-			"  next_to_watch        <%x>\n"
-			"  jiffies              <%lx>\n"
-			"  next_to_watch.status <%x>\n",
-			readl(adapter->hw.hw_addr + tx_ring->head),
-			readl(adapter->hw.hw_addr + tx_ring->tail),
-			tx_ring->next_to_use,
-			tx_ring->next_to_clean,
-			tx_ring->tx_buffer_info[eop].time_stamp,
-			eop, jiffies, eop_desc->wb.status);
+			"  jiffies              <%lx>\n",
+			tx_ring->queue_index,
+			head, tail,
+			tx_ring->next_to_use, eop,
+			tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
 		return true;
 	}
=20
@@ -203,65 +205,75 @@ static inline bool ixgbe_check_tx_hang(struct ixg=
be_adapter *adapter,
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->dat=
a */ + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
=20
+#define GET_TX_HEAD_FROM_RING(ring) (\
+	*(volatile u32 *) \
+	((union ixgbe_adv_tx_desc *)(ring)->desc + (ring)->count))
+static void ixgbe_tx_timeout(struct net_device *netdev);
+
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
+ * @tx_ring: tx ring to clean
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *tx_ring)
+                               struct ixgbe_ring *tx_ring)
 {
-	struct net_device *netdev =3D adapter->netdev;
-	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
+	union ixgbe_adv_tx_desc *tx_desc;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int i, eop;
-	bool cleaned =3D false;
-	unsigned int total_tx_bytes =3D 0, total_tx_packets =3D 0;
+	struct net_device *netdev =3D adapter->netdev;
+	struct sk_buff *skb;
+	unsigned int i;
+	u32 head, oldhead;
+	unsigned int count =3D 0;
+	unsigned int total_bytes =3D 0, total_packets =3D 0;
=20
+	rmb();
+	head =3D GET_TX_HEAD_FROM_RING(tx_ring);
+	head =3D le32_to_cpu(head);
 	i =3D tx_ring->next_to_clean;
-	eop =3D tx_ring->tx_buffer_info[i].next_to_watch;
-	eop_desc =3D IXGBE_TX_DESC_ADV(*tx_ring, eop);
-	while (eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) {
-		cleaned =3D false;
-		while (!cleaned) {
+	while (1) {
+		while (i !=3D head) {
 			tx_desc =3D IXGBE_TX_DESC_ADV(*tx_ring, i);
 			tx_buffer_info =3D &tx_ring->tx_buffer_info[i];
-			cleaned =3D (i =3D=3D eop);
+			skb =3D tx_buffer_info->skb;
=20
-			tx_ring->stats.bytes +=3D tx_buffer_info->length;
-			if (cleaned) {
-				struct sk_buff *skb =3D tx_buffer_info->skb;
+			if (skb) {
 				unsigned int segs, bytecount;
+
+				/* gso_segs is currently only valid for tcp */
 				segs =3D skb_shinfo(skb)->gso_segs ?: 1;
 				/* multiply data chunks by size of headers */
 				bytecount =3D ((segs - 1) * skb_headlen(skb)) +
-					    skb->len;
-				total_tx_packets +=3D segs;
-				total_tx_bytes +=3D bytecount;
+				            skb->len;
+				total_packets +=3D segs;
+				total_bytes +=3D bytecount;
 			}
+
 			ixgbe_unmap_and_free_tx_resource(adapter,
-							 tx_buffer_info);
-			tx_desc->wb.status =3D 0;
+			                                 tx_buffer_info);
=20
 			i++;
 			if (i =3D=3D tx_ring->count)
 				i =3D 0;
-		}
-
-		tx_ring->stats.packets++;
-
-		eop =3D tx_ring->tx_buffer_info[i].next_to_watch;
-		eop_desc =3D IXGBE_TX_DESC_ADV(*tx_ring, eop);
-
-		/* weight of a sort for tx, avoid endless transmit cleanup */
-		if (total_tx_packets >=3D tx_ring->work_limit)
-			break;
-	}
=20
+			count++;
+			if (count =3D=3D tx_ring->count)
+				goto done_cleaning;
+		}
+		oldhead =3D head;
+		rmb();
+		head =3D GET_TX_HEAD_FROM_RING(tx_ring);
+		head =3D le32_to_cpu(head);
+		if (head =3D=3D oldhead)
+			goto done_cleaning;
+	} /* while (1) */
+
+done_cleaning:
 	tx_ring->next_to_clean =3D i;
=20
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (total_tx_packets && netif_carrier_ok(netdev) &&
-	    (IXGBE_DESC_UNUSED(tx_ring) >=3D TX_WAKE_THRESHOLD)) {
+	if (unlikely(count && netif_carrier_ok(netdev) &&
+	             (IXGBE_DESC_UNUSED(tx_ring) >=3D TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -269,59 +281,68 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapt=
er *adapter,
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
-			adapter->restart_queue++;
+			++adapter->restart_queue;
 		}
 	}
=20
-	if (adapter->detect_tx_hung)
-		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
-			netif_stop_subqueue(netdev, tx_ring->queue_index);
+	if (adapter->detect_tx_hung) {
+		if (ixgbe_check_tx_hang(adapter, tx_ring, i)) {
+			/* schedule immediate reset if we believe we hung */
+			DPRINTK(PROBE, INFO,
+			        "tx hang %d detected, resetting adapter\n",
+			        adapter->tx_timeout_count + 1);
+			ixgbe_tx_timeout(adapter->netdev);
+		}
+	}
=20
-	if (total_tx_packets >=3D tx_ring->work_limit)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
+	/* re-arm the interrupt */
+	if ((total_packets >=3D tx_ring->work_limit) ||
+	    (count =3D=3D tx_ring->count))
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->v_idx);
=20
-	tx_ring->total_bytes +=3D total_tx_bytes;
-	tx_ring->total_packets +=3D total_tx_packets;
-	adapter->net_stats.tx_bytes +=3D total_tx_bytes;
-	adapter->net_stats.tx_packets +=3D total_tx_packets;
-	cleaned =3D total_tx_packets ? true : false;
-	return cleaned;
+	tx_ring->total_bytes +=3D total_bytes;
+	tx_ring->total_packets +=3D total_packets;
+	tx_ring->stats.bytes +=3D total_bytes;
+	tx_ring->stats.packets +=3D total_packets;
+	adapter->net_stats.tx_bytes +=3D total_bytes;
+	adapter->net_stats.tx_packets +=3D total_packets;
+	return (total_packets ? true : false);
 }
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rxr)
+				struct ixgbe_ring *rx_ring)
 {
 	u32 rxctrl;
 	int cpu =3D get_cpu();
-	int q =3D rxr - adapter->rx_ring;
+	int q =3D rx_ring - adapter->rx_ring;
=20
-	if (rxr->cpu !=3D cpu) {
+	if (rx_ring->cpu !=3D cpu) {
 		rxctrl =3D IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
 		rxctrl &=3D ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-		rxctrl |=3D dca_get_tag(cpu);
+		rxctrl |=3D dca3_get_tag(&adapter->pdev->dev, cpu);
 		rxctrl |=3D IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |=3D IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
-		rxr->cpu =3D cpu;
+		rx_ring->cpu =3D cpu;
 	}
 	put_cpu();
 }
=20
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *txr)
+				struct ixgbe_ring *tx_ring)
 {
 	u32 txctrl;
 	int cpu =3D get_cpu();
-	int q =3D txr - adapter->tx_ring;
+	int q =3D tx_ring - adapter->tx_ring;
=20
-	if (txr->cpu !=3D cpu) {
+	if (tx_ring->cpu !=3D cpu) {
 		txctrl =3D IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
 		txctrl &=3D ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-		txctrl |=3D dca_get_tag(cpu);
+		txctrl |=3D dca3_get_tag(&adapter->pdev->dev, cpu);
 		txctrl |=3D IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
-		txr->cpu =3D cpu;
+		tx_ring->cpu =3D cpu;
 	}
 	put_cpu();
 }
@@ -351,11 +372,14 @@ static int __ixgbe_notify_dca(struct device *dev,=
 void *data)
=20
 	switch (event) {
 	case DCA_PROVIDER_ADD:
-		adapter->flags |=3D IXGBE_FLAG_DCA_ENABLED;
+		/* if we're already enabled, don't do it again */
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			break;
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 		if (dca_add_requester(dev) =3D=3D 0) {
+			adapter->flags |=3D IXGBE_FLAG_DCA_ENABLED;
 			ixgbe_setup_dca(adapter);
 			break;
 		}
@@ -372,7 +396,7 @@ static int __ixgbe_notify_dca(struct device *dev, v=
oid *data)
 	return 0;
 }
=20
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
 /**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
@@ -420,14 +444,12 @@ static void ixgbe_receive_skb(struct ixgbe_adapte=
r *adapter,
  * @skb: skb currently being received and modified
  **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
-					 u32 status_err,
-					 struct sk_buff *skb)
+                                     u32 status_err, struct sk_buff *s=
kb)
 {
 	skb->ip_summed =3D CHECKSUM_NONE;
=20
-	/* Ignore Checksum bit is set, or rx csum disabled */
-	if ((status_err & IXGBE_RXD_STAT_IXSM) ||
-	    !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	/* Rx csum disabled */
+	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
 		return;
=20
 	/* if IP and error */
@@ -455,37 +477,36 @@ static inline void ixgbe_rx_checksum(struct ixgbe=
_adapter *adapter,
  * @adapter: address of board private structure
  **/
 static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-				       struct ixgbe_ring *rx_ring,
-				       int cleaned_count)
+                                   struct ixgbe_ring *rx_ring,
+                                   int cleaned_count)
 {
 	struct net_device *netdev =3D adapter->netdev;
 	struct pci_dev *pdev =3D adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
-	struct ixgbe_rx_buffer *rx_buffer_info;
-	struct sk_buff *skb;
+	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
-	unsigned int bufsz =3D adapter->rx_buf_len + NET_IP_ALIGN;
+	unsigned int bufsz =3D rx_ring->rx_buf_len + NET_IP_ALIGN;
=20
 	i =3D rx_ring->next_to_use;
-	rx_buffer_info =3D &rx_ring->rx_buffer_info[i];
+	bi =3D &rx_ring->rx_buffer_info[i];
=20
 	while (cleaned_count--) {
 		rx_desc =3D IXGBE_RX_DESC_ADV(*rx_ring, i);
=20
-		if (!rx_buffer_info->page &&
-				(adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
-			rx_buffer_info->page =3D alloc_page(GFP_ATOMIC);
-			if (!rx_buffer_info->page) {
+		if (!bi->page &&
+		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
+			bi->page =3D alloc_page(GFP_ATOMIC);
+			if (!bi->page) {
 				adapter->alloc_rx_page_failed++;
 				goto no_buffers;
 			}
-			rx_buffer_info->page_dma =3D
-			    pci_map_page(pdev, rx_buffer_info->page,
-					 0, PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			bi->page_dma =3D pci_map_page(pdev, bi->page, 0,
+	                                            PAGE_SIZE,
+	                                            PCI_DMA_FROMDEVICE);
 		}
=20
-		if (!rx_buffer_info->skb) {
-			skb =3D netdev_alloc_skb(netdev, bufsz);
+		if (!bi->skb) {
+			struct sk_buff *skb =3D netdev_alloc_skb(netdev, bufsz);
=20
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -499,28 +520,25 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_a=
dapter *adapter,
 			 */
 			skb_reserve(skb, NET_IP_ALIGN);
=20
-			rx_buffer_info->skb =3D skb;
-			rx_buffer_info->dma =3D pci_map_single(pdev, skb->data,
-							  bufsz,
-							  PCI_DMA_FROMDEVICE);
+			bi->skb =3D skb;
+			bi->dma =3D pci_map_single(pdev, skb->data, bufsz,
+			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-			rx_desc->read.pkt_addr =3D
-			    cpu_to_le64(rx_buffer_info->page_dma);
-			rx_desc->read.hdr_addr =3D
-					cpu_to_le64(rx_buffer_info->dma);
+			rx_desc->read.pkt_addr =3D cpu_to_le64(bi->page_dma);
+			rx_desc->read.hdr_addr =3D cpu_to_le64(bi->dma);
 		} else {
-			rx_desc->read.pkt_addr =3D
-					cpu_to_le64(rx_buffer_info->dma);
+			rx_desc->read.pkt_addr =3D cpu_to_le64(bi->dma);
 		}
=20
 		i++;
 		if (i =3D=3D rx_ring->count)
 			i =3D 0;
-		rx_buffer_info =3D &rx_ring->rx_buffer_info[i];
+		bi =3D &rx_ring->rx_buffer_info[i];
 	}
+
 no_buffers:
 	if (rx_ring->next_to_use !=3D i) {
 		rx_ring->next_to_use =3D i;
@@ -538,9 +556,19 @@ no_buffers:
 	}
 }
=20
+static inline u16 ixgbe_get_hdr_info(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return rx_desc->wb.lower.lo_dword.hs_rss.hdr_info;
+}
+
+static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
+}
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-			       struct ixgbe_ring *rx_ring,
-			       int *work_done, int work_to_do)
+	                       struct ixgbe_ring *rx_ring,
+	                       int *work_done, int work_to_do)
 {
 	struct net_device *netdev =3D adapter->netdev;
 	struct pci_dev *pdev =3D adapter->pdev;
@@ -548,36 +576,35 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapt=
er *adapter,
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
 	unsigned int i;
-	u32 upper_len, len, staterr;
+	u32 len, staterr;
 	u16 hdr_info;
 	bool cleaned =3D false;
 	int cleaned_count =3D 0;
 	unsigned int total_rx_bytes =3D 0, total_rx_packets =3D 0;
=20
 	i =3D rx_ring->next_to_clean;
-	upper_len =3D 0;
 	rx_desc =3D IXGBE_RX_DESC_ADV(*rx_ring, i);
 	staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info =3D &rx_ring->rx_buffer_info[i];
=20
 	while (staterr & IXGBE_RXD_STAT_DD) {
+		u32 upper_len =3D 0;
 		if (*work_done >=3D work_to_do)
 			break;
 		(*work_done)++;
=20
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-			hdr_info =3D
-			    le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info);
-			len =3D
-			    ((hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
-			     IXGBE_RXDADV_HDRBUFLEN_SHIFT);
+			hdr_info =3D le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
+			len =3D (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
+	                       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
 			if (hdr_info & IXGBE_RXDADV_SPH)
 				adapter->rx_hdr_split++;
 			if (len > IXGBE_RX_HDR_SIZE)
 				len =3D IXGBE_RX_HDR_SIZE;
 			upper_len =3D le16_to_cpu(rx_desc->wb.upper.length);
-		} else
+		} else {
 			len =3D le16_to_cpu(rx_desc->wb.upper.length);
+		}
=20
 		cleaned =3D true;
 		skb =3D rx_buffer_info->skb;
@@ -586,8 +613,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter=
 *adapter,
=20
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 adapter->rx_buf_len + NET_IP_ALIGN,
-					 PCI_DMA_FROMDEVICE);
+	                                 rx_ring->rx_buf_len + NET_IP_ALIGN,
+	                                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}
=20
@@ -666,9 +693,6 @@ next_desc:
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
=20
-	adapter->net_stats.rx_bytes +=3D total_rx_bytes;
-	adapter->net_stats.rx_packets +=3D total_rx_packets;
-
 	rx_ring->total_packets +=3D total_rx_packets;
 	rx_ring->total_bytes +=3D total_rx_bytes;
 	adapter->net_stats.rx_bytes +=3D total_rx_bytes;
@@ -901,7 +925,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, voi=
d *data)
 {
 	struct ixgbe_q_vector *q_vector =3D data;
 	struct ixgbe_adapter  *adapter =3D q_vector->adapter;
-	struct ixgbe_ring     *txr;
+	struct ixgbe_ring     *tx_ring;
 	int i, r_idx;
=20
 	if (!q_vector->txr_count)
@@ -909,14 +933,14 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, v=
oid *data)
=20
 	r_idx =3D find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i =3D 0; i < q_vector->txr_count; i++) {
-		txr =3D &(adapter->tx_ring[r_idx]);
-#ifdef CONFIG_DCA
+		tx_ring =3D &(adapter->tx_ring[r_idx]);
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_tx_dca(adapter, txr);
+			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
-		txr->total_bytes =3D 0;
-		txr->total_packets =3D 0;
-		ixgbe_clean_tx_irq(adapter, txr);
+		tx_ring->total_bytes =3D 0;
+		tx_ring->total_packets =3D 0;
+		ixgbe_clean_tx_irq(adapter, tx_ring);
 		r_idx =3D find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
@@ -933,18 +957,18 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, v=
oid *data)
 {
 	struct ixgbe_q_vector *q_vector =3D data;
 	struct ixgbe_adapter  *adapter =3D q_vector->adapter;
-	struct ixgbe_ring  *rxr;
+	struct ixgbe_ring  *rx_ring;
 	int r_idx;
=20
 	r_idx =3D find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
=20
-	rxr =3D &(adapter->rx_ring[r_idx]);
+	rx_ring =3D &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->v_idx);
-	rxr->total_bytes =3D 0;
-	rxr->total_packets =3D 0;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
+	rx_ring->total_bytes =3D 0;
+	rx_ring->total_packets =3D 0;
 	netif_rx_schedule(adapter->netdev, &q_vector->napi);
=20
 	return IRQ_HANDLED;
@@ -969,18 +993,18 @@ static int ixgbe_clean_rxonly(struct napi_struct =
*napi, int budget)
 	struct ixgbe_q_vector *q_vector =3D
 			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter =3D q_vector->adapter;
-	struct ixgbe_ring *rxr;
+	struct ixgbe_ring *rx_ring;
 	int work_done =3D 0;
 	long r_idx;
=20
 	r_idx =3D find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	rxr =3D &(adapter->rx_ring[r_idx]);
-#ifdef CONFIG_DCA
+	rx_ring =3D &(adapter->rx_ring[r_idx]);
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_rx_dca(adapter, rxr);
+		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
=20
-	ixgbe_clean_rx_irq(adapter, rxr, &work_done, budget);
+	ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
=20
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
@@ -988,7 +1012,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *=
napi, int budget)
 		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rxr->v_idx);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
 	}
=20
 	return work_done;
@@ -1347,26 +1371,31 @@ static void ixgbe_configure_msi_and_legacy(stru=
ct ixgbe_adapter *adapter)
 }
=20
 /**
- * ixgbe_configure_tx - Configure 8254x Transmit Unit after Reset
+ * ixgbe_configure_tx - Configure 8259x Transmit Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Tx unit of the MAC after a reset.
  **/
 static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
-	u64 tdba;
+	u64 tdba, tdwba;
 	struct ixgbe_hw *hw =3D &adapter->hw;
 	u32 i, j, tdlen, txctrl;
=20
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
-		j =3D adapter->tx_ring[i].reg_idx;
-		tdba =3D adapter->tx_ring[i].dma;
-		tdlen =3D adapter->tx_ring[i].count *
-			sizeof(union ixgbe_adv_tx_desc);
+		struct ixgbe_ring *ring =3D &adapter->tx_ring[i];
+		j =3D ring->reg_idx;
+		tdba =3D ring->dma;
+		tdlen =3D ring->count * sizeof(union ixgbe_adv_tx_desc);
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
-				(tdba & DMA_32BIT_MASK));
+		                (tdba & DMA_32BIT_MASK));
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
+		tdwba =3D ring->dma +
+		        (ring->count * sizeof(union ixgbe_adv_tx_desc));
+		tdwba |=3D IXGBE_TDWBAL_HEAD_WB_ENABLE;
+		IXGBE_WRITE_REG(hw, IXGBE_TDWBAL(j), tdwba & DMA_32BIT_MASK);
+		IXGBE_WRITE_REG(hw, IXGBE_TDWBAH(j), (tdwba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
@@ -1375,16 +1404,62 @@ static void ixgbe_configure_tx(struct ixgbe_ada=
pter *adapter)
 		/* Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
 		 */
-		txctrl =3D IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		txctrl =3D IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
 		txctrl &=3D ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), txctrl);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
 	}
 }
=20
-#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT	2
+
+static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int =
index)
+{
+	struct ixgbe_ring *rx_ring;
+	u32 srrctl;
+	int queue0;
+	unsigned long mask;
+
+	/* program one srrctl register per VMDq index */
+	if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED) {
+		long shift, len;
+		mask =3D (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
+		len =3D sizeof(adapter->ring_feature[RING_F_VMDQ].mask) * 8;
+		shift =3D find_first_bit(&mask, len);
+		queue0 =3D index & mask;
+		index =3D (index & mask) >> shift;
+	/* program one srrctl per RSS queue since RDRXCTL.MVMEN is enabled */
+	} else {
+		mask =3D (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
+		queue0 =3D index & mask;
+		index =3D index & mask;
+	}
+
+	rx_ring =3D &adapter->rx_ring[queue0];
+
+	srrctl =3D IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(index));
+
+	srrctl &=3D ~IXGBE_SRRCTL_BSIZEHDR_MASK;
+	srrctl &=3D ~IXGBE_SRRCTL_BSIZEPKT_MASK;
+
+	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+		srrctl |=3D IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		srrctl |=3D IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+		srrctl |=3D ((IXGBE_RX_HDR_SIZE <<
+			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+			   IXGBE_SRRCTL_BSIZEHDR_MASK);
+	} else {
+		srrctl |=3D IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
+
+		if (rx_ring->rx_buf_len =3D=3D MAXIMUM_ETHERNET_VLAN_SIZE)
+			srrctl |=3D IXGBE_RXBUFFER_2048 >>
+			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		else
+			srrctl |=3D rx_ring->rx_buf_len >>
+			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	}
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
+}
=20
-#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
 /**
  * ixgbe_get_skb_hdr - helper function for LRO header processing
  * @skb: pointer to sk_buff to be added to LRO packet
@@ -1399,8 +1474,8 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb,=
 void **iphdr, void **tcph,
 	union ixgbe_adv_rx_desc *rx_desc =3D priv;
=20
 	/* Verify that this is a valid IPv4 TCP packet */
-	if (!(rx_desc->wb.lower.lo_dword.pkt_info &
-	    (IXGBE_RXDADV_PKTTYPE_IPV4 | IXGBE_RXDADV_PKTTYPE_TCP)))
+	if (!((ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_IPV4) &&
+	     (ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_TCP)))
 		return -1;
=20
 	/* Set network headers */
@@ -1412,8 +1487,11 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb=
, void **iphdr, void **tcph,
 	return 0;
 }
=20
+#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
+			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+
 /**
- * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
+ * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Rx unit of the MAC after a reset.
@@ -1426,10 +1504,14 @@ static void ixgbe_configure_rx(struct ixgbe_ada=
pter *adapter)
 	int max_frame =3D netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, j;
 	u32 rdlen, rxctrl, rxcsum;
-	u32 random[10];
+	static const u32 seed[10] =3D { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
+	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
+	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 fctrl, hlreg0;
 	u32 pages;
-	u32 reta =3D 0, mrqc, srrctl;
+	u32 reta =3D 0, mrqc;
+	u32 rdrxctl;
+	int rx_buf_len;
=20
 	/* Decide whether to use packet split mode or not */
 	if (netdev->mtu > ETH_DATA_LEN)
@@ -1439,12 +1521,12 @@ static void ixgbe_configure_rx(struct ixgbe_ada=
pter *adapter)
=20
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		adapter->rx_buf_len =3D IXGBE_RX_HDR_SIZE;
+		rx_buf_len =3D IXGBE_RX_HDR_SIZE;
 	} else {
 		if (netdev->mtu <=3D ETH_DATA_LEN)
-			adapter->rx_buf_len =3D MAXIMUM_ETHERNET_VLAN_SIZE;
+			rx_buf_len =3D MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
-			adapter->rx_buf_len =3D ALIGN(max_frame, 1024);
+			rx_buf_len =3D ALIGN(max_frame, 1024);
 	}
=20
 	fctrl =3D IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
@@ -1461,28 +1543,6 @@ static void ixgbe_configure_rx(struct ixgbe_adap=
ter *adapter)
=20
 	pages =3D PAGE_USE_COUNT(adapter->netdev->mtu);
=20
-	srrctl =3D IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(0));
-	srrctl &=3D ~IXGBE_SRRCTL_BSIZEHDR_MASK;
-	srrctl &=3D ~IXGBE_SRRCTL_BSIZEPKT_MASK;
-
-	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		srrctl |=3D PAGE_SIZE >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-		srrctl |=3D IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
-		srrctl |=3D ((IXGBE_RX_HDR_SIZE <<
-			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-			   IXGBE_SRRCTL_BSIZEHDR_MASK);
-	} else {
-		srrctl |=3D IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
-
-		if (adapter->rx_buf_len =3D=3D MAXIMUM_ETHERNET_VLAN_SIZE)
-			srrctl |=3D
-			     IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-		else
-			srrctl |=3D
-			     adapter->rx_buf_len >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-	}
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(0), srrctl);
-
 	rdlen =3D adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc)=
;
 	/* disable receives while setting up the descriptors */
 	rxctrl =3D IXGBE_READ_REG(hw, IXGBE_RXCTRL);
@@ -1492,25 +1552,43 @@ static void ixgbe_configure_rx(struct ixgbe_ada=
pter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 		rdba =3D adapter->rx_ring[i].dma;
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(i), (rdba & DMA_32BIT_MASK));
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(i), (rdba >> 32));
-		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(i), rdlen);
-		IXGBE_WRITE_REG(hw, IXGBE_RDH(i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RDT(i), 0);
-		adapter->rx_ring[i].head =3D IXGBE_RDH(i);
-		adapter->rx_ring[i].tail =3D IXGBE_RDT(i);
-	}
-
-	/* Intitial LRO Settings */
-	adapter->rx_ring[i].lro_mgr.max_aggr =3D IXGBE_MAX_LRO_AGGREGATE;
-	adapter->rx_ring[i].lro_mgr.max_desc =3D IXGBE_MAX_LRO_DESCRIPTORS;
-	adapter->rx_ring[i].lro_mgr.get_skb_header =3D ixgbe_get_skb_hdr;
-	adapter->rx_ring[i].lro_mgr.features =3D LRO_F_EXTRACT_VLAN_ID;
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		adapter->rx_ring[i].lro_mgr.features |=3D LRO_F_NAPI;
-	adapter->rx_ring[i].lro_mgr.dev =3D adapter->netdev;
-	adapter->rx_ring[i].lro_mgr.ip_summed =3D CHECKSUM_UNNECESSARY;
-	adapter->rx_ring[i].lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
+		j =3D adapter->rx_ring[i].reg_idx;
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(j), (rdba >> 32));
+		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(j), rdlen);
+		IXGBE_WRITE_REG(hw, IXGBE_RDH(j), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RDT(j), 0);
+		adapter->rx_ring[i].head =3D IXGBE_RDH(j);
+		adapter->rx_ring[i].tail =3D IXGBE_RDT(j);
+		adapter->rx_ring[i].rx_buf_len =3D rx_buf_len;
+		/* Intitial LRO Settings */
+		adapter->rx_ring[i].lro_mgr.max_aggr =3D IXGBE_MAX_LRO_AGGREGATE;
+		adapter->rx_ring[i].lro_mgr.max_desc =3D IXGBE_MAX_LRO_DESCRIPTORS;
+		adapter->rx_ring[i].lro_mgr.get_skb_header =3D ixgbe_get_skb_hdr;
+		adapter->rx_ring[i].lro_mgr.features =3D LRO_F_EXTRACT_VLAN_ID;
+		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+			adapter->rx_ring[i].lro_mgr.features |=3D LRO_F_NAPI;
+		adapter->rx_ring[i].lro_mgr.dev =3D adapter->netdev;
+		adapter->rx_ring[i].lro_mgr.ip_summed =3D CHECKSUM_UNNECESSARY;
+		adapter->rx_ring[i].lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
+
+		ixgbe_configure_srrctl(adapter, j);
+	}
+
+	/*
+	 * For VMDq support of different descriptor types or
+	 * buffer sizes through the use of multiple SRRCTL
+	 * registers, RDRXCTL.MVMEN must be set to 1
+	 *
+	 * also, the manual doesn't mention it clearly but DCA hints
+	 * will only use queue 0's tags unless this bit is set.  Side
+	 * effects of setting this bit are only that SRRCTL must be
+	 * fully programmed [0..15]
+	 */
+	rdrxctl =3D IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+	rdrxctl |=3D IXGBE_RDRXCTL_MVMEN;
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+
=20
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
@@ -1525,22 +1603,20 @@ static void ixgbe_configure_rx(struct ixgbe_ada=
pter *adapter)
 		}
=20
 		/* Fill out hash function seeds */
-		/* XXX use a random constant here to glue certain flows */
-		get_random_bytes(&random[0], 40);
 		for (i =3D 0; i < 10; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), random[i]);
+			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
=20
 		mrqc =3D IXGBE_MRQC_RSSEN
 		    /* Perform hash on these packet types */
-		    | IXGBE_MRQC_RSS_FIELD_IPV4
-		    | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX
-		    | IXGBE_MRQC_RSS_FIELD_IPV6
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
+		       | IXGBE_MRQC_RSS_FIELD_IPV4
+		       | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX
+		       | IXGBE_MRQC_RSS_FIELD_IPV6
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 	}
=20
@@ -1621,23 +1697,37 @@ static void ixgbe_restore_vlan(struct ixgbe_ada=
pter *adapter)
 	}
 }
=20
+static u8 *ixgbe_addr_list_itr(struct ixgbe_hw *hw, u8 **mc_addr_ptr, =
u32 *vmdq)
+{
+	struct dev_mc_list *mc_ptr;
+	u8 *addr =3D *mc_addr_ptr;
+	*vmdq =3D 0;
+
+	mc_ptr =3D container_of(addr, struct dev_mc_list, dmi_addr[0]);
+	if (mc_ptr->next)
+		*mc_addr_ptr =3D mc_ptr->next->dmi_addr;
+	else
+		*mc_addr_ptr =3D NULL;
+
+	return addr;
+}
+
 /**
- * ixgbe_set_multi - Multicast and Promiscuous mode set
+ * ixgbe_set_rx_mode - Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
- * promiscuous mode, and all-multi behavior.
+ * The set_rx_method entry point is called whenever the unicast/multic=
ast
+ * address list or the network interface flags are updated.  This rout=
ine is
+ * responsible for configuring the hardware for proper unicast, multic=
ast and
+ * promiscuous mode.
  **/
-static void ixgbe_set_multi(struct net_device *netdev)
+static void ixgbe_set_rx_mode(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
 	struct ixgbe_hw *hw =3D &adapter->hw;
-	struct dev_mc_list *mc_ptr;
-	u8 *mta_list;
 	u32 fctrl, vlnctrl;
-	int i;
+	u8 *addr_list =3D NULL;
+	int addr_count =3D 0;
=20
 	/* Check for Promiscuous and All Multicast modes */
=20
@@ -1645,6 +1735,7 @@ static void ixgbe_set_multi(struct net_device *ne=
tdev)
 	vlnctrl =3D IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
=20
 	if (netdev->flags & IFF_PROMISC) {
+		hw->addr_ctrl.user_set_promisc =3D 1;
 		fctrl |=3D (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		vlnctrl &=3D ~IXGBE_VLNCTRL_VFE;
 	} else {
@@ -1655,33 +1746,25 @@ static void ixgbe_set_multi(struct net_device *=
netdev)
 			fctrl &=3D ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
 		vlnctrl |=3D IXGBE_VLNCTRL_VFE;
+		hw->addr_ctrl.user_set_promisc =3D 0;
 	}
=20
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
=20
-	if (netdev->mc_count) {
-		mta_list =3D kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);
-		if (!mta_list)
-			return;
-
-		/* Shared function expects packed array of only addresses. */
-		mc_ptr =3D netdev->mc_list;
-
-		for (i =3D 0; i < netdev->mc_count; i++) {
-			if (!mc_ptr)
-				break;
-			memcpy(mta_list + (i * ETH_ALEN), mc_ptr->dmi_addr,
-			       ETH_ALEN);
-			mc_ptr =3D mc_ptr->next;
-		}
-
-		ixgbe_update_mc_addr_list(hw, mta_list, i, 0);
-		kfree(mta_list);
-	} else {
-		ixgbe_update_mc_addr_list(hw, NULL, 0, 0);
-	}
+	/* reprogram secondary unicast list */
+	addr_count =3D netdev->uc_count;
+	if (addr_count)
+		addr_list =3D netdev->uc_list->dmi_addr;
+	ixgbe_update_uc_addr_list(hw, addr_list, addr_count,
+	                          ixgbe_addr_list_itr);
=20
+	/* reprogram multicast list */
+	addr_count =3D netdev->mc_count;
+	if (addr_count)
+		addr_list =3D netdev->mc_list->dmi_addr;
+	ixgbe_update_mc_addr_list(hw, addr_list, addr_count,
+	                          ixgbe_addr_list_itr);
 }
=20
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -1725,7 +1808,7 @@ static void ixgbe_configure(struct ixgbe_adapter =
*adapter)
 	struct net_device *netdev =3D adapter->netdev;
 	int i;
=20
-	ixgbe_set_multi(netdev);
+	ixgbe_set_rx_mode(netdev);
=20
 	ixgbe_restore_vlan(adapter);
=20
@@ -1778,6 +1861,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter=
 *adapter)
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
 		j =3D adapter->tx_ring[i].reg_idx;
 		txdctl =3D IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		/* enable WTHRESH=3D8 descriptors, to encourage burst writeback */
+		txdctl |=3D (8 << 16);
 		txdctl |=3D IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
@@ -1901,7 +1986,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adap=
ter *adapter,
 		rx_buffer_info =3D &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 adapter->rx_buf_len,
+					 rx_ring->rx_buf_len,
 					 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma =3D 0;
 		}
@@ -2017,11 +2102,28 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
=20
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
+		adapter->flags &=3D ~IXGBE_FLAG_DCA_ENABLED;
+		dca_remove_requester(&adapter->pdev->dev);
+	}
+
+#endif
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
=20
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+	/* since we reset the hardware DCA settings were cleared */
+	if (dca_add_requester(&adapter->pdev->dev) =3D=3D 0) {
+		adapter->flags |=3D IXGBE_FLAG_DCA_ENABLED;
+		/* always use CB2 mode, difference is masked
+		 * in the CB driver */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+		ixgbe_setup_dca(adapter);
+	}
+#endif
 }
=20
 static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -2076,7 +2178,7 @@ static int ixgbe_poll(struct napi_struct *napi, i=
nt budget)
 	struct ixgbe_adapter *adapter =3D q_vector->adapter;
 	int tx_cleaned =3D 0, work_done =3D 0;
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
@@ -2449,8 +2551,12 @@ static int __devinit ixgbe_sw_init(struct ixgbe_=
adapter *adapter)
 	adapter->tx_eitr =3D 1;
=20
 	/* default flow control settings */
-	hw->fc.original_type =3D ixgbe_fc_full;
-	hw->fc.type =3D ixgbe_fc_full;
+	hw->fc.original_type =3D ixgbe_fc_none;
+	hw->fc.type =3D ixgbe_fc_none;
+	hw->fc.high_water =3D IXGBE_DEFAULT_FCRTH;
+	hw->fc.low_water =3D IXGBE_DEFAULT_FCRTL;
+	hw->fc.pause_time =3D IXGBE_DEFAULT_FCPAUSE;
+	hw->fc.send_xon =3D true;
=20
 	/* select 10G link by default */
 	hw->mac.link_mode_select =3D IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
@@ -2481,93 +2587,94 @@ static int __devinit ixgbe_sw_init(struct ixgbe=
_adapter *adapter)
 /**
  * ixgbe_setup_tx_resources - allocate Tx resources (Descriptors)
  * @adapter: board private structure
- * @txdr:    tx descriptor ring (for a specific queue) to setup
+ * @tx_ring:    tx descriptor ring (for a specific queue) to setup
  *
  * Return 0 on success, negative on failure
  **/
 int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *txdr)
+                             struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev =3D adapter->pdev;
 	int size;
=20
-	size =3D sizeof(struct ixgbe_tx_buffer) * txdr->count;
-	txdr->tx_buffer_info =3D vmalloc(size);
-	if (!txdr->tx_buffer_info) {
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the transmit descriptor ring\n");
-		return -ENOMEM;
-	}
-	memset(txdr->tx_buffer_info, 0, size);
+	size =3D sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
+	tx_ring->tx_buffer_info =3D vmalloc(size);
+	if (!tx_ring->tx_buffer_info)
+		goto err;
+	memset(tx_ring->tx_buffer_info, 0, size);
=20
 	/* round up to nearest 4K */
-	txdr->size =3D txdr->count * sizeof(union ixgbe_adv_tx_desc);
-	txdr->size =3D ALIGN(txdr->size, 4096);
-
-	txdr->desc =3D pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if (!txdr->desc) {
-		vfree(txdr->tx_buffer_info);
-		DPRINTK(PROBE, ERR,
-			"Memory allocation failed for the tx desc ring\n");
-		return -ENOMEM;
-	}
+	tx_ring->size =3D tx_ring->count * sizeof(union ixgbe_adv_tx_desc) +
+	                sizeof(u32);
+	tx_ring->size =3D ALIGN(tx_ring->size, 4096);
=20
-	txdr->next_to_use =3D 0;
-	txdr->next_to_clean =3D 0;
-	txdr->work_limit =3D txdr->count;
+	tx_ring->desc =3D pci_alloc_consistent(pdev, tx_ring->size,
+	                                     &tx_ring->dma);
+	if (!tx_ring->desc)
+		goto err;
=20
+	tx_ring->next_to_use =3D 0;
+	tx_ring->next_to_clean =3D 0;
+	tx_ring->work_limit =3D tx_ring->count;
 	return 0;
+
+err:
+	vfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info =3D NULL;
+	DPRINTK(PROBE, ERR, "Unable to allocate memory for the transmit "
+	                    "descriptor ring\n");
+	return -ENOMEM;
 }
=20
 /**
  * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
  * @adapter: board private structure
- * @rxdr:    rx descriptor ring (for a specific queue) to setup
+ * @rx_ring:    rx descriptor ring (for a specific queue) to setup
  *
  * Returns 0 on success, negative on failure
  **/
 int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rxdr)
+			     struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev =3D adapter->pdev;
 	int size;
=20
 	size =3D sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
-	rxdr->lro_mgr.lro_arr =3D vmalloc(size);
-	if (!rxdr->lro_mgr.lro_arr)
+	rx_ring->lro_mgr.lro_arr =3D vmalloc(size);
+	if (!rx_ring->lro_mgr.lro_arr)
 		return -ENOMEM;
-	memset(rxdr->lro_mgr.lro_arr, 0, size);
+	memset(rx_ring->lro_mgr.lro_arr, 0, size);
=20
-	size =3D sizeof(struct ixgbe_rx_buffer) * rxdr->count;
-	rxdr->rx_buffer_info =3D vmalloc(size);
-	if (!rxdr->rx_buffer_info) {
+	size =3D sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
+	rx_ring->rx_buffer_info =3D vmalloc(size);
+	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 			"vmalloc allocation failed for the rx desc ring\n");
 		goto alloc_failed;
 	}
-	memset(rxdr->rx_buffer_info, 0, size);
+	memset(rx_ring->rx_buffer_info, 0, size);
=20
 	/* Round up to nearest 4K */
-	rxdr->size =3D rxdr->count * sizeof(union ixgbe_adv_rx_desc);
-	rxdr->size =3D ALIGN(rxdr->size, 4096);
+	rx_ring->size =3D rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
+	rx_ring->size =3D ALIGN(rx_ring->size, 4096);
=20
-	rxdr->desc =3D pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	rx_ring->desc =3D pci_alloc_consistent(pdev, rx_ring->size, &rx_ring-=
>dma);
=20
-	if (!rxdr->desc) {
+	if (!rx_ring->desc) {
 		DPRINTK(PROBE, ERR,
 			"Memory allocation failed for the rx desc ring\n");
-		vfree(rxdr->rx_buffer_info);
+		vfree(rx_ring->rx_buffer_info);
 		goto alloc_failed;
 	}
=20
-	rxdr->next_to_clean =3D 0;
-	rxdr->next_to_use =3D 0;
+	rx_ring->next_to_clean =3D 0;
+	rx_ring->next_to_use =3D 0;
=20
 	return 0;
=20
 alloc_failed:
-	vfree(rxdr->lro_mgr.lro_arr);
-	rxdr->lro_mgr.lro_arr =3D NULL;
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr =3D NULL;
 	return -ENOMEM;
 }
=20
@@ -2579,7 +2686,7 @@ alloc_failed:
  * Free all transmit software resources
  **/
 static void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *tx_ring)
+                                    struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev =3D adapter->pdev;
=20
@@ -3024,6 +3131,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapte=
r,
 		mss_l4len_idx |=3D
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |=3D (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
+		/* use index 1 for TSO */
+		mss_l4len_idx |=3D (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		context_desc->mss_l4len_idx =3D cpu_to_le32(mss_l4len_idx);
=20
 		tx_buffer_info->time_stamp =3D jiffies;
@@ -3096,6 +3205,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *a=
dapter,
 		}
=20
 		context_desc->type_tucmd_mlhl =3D cpu_to_le32(type_tucmd_mlhl);
+		/* use index zero for tx checksum offload */
 		context_desc->mss_l4len_idx =3D 0;
=20
 		tx_buffer_info->time_stamp =3D jiffies;
@@ -3204,6 +3314,8 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *=
adapter,
 		olinfo_status |=3D IXGBE_TXD_POPTS_TXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;
=20
+		/* use index 1 context for tso */
+		olinfo_status |=3D (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |=3D IXGBE_TXD_POPTS_IXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;
@@ -3510,7 +3622,8 @@ static int __devinit ixgbe_probe(struct pci_dev *=
pdev,
 	netdev->stop =3D &ixgbe_close;
 	netdev->hard_start_xmit =3D &ixgbe_xmit_frame;
 	netdev->get_stats =3D &ixgbe_get_stats;
-	netdev->set_multicast_list =3D &ixgbe_set_multi;
+	netdev->set_rx_mode =3D &ixgbe_set_rx_mode;
+	netdev->set_multicast_list =3D &ixgbe_set_rx_mode;
 	netdev->set_mac_address =3D &ixgbe_set_mac;
 	netdev->change_mtu =3D &ixgbe_change_mtu;
 	ixgbe_set_ethtool_ops(netdev);
@@ -3550,18 +3663,19 @@ static int __devinit ixgbe_probe(struct pci_dev=
 *pdev,
 		goto err_sw_init;
=20
 	netdev->features =3D NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
+			   NETIF_F_IP_CSUM |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_LRO;
+	netdev->features |=3D NETIF_F_IPV6_CSUM;
 	netdev->features |=3D NETIF_F_TSO;
 	netdev->features |=3D NETIF_F_TSO6;
+	netdev->features |=3D NETIF_F_LRO;
=20
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
-	netdev->vlan_features |=3D NETIF_F_HW_CSUM;
+	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
 	netdev->vlan_features |=3D NETIF_F_SG;
=20
 	if (pci_using_dac)
@@ -3588,13 +3702,6 @@ static int __devinit ixgbe_probe(struct pci_dev =
*pdev,
=20
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
=20
-	/* initialize default flow control settings */
-	hw->fc.original_type =3D ixgbe_fc_full;
-	hw->fc.type =3D ixgbe_fc_full;
-	hw->fc.high_water =3D IXGBE_DEFAULT_FCRTH;
-	hw->fc.low_water =3D IXGBE_DEFAULT_FCRTL;
-	hw->fc.pause_time =3D IXGBE_DEFAULT_FCPAUSE;
-
 	err =3D ixgbe_init_interrupt_scheme(adapter);
 	if (err)
 		goto err_sw_init;
@@ -3641,7 +3748,7 @@ static int __devinit ixgbe_probe(struct pci_dev *=
pdev,
 	if (err)
 		goto err_register;
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (dca_add_requester(&pdev->dev) =3D=3D 0) {
 		adapter->flags |=3D IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
@@ -3691,7 +3798,7 @@ static void __devexit ixgbe_remove(struct pci_dev=
 *pdev)
=20
 	flush_scheduled_work();
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &=3D ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
@@ -3824,7 +3931,7 @@ static int __init ixgbe_init_module(void)
=20
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	dca_register_notify(&dca_notifier);
=20
 #endif
@@ -3841,13 +3948,13 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 }
=20
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long e=
vent,
 			    void *p)
 {
@@ -3858,7 +3965,7 @@ static int ixgbe_notify_dca(struct notifier_block=
 *nb, unsigned long event,
=20
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
=20
 module_exit(ixgbe_exit_module);
=20
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_t=
ype.h
index c0282a2..3e9c483 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -356,12 +356,10 @@
 #define IXGBE_ANLP2     0x042B4
 #define IXGBE_ATLASCTL  0x04800
=20
-/* RSCCTL Bit Masks */
-#define IXGBE_RSCCTL_RSCEN          0x01
-#define IXGBE_RSCCTL_MAXDESC_1      0x00
-#define IXGBE_RSCCTL_MAXDESC_4      0x04
-#define IXGBE_RSCCTL_MAXDESC_8      0x08
-#define IXGBE_RSCCTL_MAXDESC_16     0x0C
+/* RDRXCTL Bit Masks */
+#define IXGBE_RDRXCTL_RDMTS_1_2     0x00000000 /* Rx Desc Min Threshol=
d Size */
+#define IXGBE_RDRXCTL_MVMEN         0x00000020
+#define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done =
*/
=20
 /* CTRL Bit Masks */
 #define IXGBE_CTRL_GIO_DIS      0x00000004 /* Global IO Master Disable=
 bit */
@@ -822,10 +820,6 @@
 #define IXGBE_RAH_VIND_SHIFT    18
 #define IXGBE_RAH_AV            0x80000000
=20
-/* Filters */
-#define IXGBE_MC_TBL_SIZE       128  /* Multicast Filter Table (4096 b=
its) */
-#define IXGBE_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bit=
s) */
-
 /* Header split receive */
 #define IXGBE_RFCTL_ISCSI_DIS       0x00000001
 #define IXGBE_RFCTL_ISCSI_DWC_MASK  0x0000003E
@@ -1007,15 +1001,15 @@ struct ixgbe_legacy_tx_desc {
 		__le32 data;
 		struct {
 			__le16 length;    /* Data buffer length */
-			u8 cso; /* Checksum offset */
-			u8 cmd; /* Descriptor control */
+			u8 cso;           /* Checksum offset */
+			u8 cmd;           /* Descriptor control */
 		} flags;
 	} lower;
 	union {
 		__le32 data;
 		struct {
 			u8 status;     /* Descriptor status */
-			u8 css; /* Checksum start */
+			u8 css;        /* Checksum start */
 			__le16 vlan;
 		} fields;
 	} upper;
@@ -1039,9 +1033,9 @@ union ixgbe_adv_tx_desc {
 struct ixgbe_legacy_rx_desc {
 	__le64 buffer_addr; /* Address of the descriptor's data buffer */
 	__le16 length;      /* Length of data DMAed into data buffer */
-	u16 csum;        /* Packet checksum */
-	u8 status;       /* Descriptor status */
-	u8 errors;       /* Descriptor Errors */
+	__le16 csum;        /* Packet checksum */
+	u8 status;          /* Descriptor status */
+	u8 errors;          /* Descriptor Errors */
 	__le16 vlan;
 };
=20
@@ -1053,15 +1047,18 @@ union ixgbe_adv_rx_desc {
 	} read;
 	struct {
 		struct {
-			struct {
-				__le16 pkt_info; /* RSS type, Packet type */
-				__le16 hdr_info; /* Split Header, header len */
+			union {
+				__le32 data;
+				struct {
+					__le16 pkt_info; /* RSS type, Packet type */
+					__le16 hdr_info; /* Split Header, header len */
+				} hs_rss;
 			} lo_dword;
 			union {
 				__le32 rss; /* RSS Hash */
 				struct {
 					__le16 ip_id; /* IP id */
-					u16 csum; /* Packet Checksum */
+					__le16 csum; /* Packet Checksum */
 				} csum_ip;
 			} hi_dword;
 		} lower;
@@ -1167,6 +1164,8 @@ struct ixgbe_addr_filter_info {
 	u32 rar_used_count;
 	u32 mc_addr_in_rar_count;
 	u32 mta_in_use;
+	u32 overflow_promisc;
+	bool user_set_promisc;
 };
=20
 /* Flow control parameters */
@@ -1242,6 +1241,10 @@ struct ixgbe_hw_stats {
 /* forward declaration */
 struct ixgbe_hw;
=20
+/* iterator type for walking multicast address lists */
+typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_pt=
r,
+                                  u32 *vmdq);
+
 struct ixgbe_mac_operations {
 	s32 (*reset)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
@@ -1263,9 +1266,11 @@ struct ixgbe_mac_info {
 	u8				addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	u8				perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	s32				mc_filter_type;
+	u32				mcft_size;
+	u32				vft_size;
+	u32				num_rar_entries;
 	u32				num_rx_queues;
 	u32				num_tx_queues;
-	u32				num_rx_addrs;
 	u32				link_attach_type;
 	u32				link_mode_select;
 	bool				link_settings_loaded;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index f684753..d6524db 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -56,7 +56,6 @@
 #include <linux/ethtool.h>
 #include <linux/firmware.h>
 #include <linux/delay.h>
-#include <linux/version.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
 #include <linux/crc32.h>
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index 4ad3e08..b974ca0 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -38,7 +38,6 @@
 #include <asm/io.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/version.h>
=20
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0f6f974..1822491 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -61,6 +61,7 @@ static const int multicast_filter_limit =3D 32;
 /* MAC address length */
 #define MAC_ADDR_LEN	6
=20
+#define MAX_READ_REQUEST_SHIFT	12
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level befo=
re first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -95,6 +96,10 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_04 =3D 0x04, // 8169SB
 	RTL_GIGA_MAC_VER_05 =3D 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 =3D 0x06, // 8110SCe
+	RTL_GIGA_MAC_VER_07 =3D 0x07, // 8102e
+	RTL_GIGA_MAC_VER_08 =3D 0x08, // 8102e
+	RTL_GIGA_MAC_VER_09 =3D 0x09, // 8102e
+	RTL_GIGA_MAC_VER_10 =3D 0x0a, // 8101e
 	RTL_GIGA_MAC_VER_11 =3D 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 =3D 0x0c, // 8168Be
 	RTL_GIGA_MAC_VER_13 =3D 0x0d, // 8101Eb
@@ -121,6 +126,10 @@ static const struct {
 	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_07, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_08, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_09, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_10, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -196,9 +205,6 @@ enum rtl_registers {
 	Config5		=3D 0x56,
 	MultiIntr	=3D 0x5c,
 	PHYAR		=3D 0x60,
-	TBICSR		=3D 0x64,
-	TBI_ANAR	=3D 0x68,
-	TBI_LPAR	=3D 0x6a,
 	PHYstatus	=3D 0x6c,
 	RxMaxSize	=3D 0xda,
 	CPlusCmd	=3D 0xe0,
@@ -212,6 +218,32 @@ enum rtl_registers {
 	FuncForceEvent	=3D 0xfc,
 };
=20
+enum rtl8110_registers {
+	TBICSR			=3D 0x64,
+	TBI_ANAR		=3D 0x68,
+	TBI_LPAR		=3D 0x6a,
+};
+
+enum rtl8168_8101_registers {
+	CSIDR			=3D 0x64,
+	CSIAR			=3D 0x68,
+#define	CSIAR_FLAG			0x80000000
+#define	CSIAR_WRITE_CMD			0x80000000
+#define	CSIAR_BYTE_ENABLE		0x0f
+#define	CSIAR_BYTE_ENABLE_SHIFT		12
+#define	CSIAR_ADDR_MASK			0x0fff
+
+	EPHYAR			=3D 0x80,
+#define	EPHYAR_FLAG			0x80000000
+#define	EPHYAR_WRITE_CMD		0x80000000
+#define	EPHYAR_REG_MASK			0x1f
+#define	EPHYAR_REG_SHIFT		16
+#define	EPHYAR_DATA_MASK		0xffff
+	DBG_REG			=3D 0xd1,
+#define	FIX_NAK_1			(1 << 4)
+#define	FIX_NAK_2			(1 << 3)
+};
+
 enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		=3D 0x8000,
@@ -265,7 +297,13 @@ enum rtl_register_content {
 	TxDMAShift =3D 8,	/* DMA burst value (0-7) is shift this many bits */
=20
 	/* Config1 register p.24 */
+	LEDS1		=3D (1 << 7),
+	LEDS0		=3D (1 << 6),
 	MSIEnable	=3D (1 << 5),	/* Enable Message Signaled Interrupt */
+	Speed_down	=3D (1 << 4),
+	MEMMAP		=3D (1 << 3),
+	IOMAP		=3D (1 << 2),
+	VPD		=3D (1 << 1),
 	PMEnable	=3D (1 << 0),	/* Power Management Enable */
=20
 	/* Config2 register p. 25 */
@@ -275,6 +313,7 @@ enum rtl_register_content {
 	/* Config3 register p.25 */
 	MagicPacket	=3D (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		=3D (1 << 4),	/* Wake up when the cable connection is re-esta=
blished */
+	Beacon_en	=3D (1 << 0),	/* 8168 only. Reserved in the 8168b */
=20
 	/* Config5 register p.27 */
 	BWF		=3D (1 << 6),	/* Accept Broadcast wakeup frame */
@@ -292,7 +331,16 @@ enum rtl_register_content {
 	TBINwComplete	=3D 0x01000000,
=20
 	/* CPlusCmd p.31 */
-	PktCntrDisable	=3D (1 << 7),	// 8168
+	EnableBist	=3D (1 << 15),	// 8168 8101
+	Mac_dbgo_oe	=3D (1 << 14),	// 8168 8101
+	Normal_mode	=3D (1 << 13),	// unused
+	Force_half_dup	=3D (1 << 12),	// 8168 8101
+	Force_rxflow_en	=3D (1 << 11),	// 8168 8101
+	Force_txflow_en	=3D (1 << 10),	// 8168 8101
+	Cxpl_dbg_sel	=3D (1 << 9),	// 8168 8101
+	ASF		=3D (1 << 8),	// 8168 8101
+	PktCntrDisable	=3D (1 << 7),	// 8168 8101
+	Mac_dbgo_sel	=3D 0x001c,	// 8168
 	RxVlan		=3D (1 << 6),
 	RxChkSum	=3D (1 << 5),
 	PCIDAC		=3D (1 << 4),
@@ -370,8 +418,9 @@ struct ring_info {
 };
=20
 enum features {
-	RTL_FEATURE_WOL	=3D (1 << 0),
-	RTL_FEATURE_MSI	=3D (1 << 1),
+	RTL_FEATURE_WOL		=3D (1 << 0),
+	RTL_FEATURE_MSI		=3D (1 << 1),
+	RTL_FEATURE_GMII	=3D (1 << 2),
 };
=20
 struct rtl8169_private {
@@ -406,13 +455,16 @@ struct rtl8169_private {
 	struct vlan_group *vlgrp;
 #endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duple=
x);
-	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
+	int pcie_cap;
 	struct delayed_work task;
 	unsigned features;
+
+	struct mii_if_info mii;
 };
=20
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.or=
g>");
@@ -482,6 +534,94 @@ static int mdio_read(void __iomem *ioaddr, int reg=
_addr)
 	return value;
 }
=20
+static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+{
+	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+}
+
+static void rtl_mdio_write(struct net_device *dev, int phy_id, int loc=
ation,
+			   int val)
+{
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	mdio_write(ioaddr, location, val);
+}
+
+static int rtl_mdio_read(struct net_device *dev, int phy_id, int locat=
ion)
+{
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	return mdio_read(ioaddr, location);
+}
+
+static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int val=
ue)
+{
+	unsigned int i;
+
+	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
+		(reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i =3D 0; i < 100; i++) {
+		if (!(RTL_R32(EPHYAR) & EPHYAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+{
+	u16 value =3D 0xffff;
+	unsigned int i;
+
+	RTL_W32(EPHYAR, (reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i =3D 0; i < 100; i++) {
+		if (RTL_R32(EPHYAR) & EPHYAR_FLAG) {
+			value =3D RTL_R32(EPHYAR) & EPHYAR_DATA_MASK;
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
+static void rtl_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i =3D 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value =3D ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i =3D 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value =3D RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -705,8 +845,12 @@ static int rtl8169_set_speed_xmii(struct net_devic=
e *dev,
 		}
 	}
=20
-	/* The 8100e/8101e do Fast Ethernet only. */
-	if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_13) ||
+	/* The 8100e/8101e/8102e do Fast Ethernet only. */
+	if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_07) ||
+	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_08) ||
+	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_09) ||
+	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_10) ||
+	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_14) ||
 	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_15) ||
 	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_16)) {
@@ -850,7 +994,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_priva=
te *tp, struct RxDesc *desc,
=20
 #endif
=20
-static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cm=
d *cmd)
+static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd=
 *cmd)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -867,65 +1011,29 @@ static void rtl8169_gset_tbi(struct net_device *=
dev, struct ethtool_cmd *cmd)
=20
 	cmd->speed =3D SPEED_1000;
 	cmd->duplex =3D DUPLEX_FULL; /* Always set */
+
+	return 0;
 }
=20
-static void rtl8169_gset_xmii(struct net_device *dev, struct ethtool_c=
md *cmd)
+static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cm=
d *cmd)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
-	void __iomem *ioaddr =3D tp->mmio_addr;
-	u8 status;
-
-	cmd->supported =3D SUPPORTED_10baseT_Half |
-			 SUPPORTED_10baseT_Full |
-			 SUPPORTED_100baseT_Half |
-			 SUPPORTED_100baseT_Full |
-			 SUPPORTED_1000baseT_Full |
-			 SUPPORTED_Autoneg |
-			 SUPPORTED_TP;
-
-	cmd->autoneg =3D 1;
-	cmd->advertising =3D ADVERTISED_TP | ADVERTISED_Autoneg;
-
-	if (tp->phy_auto_nego_reg & ADVERTISE_10HALF)
-		cmd->advertising |=3D ADVERTISED_10baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_10FULL)
-		cmd->advertising |=3D ADVERTISED_10baseT_Full;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100HALF)
-		cmd->advertising |=3D ADVERTISED_100baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100FULL)
-		cmd->advertising |=3D ADVERTISED_100baseT_Full;
-	if (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL)
-		cmd->advertising |=3D ADVERTISED_1000baseT_Full;
-
-	status =3D RTL_R8(PHYstatus);
-
-	if (status & _1000bpsF)
-		cmd->speed =3D SPEED_1000;
-	else if (status & _100bps)
-		cmd->speed =3D SPEED_100;
-	else if (status & _10bps)
-		cmd->speed =3D SPEED_10;
-
-	if (status & TxFlowCtrl)
-		cmd->advertising |=3D ADVERTISED_Asym_Pause;
-	if (status & RxFlowCtrl)
-		cmd->advertising |=3D ADVERTISED_Pause;
-
-	cmd->duplex =3D ((status & _1000bpsF) || (status & FullDup)) ?
-		      DUPLEX_FULL : DUPLEX_HALF;
+
+	return mii_ethtool_gset(&tp->mii, cmd);
 }
=20
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool=
_cmd *cmd)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	unsigned long flags;
+	int rc;
=20
 	spin_lock_irqsave(&tp->lock, flags);
=20
-	tp->get_settings(dev, cmd);
+	rc =3D tp->get_settings(dev, cmd);
=20
 	spin_unlock_irqrestore(&tp->lock, flags);
-	return 0;
+	return rc;
 }
=20
 static void rtl8169_get_regs(struct net_device *dev, struct ethtool_re=
gs *regs,
@@ -1116,8 +1224,17 @@ static void rtl8169_get_mac_version(struct rtl81=
69_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
=20
 		/* 8101 family. */
+		{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x24900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x34800000,	RTL_GIGA_MAC_VER_07 },
+		{ 0x7cf00000, 0x24800000,	RTL_GIGA_MAC_VER_07 },
 		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34300000,	RTL_GIGA_MAC_VER_10 },
 		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34800000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7c800000, 0x24800000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
 		/* FIXME: where did these entries come from ? -- FR */
 		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
@@ -1279,6 +1396,22 @@ static void rtl8168cx_hw_phy_config(void __iomem=
 *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
=20
+static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] =3D {
+		{ 0x1f, 0x0003 },
+		{ 0x08, 0x441d },
+		{ 0x01, 0x9100 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x11, 1 << 12);
+	mdio_patch(ioaddr, 0x19, 1 << 13);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -1296,6 +1429,11 @@ static void rtl_hw_phy_config(struct net_device =
*dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+		rtl8102e_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
@@ -1513,7 +1651,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
-	unsigned msi;
+	unsigned features;
 } rtl_cfg_infos [] =3D {
 	[RTL_CFG_0] =3D {
 		.hw_start	=3D rtl_hw_start_8169,
@@ -1522,7 +1660,7 @@ static const struct rtl_cfg_info {
 		.intr_event	=3D SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	=3D RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		=3D 0
+		.features	=3D RTL_FEATURE_GMII
 	},
 	[RTL_CFG_1] =3D {
 		.hw_start	=3D rtl_hw_start_8168,
@@ -1531,7 +1669,7 @@ static const struct rtl_cfg_info {
 		.intr_event	=3D SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
 		.napi_event	=3D TxErr | TxOK | RxOK | RxOverflow,
-		.msi		=3D RTL_FEATURE_MSI
+		.features	=3D RTL_FEATURE_GMII | RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] =3D {
 		.hw_start	=3D rtl_hw_start_8101,
@@ -1540,7 +1678,7 @@ static const struct rtl_cfg_info {
 		.intr_event	=3D SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	=3D RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		=3D RTL_FEATURE_MSI
+		.features	=3D RTL_FEATURE_MSI
 	}
 };
=20
@@ -1552,7 +1690,7 @@ static unsigned rtl_try_msi(struct pci_dev *pdev,=
 void __iomem *ioaddr,
 	u8 cfg2;
=20
 	cfg2 =3D RTL_R8(Config2) & ~MSIEnable;
-	if (cfg->msi) {
+	if (cfg->features & RTL_FEATURE_MSI) {
 		if (pci_enable_msi(pdev)) {
 			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
 		} else {
@@ -1578,6 +1716,7 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 	const struct rtl_cfg_info *cfg =3D rtl_cfg_infos + ent->driver_data;
 	const unsigned int region =3D cfg->region;
 	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	unsigned int i;
@@ -1602,6 +1741,14 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
 	tp->pci_dev =3D pdev;
 	tp->msg_enable =3D netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT=
);
=20
+	mii =3D &tp->mii;
+	mii->dev =3D dev;
+	mii->mdio_read =3D rtl_mdio_read;
+	mii->mdio_write =3D rtl_mdio_write;
+	mii->phy_id_mask =3D 0x1f;
+	mii->reg_num_mask =3D 0x1f;
+	mii->supports_gmii =3D !!(cfg->features & RTL_FEATURE_GMII);
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc =3D pci_enable_device(pdev);
 	if (rc < 0) {
@@ -1670,6 +1817,10 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
 		goto err_out_free_res_4;
 	}
=20
+	tp->pcie_cap =3D pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (!tp->pcie_cap && netif_msg_probe(tp))
+		dev_info(&pdev->dev, "no PCI Express capability\n");
+
 	/* Unneeded ? Don't mess with Mrs. Murphy. */
 	rtl8169_irq_mask_and_ack(ioaddr);
=20
@@ -2061,12 +2212,51 @@ static void rtl_hw_start_8169(struct net_device=
 *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
=20
+static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+	int cap =3D tp->pcie_cap;
+
+	if (cap) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
+		ctl =3D (ctl & ~PCI_EXP_DEVCTL_READRQ) | force;
+		pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, ctl);
+	}
+}
+
+static void rtl_csi_access_enable(void __iomem *ioaddr)
+{
+	u32 csi;
+
+	csi =3D rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
+	rtl_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+}
+
+struct ephy_info {
+	unsigned int offset;
+	u16 mask;
+	u16 bits;
+};
+
+static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, i=
nt len)
+{
+	u16 w;
+
+	while (len-- > 0) {
+		w =3D (rtl_ephy_read(ioaddr, e->offset) & ~e->mask) | e->bits;
+		rtl_ephy_write(ioaddr, e->offset, w);
+		e++;
+	}
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	struct pci_dev *pdev =3D tp->pci_dev;
-	u8 ctl;
=20
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
=20
@@ -2080,10 +2270,7 @@ static void rtl_hw_start_8168(struct net_device =
*dev)
=20
 	RTL_W16(CPlusCmd, tp->cp_cmd);
=20
-	/* Tx performance tweak. */
-	pci_read_config_byte(pdev, 0x69, &ctl);
-	ctl =3D (ctl & ~0x70) | 0x50;
-	pci_write_config_byte(pdev, 0x69, ctl);
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
=20
 	RTL_W16(IntrMitigate, 0x5151);
=20
@@ -2110,6 +2297,70 @@ static void rtl_hw_start_8168(struct net_device =
*dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
=20
+#define R810X_CPCMD_QUIRK_MASK (\
+	EnableBist | \
+	Mac_dbgo_oe | \
+	Force_half_dup | \
+	Force_half_dup | \
+	Force_txflow_en | \
+	Cxpl_dbg_sel | \
+	ASF | \
+	PktCntrDisable | \
+	PCIDAC | \
+	PCIMulRW)
+
+static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev =
*pdev)
+{
+	static struct ephy_info e_info_8102e_1[] =3D {
+		{ 0x01,	0, 0x6e65 },
+		{ 0x02,	0, 0x091f },
+		{ 0x03,	0, 0xc2f9 },
+		{ 0x06,	0, 0xafb5 },
+		{ 0x07,	0, 0x0e00 },
+		{ 0x19,	0, 0xec80 },
+		{ 0x01,	0, 0x2e65 },
+		{ 0x01,	0, 0x6e65 }
+	};
+	u8 cfg1;
+
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(DBG_REG, FIX_NAK_1);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W8(Config1,
+	       LEDS1 | LEDS0 | Speed_down | MEMMAP | IOMAP | VPD | PMEnable);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	cfg1 =3D RTL_R8(Config1);
+	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
+		RTL_W8(Config1, cfg1 & ~LEDS0);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
+
+	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
+}
+
+static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev =
*pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W8(Config1, MEMMAP | IOMAP | VPD | PMEnable);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
+}
+
+static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev =
*pdev)
+{
+	rtl_hw_start_8102e_2(ioaddr, pdev);
+
+	rtl_ephy_write(ioaddr, 0x03, 0xc2f9);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -2118,8 +2369,26 @@ static void rtl_hw_start_8101(struct net_device =
*dev)
=20
 	if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_16)) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
+		int cap =3D tp->pcie_cap;
+
+		if (cap) {
+			pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL,
+					      PCI_EXP_DEVCTL_NOSNOOP_EN);
+		}
+	}
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+		rtl_hw_start_8102e_1(ioaddr, pdev);
+		break;
+
+	case RTL_GIGA_MAC_VER_08:
+		rtl_hw_start_8102e_3(ioaddr, pdev);
+		break;
+
+	case RTL_GIGA_MAC_VER_09:
+		rtl_hw_start_8102e_2(ioaddr, pdev);
+		break;
 	}
=20
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..243db33 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8175,8 +8175,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
 		    break;
 	}
 	if (sp->config.multiq) {
-	for (i =3D 0; i < sp->config.tx_fifo_num; i++)
-		mac_control->fifos[i].multiq =3D config->multiq;
+		for (i =3D 0; i < sp->config.tx_fifo_num; i++)
+			mac_control->fifos[i].multiq =3D config->multiq;
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support enabled\n",
 			dev->name);
 	} else
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index 2c79d27..d95c218 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -52,9 +52,9 @@
  *
  * The maximum width mask that can be generated is 64 bits.
  */
-#define EFX_MASK64(field)					\
-	(EFX_WIDTH(field) =3D=3D 64 ? ~((u64) 0) :		\
-	 (((((u64) 1) << EFX_WIDTH(field))) - 1))
+#define EFX_MASK64(width)			\
+	((width) =3D=3D 64 ? ~((u64) 0) :		\
+	 (((((u64) 1) << (width))) - 1))
=20
 /* Mask equal in width to the specified field.
  *
@@ -63,9 +63,9 @@
  * The maximum width mask that can be generated is 32 bits.  Use
  * EFX_MASK64 for higher width fields.
  */
-#define EFX_MASK32(field)					\
-	(EFX_WIDTH(field) =3D=3D 32 ? ~((u32) 0) :		\
-	 (((((u32) 1) << EFX_WIDTH(field))) - 1))
+#define EFX_MASK32(width)			\
+	((width) =3D=3D 32 ? ~((u32) 0) :		\
+	 (((((u32) 1) << (width))) - 1))
=20
 /* A doubleword (i.e. 4 byte) datatype - little-endian in HW */
 typedef union efx_dword {
@@ -138,44 +138,49 @@ typedef union efx_oword {
 	EFX_EXTRACT_NATIVE(le32_to_cpu(element), min, max, low, high)
=20
 #define EFX_EXTRACT_OWORD64(oword, low, high)				\
-	(EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
-	 EFX_EXTRACT64((oword).u64[1], 64, 127, low, high))
+	((EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
+	  EFX_EXTRACT64((oword).u64[1], 64, 127, low, high)) &		\
+	 EFX_MASK64(high + 1 - low))
=20
 #define EFX_EXTRACT_QWORD64(qword, low, high)				\
-	EFX_EXTRACT64((qword).u64[0], 0, 63, low, high)
+	(EFX_EXTRACT64((qword).u64[0], 0, 63, low, high) &		\
+	 EFX_MASK64(high + 1 - low))
=20
 #define EFX_EXTRACT_OWORD32(oword, low, high)				\
-	(EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[3], 96, 127, low, high))
+	((EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[3], 96, 127, low, high)) &		\
+	 EFX_MASK32(high + 1 - low))
=20
 #define EFX_EXTRACT_QWORD32(qword, low, high)				\
-	(EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
-	 EFX_EXTRACT32((qword).u32[1], 32, 63, low, high))
+	((EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
+	  EFX_EXTRACT32((qword).u32[1], 32, 63, low, high)) &		\
+	 EFX_MASK32(high + 1 - low))
=20
-#define EFX_EXTRACT_DWORD(dword, low, high)				\
-	EFX_EXTRACT32((dword).u32[0], 0, 31, low, high)
+#define EFX_EXTRACT_DWORD(dword, low, high)			\
+	(EFX_EXTRACT32((dword).u32[0], 0, 31, low, high) &	\
+	 EFX_MASK32(high + 1 - low))
=20
-#define EFX_OWORD_FIELD64(oword, field)					\
-	(EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) =
\
-	 & EFX_MASK64(field))
+#define EFX_OWORD_FIELD64(oword, field)				\
+	EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
=20
-#define EFX_QWORD_FIELD64(qword, field)					\
-	(EFX_EXTRACT_QWORD64(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) =
\
-	 & EFX_MASK64(field))
+#define EFX_QWORD_FIELD64(qword, field)				\
+	EFX_EXTRACT_QWORD64(qword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
=20
-#define EFX_OWORD_FIELD32(oword, field)					\
-	(EFX_EXTRACT_OWORD32(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) =
\
-	 & EFX_MASK32(field))
+#define EFX_OWORD_FIELD32(oword, field)				\
+	EFX_EXTRACT_OWORD32(oword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
=20
-#define EFX_QWORD_FIELD32(qword, field)					\
-	(EFX_EXTRACT_QWORD32(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) =
\
-	 & EFX_MASK32(field))
+#define EFX_QWORD_FIELD32(qword, field)				\
+	EFX_EXTRACT_QWORD32(qword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
=20
-#define EFX_DWORD_FIELD(dword, field)					   \
-	(EFX_EXTRACT_DWORD(dword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK32(field))
+#define EFX_DWORD_FIELD(dword, field)				\
+	EFX_EXTRACT_DWORD(dword, EFX_LOW_BIT(field),		\
+			  EFX_HIGH_BIT(field))
=20
 #define EFX_OWORD_IS_ZERO64(oword)					\
 	(((oword).u64[0] | (oword).u64[1]) =3D=3D (__force __le64) 0)
@@ -411,69 +416,102 @@ typedef union efx_oword {
  * for read-modify-write operations.
  *
  */
-
 #define EFX_INVERT_OWORD(oword) do {		\
 	(oword).u64[0] =3D ~((oword).u64[0]);	\
 	(oword).u64[1] =3D ~((oword).u64[1]);	\
 	} while (0)
=20
-#define EFX_INSERT_FIELD64(...)					\
-	cpu_to_le64(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+#define EFX_AND_OWORD(oword, from, mask)			\
+	do {							\
+		(oword).u64[0] =3D (from).u64[0] & (mask).u64[0];	\
+		(oword).u64[1] =3D (from).u64[1] & (mask).u64[1];	\
+	} while (0)
+
+#define EFX_OR_OWORD(oword, from, mask)				\
+	do {							\
+		(oword).u64[0] =3D (from).u64[0] | (mask).u64[0];	\
+		(oword).u64[1] =3D (from).u64[1] | (mask).u64[1];	\
+	} while (0)
=20
-#define EFX_INSERT_FIELD32(...)					\
-	cpu_to_le32(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+#define EFX_INSERT64(min, max, low, high, value)			\
+	cpu_to_le64(EFX_INSERT_NATIVE(min, max, low, high, value))
=20
-#define EFX_INPLACE_MASK64(min, max, field)			\
-	EFX_INSERT_FIELD64(min, max, field, EFX_MASK64(field))
+#define EFX_INSERT32(min, max, low, high, value)			\
+	cpu_to_le32(EFX_INSERT_NATIVE(min, max, low, high, value))
=20
-#define EFX_INPLACE_MASK32(min, max, field)			\
-	EFX_INSERT_FIELD32(min, max, field, EFX_MASK32(field))
+#define EFX_INPLACE_MASK64(min, max, low, high)				\
+	EFX_INSERT64(min, max, low, high, EFX_MASK64(high + 1 - low))
=20
-#define EFX_SET_OWORD_FIELD64(oword, field, value) do {			\
+#define EFX_INPLACE_MASK32(min, max, low, high)				\
+	EFX_INSERT32(min, max, low, high, EFX_MASK32(high + 1 - low))
+
+#define EFX_SET_OWORD64(oword, low, high, value) do {			\
 	(oword).u64[0] =3D (((oword).u64[0] 				\
-			   & ~EFX_INPLACE_MASK64(0,  63, field))	\
-			  | EFX_INSERT_FIELD64(0,  63, field, value));  \
+			   & ~EFX_INPLACE_MASK64(0,  63, low, high))	\
+			  | EFX_INSERT64(0,  63, low, high, value));	\
 	(oword).u64[1] =3D (((oword).u64[1] 				\
-			   & ~EFX_INPLACE_MASK64(64, 127, field))	\
-			  | EFX_INSERT_FIELD64(64, 127, field, value)); \
+			   & ~EFX_INPLACE_MASK64(64, 127, low, high))	\
+			  | EFX_INSERT64(64, 127, low, high, value));	\
 	} while (0)
=20
-#define EFX_SET_QWORD_FIELD64(qword, field, value) do {			\
+#define EFX_SET_QWORD64(qword, low, high, value) do {			\
 	(qword).u64[0] =3D (((qword).u64[0] 				\
-			   & ~EFX_INPLACE_MASK64(0, 63, field))		\
-			  | EFX_INSERT_FIELD64(0, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK64(0, 63, low, high))	\
+			  | EFX_INSERT64(0, 63, low, high, value));	\
 	} while (0)
=20
-#define EFX_SET_OWORD_FIELD32(oword, field, value) do {			\
+#define EFX_SET_OWORD32(oword, low, high, value) do {			\
 	(oword).u32[0] =3D (((oword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	(oword).u32[1] =3D (((oword).u32[1] 				\
-			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
-			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK32(32, 63, low, high))	\
+			  | EFX_INSERT32(32, 63, low, high, value));	\
 	(oword).u32[2] =3D (((oword).u32[2] 				\
-			   & ~EFX_INPLACE_MASK32(64, 95, field))	\
-			  | EFX_INSERT_FIELD32(64, 95, field, value));	\
+			   & ~EFX_INPLACE_MASK32(64, 95, low, high))	\
+			  | EFX_INSERT32(64, 95, low, high, value));	\
 	(oword).u32[3] =3D (((oword).u32[3] 				\
-			   & ~EFX_INPLACE_MASK32(96, 127, field))	\
-			  | EFX_INSERT_FIELD32(96, 127, field, value));	\
+			   & ~EFX_INPLACE_MASK32(96, 127, low, high))	\
+			  | EFX_INSERT32(96, 127, low, high, value));	\
 	} while (0)
=20
-#define EFX_SET_QWORD_FIELD32(qword, field, value) do {			\
+#define EFX_SET_QWORD32(qword, low, high, value) do {			\
 	(qword).u32[0] =3D (((qword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	(qword).u32[1] =3D (((qword).u32[1] 				\
-			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
-			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK32(32, 63, low, high))	\
+			  | EFX_INSERT32(32, 63, low, high, value));	\
 	} while (0)
=20
-#define EFX_SET_DWORD_FIELD(dword, field, value) do {			\
-	(dword).u32[0] =3D (((dword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+#define EFX_SET_DWORD32(dword, low, high, value) do {			\
+	(dword).u32[0] =3D (((dword).u32[0]				\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	} while (0)
=20
+#define EFX_SET_OWORD_FIELD64(oword, field, value)			\
+	EFX_SET_OWORD64(oword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_QWORD_FIELD64(qword, field, value)			\
+	EFX_SET_QWORD64(qword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_OWORD_FIELD32(oword, field, value)			\
+	EFX_SET_OWORD32(oword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_QWORD_FIELD32(qword, field, value)			\
+	EFX_SET_QWORD32(qword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_DWORD_FIELD(dword, field, value)			\
+	EFX_SET_DWORD32(dword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+
+
 #if BITS_PER_LONG =3D=3D 64
 #define EFX_SET_OWORD_FIELD EFX_SET_OWORD_FIELD64
 #define EFX_SET_QWORD_FIELD EFX_SET_QWORD_FIELD64
@@ -502,4 +540,10 @@ typedef union efx_oword {
 #define EFX_DMA_TYPE_WIDTH(width) \
 	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
=20
+
+/* Static initialiser */
+#define EFX_OWORD32(a, b, c, d)						\
+	{ .u32 =3D { __constant_cpu_to_le32(a), __constant_cpu_to_le32(b), \
+		   __constant_cpu_to_le32(c), __constant_cpu_to_le32(d) } }
+
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index d3d3dd0..99e6023 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -31,23 +31,23 @@ static void blink_led_timer(unsigned long context)
 		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
 }
=20
-static void board_blink(struct efx_nic *efx, int blink)
+static void board_blink(struct efx_nic *efx, bool blink)
 {
 	struct efx_blinker *blinker =3D &efx->board_info.blinker;
=20
 	/* The rtnl mutex serialises all ethtool ioctls, so
 	 * nothing special needs doing here. */
 	if (blink) {
-		blinker->resubmit =3D 1;
-		blinker->state =3D 0;
+		blinker->resubmit =3D true;
+		blinker->state =3D false;
 		setup_timer(&blinker->timer, blink_led_timer,
 			    (unsigned long)efx);
 		mod_timer(&blinker->timer, jiffies + BLINK_INTERVAL);
 	} else {
-		blinker->resubmit =3D 0;
+		blinker->resubmit =3D false;
 		if (blinker->timer.function)
 			del_timer_sync(&blinker->timer);
-		efx->board_info.set_fault_led(efx, 0);
+		efx->board_info.set_fault_led(efx, false);
 	}
 }
=20
@@ -78,7 +78,7 @@ static int sfe4002_init_leds(struct efx_nic *efx)
 	return 0;
 }
=20
-static void sfe4002_fault_led(struct efx_nic *efx, int state)
+static void sfe4002_fault_led(struct efx_nic *efx, bool state)
 {
 	xfp_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
 			QUAKE_LED_OFF);
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index e5e8443..c6e01b6 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -21,7 +21,5 @@ enum efx_board_type {
=20
 extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
 extern int sfe4001_init(struct efx_nic *efx);
-/* Are we putting the PHY into flash config mode */
-extern unsigned int sfe4001_phy_flash_cfg;
=20
 #endif
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 45c72ee..0d47d6f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -28,7 +28,6 @@
 #include "efx.h"
 #include "mdio_10g.h"
 #include "falcon.h"
-#include "workarounds.h"
 #include "mac.h"
=20
 #define EFX_MAX_MTU (9 * 1024)
@@ -52,7 +51,7 @@ static struct workqueue_struct *refill_workqueue;
  * This sets the default for new devices.  It can be controlled later
  * using ethtool.
  */
-static int lro =3D 1;
+static int lro =3D true;
 module_param(lro, int, 0644);
 MODULE_PARM_DESC(lro, "Large receive offload acceleration");
=20
@@ -65,7 +64,7 @@ MODULE_PARM_DESC(lro, "Large receive offload accelera=
tion");
  * This is forced to 0 for MSI interrupt mode as the interrupt vector
  * is not written
  */
-static unsigned int separate_tx_and_rx_channels =3D 1;
+static unsigned int separate_tx_and_rx_channels =3D true;
=20
 /* This is the weight assigned to each of the (per-channel) virtual
  * NAPI devices.
@@ -81,7 +80,7 @@ unsigned int efx_monitor_interval =3D 1 * HZ;
 /* This controls whether or not the hardware monitor will trigger a
  * reset when it detects an error condition.
  */
-static unsigned int monitor_reset =3D 1;
+static unsigned int monitor_reset =3D true;
=20
 /* This controls whether or not the driver will initialise devices
  * with invalid MAC addresses stored in the EEPROM or flash.  If true,
@@ -141,8 +140,7 @@ static void efx_fini_channels(struct efx_nic *efx);
=20
 #define EFX_ASSERT_RESET_SERIALISED(efx)		\
 	do {						\
-		if ((efx->state =3D=3D STATE_RUNNING) ||	\
-		    (efx->state =3D=3D STATE_RESETTING))	\
+		if (efx->state =3D=3D STATE_RUNNING)	\
 			ASSERT_RTNL();			\
 	} while (0)
=20
@@ -159,16 +157,18 @@ static void efx_fini_channels(struct efx_nic *efx=
);
  * never be concurrently called more than once on the same channel,
  * though different channels may be being processed concurrently.
  */
-static inline int efx_process_channel(struct efx_channel *channel, int=
 rx_quota)
+static int efx_process_channel(struct efx_channel *channel, int rx_quo=
ta)
 {
-	int rxdmaqs;
-	struct efx_rx_queue *rx_queue;
+	struct efx_nic *efx =3D channel->efx;
+	int rx_packets;
=20
-	if (unlikely(channel->efx->reset_pending !=3D RESET_TYPE_NONE ||
+	if (unlikely(efx->reset_pending !=3D RESET_TYPE_NONE ||
 		     !channel->enabled))
-		return rx_quota;
+		return 0;
=20
-	rxdmaqs =3D falcon_process_eventq(channel, &rx_quota);
+	rx_packets =3D falcon_process_eventq(channel, rx_quota);
+	if (rx_packets =3D=3D 0)
+		return 0;
=20
 	/* Deliver last RX packet. */
 	if (channel->rx_pkt) {
@@ -180,16 +180,9 @@ static inline int efx_process_channel(struct efx_c=
hannel *channel, int rx_quota)
 	efx_flush_lro(channel);
 	efx_rx_strategy(channel);
=20
-	/* Refill descriptor rings as necessary */
-	rx_queue =3D &channel->efx->rx_queue[0];
-	while (rxdmaqs) {
-		if (rxdmaqs & 0x01)
-			efx_fast_push_rx_descriptors(rx_queue);
-		rx_queue++;
-		rxdmaqs >>=3D 1;
-	}
+	efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
=20
-	return rx_quota;
+	return rx_packets;
 }
=20
 /* Mark channel as finished processing
@@ -203,7 +196,7 @@ static inline void efx_channel_processed(struct efx=
_channel *channel)
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we acknowledge the events we've seen.  Make sure
 	 * it's cleared before then. */
-	channel->work_pending =3D 0;
+	channel->work_pending =3D false;
 	smp_wmb();
=20
 	falcon_eventq_read_ack(channel);
@@ -219,14 +212,12 @@ static int efx_poll(struct napi_struct *napi, int=
 budget)
 	struct efx_channel *channel =3D
 		container_of(napi, struct efx_channel, napi_str);
 	struct net_device *napi_dev =3D channel->napi_dev;
-	int unused;
 	int rx_packets;
=20
 	EFX_TRACE(channel->efx, "channel %d NAPI poll executing on CPU %d\n",
 		  channel->channel, raw_smp_processor_id());
=20
-	unused =3D efx_process_channel(channel, budget);
-	rx_packets =3D (budget - unused);
+	rx_packets =3D efx_process_channel(channel, budget);
=20
 	if (rx_packets < budget) {
 		/* There is no race here; although napi_disable() will
@@ -260,7 +251,7 @@ void efx_process_channel_now(struct efx_channel *ch=
annel)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	if (channel->has_interrupt && channel->irq)
+	if (channel->irq)
 		synchronize_irq(channel->irq);
=20
 	/* Wait for any NAPI processing to complete */
@@ -290,13 +281,13 @@ static int efx_probe_eventq(struct efx_channel *c=
hannel)
 }
=20
 /* Prepare channel's event queue */
-static int efx_init_eventq(struct efx_channel *channel)
+static void efx_init_eventq(struct efx_channel *channel)
 {
 	EFX_LOG(channel->efx, "chan %d init event queue\n", channel->channel)=
;
=20
 	channel->eventq_read_ptr =3D 0;
=20
-	return falcon_init_eventq(channel);
+	falcon_init_eventq(channel);
 }
=20
 static void efx_fini_eventq(struct efx_channel *channel)
@@ -362,12 +353,11 @@ static int efx_probe_channel(struct efx_channel *=
channel)
  * to propagate configuration changes (mtu, checksum offload), or
  * to clear hardware error conditions
  */
-static int efx_init_channels(struct efx_nic *efx)
+static void efx_init_channels(struct efx_nic *efx)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	struct efx_channel *channel;
-	int rc =3D 0;
=20
 	/* Calculate the rx buffer allocation parameters required to
 	 * support the current MTU, including padding for header
@@ -382,36 +372,20 @@ static int efx_init_channels(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx) {
 		EFX_LOG(channel->efx, "init chan %d\n", channel->channel);
=20
-		rc =3D efx_init_eventq(channel);
-		if (rc)
-			goto err;
+		efx_init_eventq(channel);
=20
-		efx_for_each_channel_tx_queue(tx_queue, channel) {
-			rc =3D efx_init_tx_queue(tx_queue);
-			if (rc)
-				goto err;
-		}
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			efx_init_tx_queue(tx_queue);
=20
 		/* The rx buffer allocation strategy is MTU dependent */
 		efx_rx_strategy(channel);
=20
-		efx_for_each_channel_rx_queue(rx_queue, channel) {
-			rc =3D efx_init_rx_queue(rx_queue);
-			if (rc)
-				goto err;
-		}
+		efx_for_each_channel_rx_queue(rx_queue, channel)
+			efx_init_rx_queue(rx_queue);
=20
 		WARN_ON(channel->rx_pkt !=3D NULL);
 		efx_rx_strategy(channel);
 	}
-
-	return 0;
-
- err:
-	EFX_ERR(efx, "failed to initialise channel %d\n",
-		channel ? channel->channel : -1);
-	efx_fini_channels(efx);
-	return rc;
 }
=20
 /* This enables event queue processing and packet transmission.
@@ -432,8 +406,8 @@ static void efx_start_channel(struct efx_channel *c=
hannel)
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
 	 * then.  Similarly, make sure it sees the enabled flag set. */
-	channel->work_pending =3D 0;
-	channel->enabled =3D 1;
+	channel->work_pending =3D false;
+	channel->enabled =3D true;
 	smp_wmb();
=20
 	napi_enable(&channel->napi_str);
@@ -456,7 +430,7 @@ static void efx_stop_channel(struct efx_channel *ch=
annel)
=20
 	EFX_LOG(channel->efx, "stop chan %d\n", channel->channel);
=20
-	channel->enabled =3D 0;
+	channel->enabled =3D false;
 	napi_disable(&channel->napi_str);
=20
 	/* Ensure that any worker threads have exited or will be no-ops */
@@ -526,8 +500,6 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx=
_queue, int delay)
  */
 static void efx_link_status_changed(struct efx_nic *efx)
 {
-	int carrier_ok;
-
 	/* SFC Bug 5356: A net_dev notifier is registered, so we must ensure
 	 * that no events are triggered between unregister_netdev() and the
 	 * driver unloading. A more general condition is that NETDEV_CHANGE
@@ -535,8 +507,12 @@ static void efx_link_status_changed(struct efx_nic=
 *efx)
 	if (!netif_running(efx->net_dev))
 		return;
=20
-	carrier_ok =3D netif_carrier_ok(efx->net_dev) ? 1 : 0;
-	if (efx->link_up !=3D carrier_ok) {
+	if (efx->port_inhibited) {
+		netif_carrier_off(efx->net_dev);
+		return;
+	}
+
+	if (efx->link_up !=3D netif_carrier_ok(efx->net_dev)) {
 		efx->n_link_state_changes++;
=20
 		if (efx->link_up)
@@ -577,13 +553,19 @@ static void efx_link_status_changed(struct efx_ni=
c *efx)
=20
 /* This call reinitialises the MAC to pick up new PHY settings. The
  * caller must hold the mac_lock */
-static void __efx_reconfigure_port(struct efx_nic *efx)
+void __efx_reconfigure_port(struct efx_nic *efx)
 {
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
=20
 	EFX_LOG(efx, "reconfiguring MAC from PHY settings on CPU %d\n",
 		raw_smp_processor_id());
=20
+	/* Serialise the promiscuous flag with efx_set_multicast_list. */
+	if (efx_dev_registered(efx)) {
+		netif_addr_lock_bh(efx->net_dev);
+		netif_addr_unlock_bh(efx->net_dev);
+	}
+
 	falcon_reconfigure_xmac(efx);
=20
 	/* Inform kernel of loss/gain of carrier */
@@ -661,7 +643,8 @@ static int efx_init_port(struct efx_nic *efx)
 	if (rc)
 		return rc;
=20
-	efx->port_initialized =3D 1;
+	efx->port_initialized =3D true;
+	efx->stats_enabled =3D true;
=20
 	/* Reconfigure port to program MAC registers */
 	falcon_reconfigure_xmac(efx);
@@ -678,7 +661,7 @@ static void efx_start_port(struct efx_nic *efx)
 	BUG_ON(efx->port_enabled);
=20
 	mutex_lock(&efx->mac_lock);
-	efx->port_enabled =3D 1;
+	efx->port_enabled =3D true;
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 }
@@ -692,7 +675,7 @@ static void efx_stop_port(struct efx_nic *efx)
 	EFX_LOG(efx, "stop port\n");
=20
 	mutex_lock(&efx->mac_lock);
-	efx->port_enabled =3D 0;
+	efx->port_enabled =3D false;
 	mutex_unlock(&efx->mac_lock);
=20
 	/* Serialise against efx_set_multicast_list() */
@@ -710,9 +693,9 @@ static void efx_fini_port(struct efx_nic *efx)
 		return;
=20
 	falcon_fini_xmac(efx);
-	efx->port_initialized =3D 0;
+	efx->port_initialized =3D false;
=20
-	efx->link_up =3D 0;
+	efx->link_up =3D false;
 	efx_link_status_changed(efx);
 }
=20
@@ -823,53 +806,61 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
=20
-/* Probe the number and type of interrupts we are able to obtain. */
+/* Get number of RX queues wanted.  Return number of online CPU
+ * packages in the expectation that an IRQ balancer will spread
+ * interrupts across them. */
+static int efx_wanted_rx_queues(void)
+{
+	cpumask_t core_mask;
+	int count;
+	int cpu;
+
+	cpus_clear(core_mask);
+	count =3D 0;
+	for_each_online_cpu(cpu) {
+		if (!cpu_isset(cpu, core_mask)) {
+			++count;
+			cpus_or(core_mask, core_mask,
+				topology_core_siblings(cpu));
+		}
+	}
+
+	return count;
+}
+
+/* Probe the number and type of interrupts we are able to obtain, and
+ * the resulting numbers of channels and RX queues.
+ */
 static void efx_probe_interrupts(struct efx_nic *efx)
 {
-	int max_channel =3D efx->type->phys_addr_channels - 1;
-	struct msix_entry xentries[EFX_MAX_CHANNELS];
+	int max_channels =3D
+		min_t(int, efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
 	int rc, i;
=20
 	if (efx->interrupt_mode =3D=3D EFX_INT_MODE_MSIX) {
-		BUG_ON(!pci_find_capability(efx->pci_dev, PCI_CAP_ID_MSIX));
-
-		if (rss_cpus =3D=3D 0) {
-			cpumask_t core_mask;
-			int cpu;
-
-			cpus_clear(core_mask);
-			efx->rss_queues =3D 0;
-			for_each_online_cpu(cpu) {
-				if (!cpu_isset(cpu, core_mask)) {
-					++efx->rss_queues;
-					cpus_or(core_mask, core_mask,
-						topology_core_siblings(cpu));
-				}
-			}
-		} else {
-			efx->rss_queues =3D rss_cpus;
-		}
+		struct msix_entry xentries[EFX_MAX_CHANNELS];
+		int wanted_ints;
=20
-		efx->rss_queues =3D min(efx->rss_queues, max_channel + 1);
-		efx->rss_queues =3D min(efx->rss_queues, EFX_MAX_CHANNELS);
+		/* We want one RX queue and interrupt per CPU package
+		 * (or as specified by the rss_cpus module parameter).
+		 * We will need one channel per interrupt.
+		 */
+		wanted_ints =3D rss_cpus ? rss_cpus : efx_wanted_rx_queues();
+		efx->n_rx_queues =3D min(wanted_ints, max_channels);
=20
-		/* Request maximum number of MSI interrupts, and fill out
-		 * the channel interrupt information the allowed allocation */
-		for (i =3D 0; i < efx->rss_queues; i++)
+		for (i =3D 0; i < efx->n_rx_queues; i++)
 			xentries[i].entry =3D i;
-		rc =3D pci_enable_msix(efx->pci_dev, xentries, efx->rss_queues);
+		rc =3D pci_enable_msix(efx->pci_dev, xentries, efx->n_rx_queues);
 		if (rc > 0) {
-			EFX_BUG_ON_PARANOID(rc >=3D efx->rss_queues);
-			efx->rss_queues =3D rc;
+			EFX_BUG_ON_PARANOID(rc >=3D efx->n_rx_queues);
+			efx->n_rx_queues =3D rc;
 			rc =3D pci_enable_msix(efx->pci_dev, xentries,
-					     efx->rss_queues);
+					     efx->n_rx_queues);
 		}
=20
 		if (rc =3D=3D 0) {
-			for (i =3D 0; i < efx->rss_queues; i++) {
-				efx->channel[i].has_interrupt =3D 1;
+			for (i =3D 0; i < efx->n_rx_queues; i++)
 				efx->channel[i].irq =3D xentries[i].vector;
-			}
 		} else {
 			/* Fall back to single channel MSI */
 			efx->interrupt_mode =3D EFX_INT_MODE_MSI;
@@ -879,11 +870,10 @@ static void efx_probe_interrupts(struct efx_nic *=
efx)
=20
 	/* Try single interrupt MSI */
 	if (efx->interrupt_mode =3D=3D EFX_INT_MODE_MSI) {
-		efx->rss_queues =3D 1;
+		efx->n_rx_queues =3D 1;
 		rc =3D pci_enable_msi(efx->pci_dev);
 		if (rc =3D=3D 0) {
 			efx->channel[0].irq =3D efx->pci_dev->irq;
-			efx->channel[0].has_interrupt =3D 1;
 		} else {
 			EFX_ERR(efx, "could not enable MSI\n");
 			efx->interrupt_mode =3D EFX_INT_MODE_LEGACY;
@@ -892,10 +882,7 @@ static void efx_probe_interrupts(struct efx_nic *e=
fx)
=20
 	/* Assume legacy interrupts */
 	if (efx->interrupt_mode =3D=3D EFX_INT_MODE_LEGACY) {
-		efx->rss_queues =3D 1;
-		/* Every channel is interruptible */
-		for (i =3D 0; i < EFX_MAX_CHANNELS; i++)
-			efx->channel[i].has_interrupt =3D 1;
+		efx->n_rx_queues =3D 1;
 		efx->legacy_irq =3D efx->pci_dev->irq;
 	}
 }
@@ -905,7 +892,7 @@ static void efx_remove_interrupts(struct efx_nic *e=
fx)
 	struct efx_channel *channel;
=20
 	/* Remove MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		channel->irq =3D 0;
 	pci_disable_msi(efx->pci_dev);
 	pci_disable_msix(efx->pci_dev);
@@ -914,45 +901,22 @@ static void efx_remove_interrupts(struct efx_nic =
*efx)
 	efx->legacy_irq =3D 0;
 }
=20
-/* Select number of used resources
- * Should be called after probe_interrupts()
- */
-static void efx_select_used(struct efx_nic *efx)
+static void efx_set_channels(struct efx_nic *efx)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	int i;
-
-	/* TX queues.  One per port per channel with TX capability
-	 * (more than one per port won't work on Linux, due to out
-	 *  of order issues... but will be fine on Solaris)
-	 */
-	tx_queue =3D &efx->tx_queue[0];
=20
-	/* Perform this for each channel with TX capabilities.
-	 * At the moment, we only support a single TX queue
-	 */
-	tx_queue->used =3D 1;
-	if ((!EFX_INT_MODE_USE_MSI(efx)) && separate_tx_and_rx_channels)
-		tx_queue->channel =3D &efx->channel[1];
-	else
-		tx_queue->channel =3D &efx->channel[0];
-	tx_queue->channel->used_flags |=3D EFX_USED_BY_TX;
-	tx_queue++;
-
-	/* RX queues.  Each has a dedicated channel. */
-	for (i =3D 0; i < EFX_MAX_RX_QUEUES; i++) {
-		rx_queue =3D &efx->rx_queue[i];
+	efx_for_each_tx_queue(tx_queue, efx) {
+		if (!EFX_INT_MODE_USE_MSI(efx) && separate_tx_and_rx_channels)
+			tx_queue->channel =3D &efx->channel[1];
+		else
+			tx_queue->channel =3D &efx->channel[0];
+		tx_queue->channel->used_flags |=3D EFX_USED_BY_TX;
+	}
=20
-		if (i < efx->rss_queues) {
-			rx_queue->used =3D 1;
-			/* If we allow multiple RX queues per channel
-			 * we need to decide that here
-			 */
-			rx_queue->channel =3D &efx->channel[rx_queue->queue];
-			rx_queue->channel->used_flags |=3D EFX_USED_BY_RX;
-			rx_queue++;
-		}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		rx_queue->channel =3D &efx->channel[rx_queue->queue];
+		rx_queue->channel->used_flags |=3D EFX_USED_BY_RX;
 	}
 }
=20
@@ -971,8 +935,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 	 * in MSI-X interrupts. */
 	efx_probe_interrupts(efx);
=20
-	/* Determine number of RX queues and TX queues */
-	efx_select_used(efx);
+	efx_set_channels(efx);
=20
 	/* Initialise the interrupt moderation settings */
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec);
@@ -1058,7 +1021,8 @@ static void efx_start_all(struct efx_nic *efx)
 	/* Mark the port as enabled so port reconfigurations can start, then
 	 * restart the transmit interface early so the watchdog timer stops *=
/
 	efx_start_port(efx);
-	efx_wake_queue(efx);
+	if (efx_dev_registered(efx))
+		efx_wake_queue(efx);
=20
 	efx_for_each_channel(channel, efx)
 		efx_start_channel(channel);
@@ -1109,7 +1073,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
 			synchronize_irq(channel->irq);
 	}
@@ -1133,8 +1097,8 @@ static void efx_stop_all(struct efx_nic *efx)
=20
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
-	efx_stop_queue(efx);
 	if (efx_dev_registered(efx)) {
+		efx_stop_queue(efx);
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1151,24 +1115,16 @@ static void efx_remove_all(struct efx_nic *efx)
 }
=20
 /* A convinience function to safely flush all the queues */
-int efx_flush_queues(struct efx_nic *efx)
+void efx_flush_queues(struct efx_nic *efx)
 {
-	int rc;
-
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
 	efx_stop_all(efx);
=20
 	efx_fini_channels(efx);
-	rc =3D efx_init_channels(efx);
-	if (rc) {
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-		return rc;
-	}
+	efx_init_channels(efx);
=20
 	efx_start_all(efx);
-
-	return 0;
 }
=20
 /*********************************************************************=
*****
@@ -1249,7 +1205,7 @@ static void efx_monitor(struct work_struct *data)
  */
 static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, in=
t cmd)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
@@ -1303,10 +1259,10 @@ static void efx_fini_napi(struct efx_nic *efx)
  */
 static void efx_netpoll(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_channel *channel;
=20
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		efx_schedule_channel(channel);
 }
=20
@@ -1321,12 +1277,15 @@ static void efx_netpoll(struct net_device *net_=
dev)
 /* Context: process, rtnl_lock() held. */
 static int efx_net_open(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
 	EFX_LOG(efx, "opening device %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
=20
+	if (efx->phy_mode & PHY_MODE_SPECIAL)
+		return -EBUSY;
+
 	efx_start_all(efx);
 	return 0;
 }
@@ -1337,8 +1296,7 @@ static int efx_net_open(struct net_device *net_de=
v)
  */
 static int efx_net_stop(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
-	int rc;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	EFX_LOG(efx, "closing %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
@@ -1346,9 +1304,7 @@ static int efx_net_stop(struct net_device *net_de=
v)
 	/* Stop the device and flush all the channels */
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
-	rc =3D efx_init_channels(efx);
-	if (rc)
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+	efx_init_channels(efx);
=20
 	return 0;
 }
@@ -1356,7 +1312,7 @@ static int efx_net_stop(struct net_device *net_de=
v)
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
 static struct net_device_stats *efx_net_stats(struct net_device *net_d=
ev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	struct net_device_stats *stats =3D &net_dev->stats;
=20
@@ -1366,7 +1322,7 @@ static struct net_device_stats *efx_net_stats(str=
uct net_device *net_dev)
 	 */
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
-	if (efx->state =3D=3D STATE_RUNNING) {
+	if (efx->stats_enabled) {
 		falcon_update_stats_xmac(efx);
 		falcon_update_nic_stats(efx);
 	}
@@ -1403,7 +1359,7 @@ static struct net_device_stats *efx_net_stats(str=
uct net_device *net_dev)
 /* Context: netif_tx_lock held, BHs disabled. */
 static void efx_watchdog(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	EFX_ERR(efx, "TX stuck with stop_count=3D%d port_enabled=3D%d: %s\n",
 		atomic_read(&efx->netif_stop_count), efx->port_enabled,
@@ -1417,7 +1373,7 @@ static void efx_watchdog(struct net_device *net_d=
ev)
 /* Context: process, rtnl_lock() held. */
 static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	int rc =3D 0;
=20
 	EFX_ASSERT_RESET_SERIALISED(efx);
@@ -1431,21 +1387,15 @@ static int efx_change_mtu(struct net_device *ne=
t_dev, int new_mtu)
=20
 	efx_fini_channels(efx);
 	net_dev->mtu =3D new_mtu;
-	rc =3D efx_init_channels(efx);
-	if (rc)
-		goto fail;
+	efx_init_channels(efx);
=20
 	efx_start_all(efx);
 	return rc;
-
- fail:
-	efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-	return rc;
 }
=20
 static int efx_set_mac_address(struct net_device *net_dev, void *data)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct sockaddr *addr =3D data;
 	char *new_addr =3D addr->sa_data;
=20
@@ -1466,26 +1416,19 @@ static int efx_set_mac_address(struct net_devic=
e *net_dev, void *data)
 	return 0;
 }
=20
-/* Context: netif_tx_lock held, BHs disabled. */
+/* Context: netif_addr_lock held, BHs disabled. */
 static void efx_set_multicast_list(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct dev_mc_list *mc_list =3D net_dev->mc_list;
 	union efx_multicast_hash *mc_hash =3D &efx->multicast_hash;
-	int promiscuous;
+	bool promiscuous =3D !!(net_dev->flags & IFF_PROMISC);
+	bool changed =3D (efx->promiscuous !=3D promiscuous);
 	u32 crc;
 	int bit;
 	int i;
=20
-	/* Set per-MAC promiscuity flag and reconfigure MAC if necessary */
-	promiscuous =3D (net_dev->flags & IFF_PROMISC) ? 1 : 0;
-	if (efx->promiscuous !=3D promiscuous) {
-		efx->promiscuous =3D promiscuous;
-		/* Close the window between efx_stop_port() and efx_flush_all()
-		 * by only queuing work when the port is enabled. */
-		if (efx->port_enabled)
-			queue_work(efx->workqueue, &efx->reconfigure_work);
-	}
+	efx->promiscuous =3D promiscuous;
=20
 	/* Build multicast hash table */
 	if (promiscuous || (net_dev->flags & IFF_ALLMULTI)) {
@@ -1500,6 +1443,13 @@ static void efx_set_multicast_list(struct net_de=
vice *net_dev)
 		}
 	}
=20
+	if (!efx->port_enabled)
+		/* Delay pushing settings until efx_start_port() */
+		return;
+
+	if (changed)
+		queue_work(efx->workqueue, &efx->reconfigure_work);
+
 	/* Create and activate new global multicast hash table */
 	falcon_set_multicast_hash(efx);
 }
@@ -1510,7 +1460,7 @@ static int efx_netdev_event(struct notifier_block=
 *this,
 	struct net_device *net_dev =3D ptr;
=20
 	if (net_dev->open =3D=3D efx_net_open && event =3D=3D NETDEV_CHANGENA=
ME) {
-		struct efx_nic *efx =3D net_dev->priv;
+		struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 		strcpy(efx->name, net_dev->name);
 	}
@@ -1568,7 +1518,7 @@ static void efx_unregister_netdev(struct efx_nic =
*efx)
 	if (!efx->net_dev)
 		return;
=20
-	BUG_ON(efx->net_dev->priv !=3D efx);
+	BUG_ON(netdev_priv(efx->net_dev) !=3D efx);
=20
 	/* Free up any skbs still remaining. This has to happen before
 	 * we try to unregister the netdev as running their destructors
@@ -1588,49 +1538,60 @@ static void efx_unregister_netdev(struct efx_ni=
c *efx)
  *
  *********************************************************************=
*****/
=20
-/* The final hardware and software finalisation before reset. */
-static int efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecm=
d)
+/* Tears down the entire software state and most of the hardware state
+ * before reset.  */
+void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	int rc;
=20
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
+	/* The net_dev->get_stats handler is quite slow, and will fail
+	 * if a fetch is pending over reset. Serialise against it. */
+	spin_lock(&efx->stats_lock);
+	efx->stats_enabled =3D false;
+	spin_unlock(&efx->stats_lock);
+
+	efx_stop_all(efx);
+	mutex_lock(&efx->mac_lock);
+
 	rc =3D falcon_xmac_get_settings(efx, ecmd);
-	if (rc) {
+	if (rc)
 		EFX_ERR(efx, "could not back up PHY settings\n");
-		goto fail;
-	}
=20
 	efx_fini_channels(efx);
-	return 0;
-
- fail:
-	return rc;
 }
=20
-/* The first part of software initialisation after a hardware reset
- * This function does not handle serialisation with the kernel, it
- * assumes the caller has done this */
-static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+/* This function will always ensure that the locks acquired in
+ * efx_reset_down() are released. A failure return code indicates
+ * that we were unable to reinitialise the hardware, and the
+ * driver should be disabled. If ok is false, then the rx and tx
+ * engines are not restarted, pending a RESET_DISABLE. */
+int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool o=
k)
 {
 	int rc;
=20
-	rc =3D efx_init_channels(efx);
-	if (rc)
-		goto fail1;
+	EFX_ASSERT_RESET_SERIALISED(efx);
=20
-	/* Restore MAC and PHY settings. */
-	rc =3D falcon_xmac_set_settings(efx, ecmd);
+	rc =3D falcon_init_nic(efx);
 	if (rc) {
-		EFX_ERR(efx, "could not restore PHY settings\n");
-		goto fail2;
+		EFX_ERR(efx, "failed to initialise NIC\n");
+		ok =3D false;
 	}
=20
-	return 0;
+	if (ok) {
+		efx_init_channels(efx);
=20
- fail2:
-	efx_fini_channels(efx);
- fail1:
+		if (falcon_xmac_set_settings(efx, ecmd))
+			EFX_ERR(efx, "could not restore PHY settings\n");
+	}
+
+	mutex_unlock(&efx->mac_lock);
+
+	if (ok) {
+		efx_start_all(efx);
+		efx->stats_enabled =3D true;
+	}
 	return rc;
 }
=20
@@ -1659,25 +1620,14 @@ static int efx_reset(struct efx_nic *efx)
 		goto unlock_rtnl;
 	}
=20
-	efx->state =3D STATE_RESETTING;
 	EFX_INFO(efx, "resetting (%d)\n", method);
=20
-	/* The net_dev->get_stats handler is quite slow, and will fail
-	 * if a fetch is pending over reset. Serialise against it. */
-	spin_lock(&efx->stats_lock);
-	spin_unlock(&efx->stats_lock);
-
-	efx_stop_all(efx);
-	mutex_lock(&efx->mac_lock);
-
-	rc =3D efx_reset_down(efx, &ecmd);
-	if (rc)
-		goto fail1;
+	efx_reset_down(efx, &ecmd);
=20
 	rc =3D falcon_reset_hw(efx, method);
 	if (rc) {
 		EFX_ERR(efx, "failed to reset hardware\n");
-		goto fail2;
+		goto fail;
 	}
=20
 	/* Allow resets to be rescheduled. */
@@ -1689,46 +1639,27 @@ static int efx_reset(struct efx_nic *efx)
 	 * can respond to requests. */
 	pci_set_master(efx->pci_dev);
=20
-	/* Reinitialise device. This is appropriate in the RESET_TYPE_DISABLE
-	 * case so the driver can talk to external SRAM */
-	rc =3D falcon_init_nic(efx);
-	if (rc) {
-		EFX_ERR(efx, "failed to initialise NIC\n");
-		goto fail3;
-	}
-
 	/* Leave device stopped if necessary */
 	if (method =3D=3D RESET_TYPE_DISABLE) {
-		/* Reinitialise the device anyway so the driver unload sequence
-		 * can talk to the external SRAM */
-		falcon_init_nic(efx);
 		rc =3D -EIO;
-		goto fail4;
+		goto fail;
 	}
=20
-	rc =3D efx_reset_up(efx, &ecmd);
+	rc =3D efx_reset_up(efx, &ecmd, true);
 	if (rc)
-		goto fail5;
+		goto disable;
=20
-	mutex_unlock(&efx->mac_lock);
 	EFX_LOG(efx, "reset complete\n");
-
-	efx->state =3D STATE_RUNNING;
-	efx_start_all(efx);
-
  unlock_rtnl:
 	rtnl_unlock();
 	return 0;
=20
- fail5:
- fail4:
- fail3:
- fail2:
- fail1:
+ fail:
+	efx_reset_up(efx, &ecmd, false);
+ disable:
 	EFX_ERR(efx, "has been disabled\n");
 	efx->state =3D STATE_DISABLED;
=20
-	mutex_unlock(&efx->mac_lock);
 	rtnl_unlock();
 	efx_unregister_netdev(efx);
 	efx_fini_port(efx);
@@ -1801,7 +1732,7 @@ static struct pci_device_id efx_pci_table[] __dev=
initdata =3D {
  *
  * Dummy PHY/MAC/Board operations
  *
- * Can be used where the MAC does not implement this operation
+ * Can be used for some unimplemented operations
  * Needed so all function pointers are valid and do not have to be tes=
ted
  * before use
  *
@@ -1811,7 +1742,7 @@ int efx_port_dummy_op_int(struct efx_nic *efx)
 	return 0;
 }
 void efx_port_dummy_op_void(struct efx_nic *efx) {}
-void efx_port_dummy_op_blink(struct efx_nic *efx, int blink) {}
+void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink) {}
=20
 static struct efx_phy_operations efx_dummy_phy_operations =3D {
 	.init		 =3D efx_port_dummy_op_int,
@@ -1822,17 +1753,12 @@ static struct efx_phy_operations efx_dummy_phy_=
operations =3D {
 	.reset_xaui      =3D efx_port_dummy_op_void,
 };
=20
-/* Dummy board operations */
-static int efx_nic_dummy_op_int(struct efx_nic *nic)
-{
-	return 0;
-}
-
 static struct efx_board efx_dummy_board_info =3D {
-	.init    =3D efx_nic_dummy_op_int,
-	.init_leds =3D efx_port_dummy_op_int,
-	.set_fault_led =3D efx_port_dummy_op_blink,
-	.fini	=3D efx_port_dummy_op_void,
+	.init		=3D efx_port_dummy_op_int,
+	.init_leds	=3D efx_port_dummy_op_int,
+	.set_fault_led	=3D efx_port_dummy_op_blink,
+	.blink		=3D efx_port_dummy_op_blink,
+	.fini		=3D efx_port_dummy_op_void,
 };
=20
 /*********************************************************************=
*****
@@ -1865,7 +1791,7 @@ static int efx_init_struct(struct efx_nic *efx, s=
truct efx_nic_type *type,
 	efx->board_info =3D efx_dummy_board_info;
=20
 	efx->net_dev =3D net_dev;
-	efx->rx_checksum_enabled =3D 1;
+	efx->rx_checksum_enabled =3D true;
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
@@ -1878,10 +1804,9 @@ static int efx_init_struct(struct efx_nic *efx, =
struct efx_nic_type *type,
 		channel =3D &efx->channel[i];
 		channel->efx =3D efx;
 		channel->channel =3D i;
-		channel->evqnum =3D i;
-		channel->work_pending =3D 0;
+		channel->work_pending =3D false;
 	}
-	for (i =3D 0; i < EFX_MAX_TX_QUEUES; i++) {
+	for (i =3D 0; i < EFX_TX_QUEUE_COUNT; i++) {
 		tx_queue =3D &efx->tx_queue[i];
 		tx_queue->efx =3D efx;
 		tx_queue->queue =3D i;
@@ -2056,19 +1981,16 @@ static int efx_pci_probe_main(struct efx_nic *e=
fx)
 		goto fail5;
 	}
=20
-	rc =3D efx_init_channels(efx);
-	if (rc)
-		goto fail6;
+	efx_init_channels(efx);
=20
 	rc =3D falcon_init_interrupt(efx);
 	if (rc)
-		goto fail7;
+		goto fail6;
=20
 	return 0;
=20
- fail7:
-	efx_fini_channels(efx);
  fail6:
+	efx_fini_channels(efx);
 	efx_fini_port(efx);
  fail5:
  fail4:
@@ -2105,7 +2027,10 @@ static int __devinit efx_pci_probe(struct pci_de=
v *pci_dev,
 			      NETIF_F_HIGHDMA | NETIF_F_TSO);
 	if (lro)
 		net_dev->features |=3D NETIF_F_LRO;
-	efx =3D net_dev->priv;
+	/* Mask for features that also apply to VLAN devices */
+	net_dev->vlan_features |=3D (NETIF_F_ALL_CSUM | NETIF_F_SG |
+				   NETIF_F_HIGHDMA | NETIF_F_TSO);
+	efx =3D netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	rc =3D efx_init_struct(efx, type, pci_dev, net_dev);
 	if (rc)
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 3b2f69f..d02937b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -28,15 +28,21 @@ extern void efx_wake_queue(struct efx_nic *efx);
 /* RX */
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int =
index);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int =
index,
-			  unsigned int len, int checksummed, int discard);
+			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int =
delay);
=20
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
-extern int efx_flush_queues(struct efx_nic *efx);
+extern void efx_flush_queues(struct efx_nic *efx);
=20
 /* Ports */
 extern void efx_reconfigure_port(struct efx_nic *efx);
+extern void __efx_reconfigure_port(struct efx_nic *efx);
+
+/* Reset handling */
+extern void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ec=
md);
+extern int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
+			bool ok);
=20
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type ty=
pe);
@@ -50,7 +56,7 @@ extern void efx_hex_dump(const u8 *, unsigned int, co=
nst char *);
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
-extern void efx_port_dummy_op_blink(struct efx_nic *efx, int blink);
+extern void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink);
=20
=20
 extern unsigned int efx_monitor_interval;
@@ -59,7 +65,7 @@ static inline void efx_schedule_channel(struct efx_ch=
annel *channel)
 {
 	EFX_TRACE(channel->efx, "channel %d scheduling NAPI poll on CPU%d\n",
 		  channel->channel, raw_smp_processor_id());
-	channel->work_pending =3D 1;
+	channel->work_pending =3D true;
=20
 	netif_rx_schedule(channel->napi_dev, &channel->napi_str);
 }
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index c53290d..cec15db 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -52,12 +52,11 @@ extern const char *efx_loopback_mode_names[];
 #define LOOPBACK_MASK(_efx)			\
 	(1 << (_efx)->loopback_mode)
=20
-#define LOOPBACK_INTERNAL(_efx)						\
-	((LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)) ? 1 : 0)
+#define LOOPBACK_INTERNAL(_efx)				\
+	(!!(LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)))
=20
-#define LOOPBACK_OUT_OF(_from, _to, _mask)		\
-	(((LOOPBACK_MASK(_from) & (_mask)) &&		\
-	  ((LOOPBACK_MASK(_to) & (_mask)) =3D=3D 0)) ? 1 : 0)
+#define LOOPBACK_OUT_OF(_from, _to, _mask)				\
+	((LOOPBACK_MASK(_from) & (_mask)) && !(LOOPBACK_MASK(_to) & (_mask)))
=20
 /*********************************************************************=
********/
=20
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index e2c75d1..fa98af5 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -17,6 +17,7 @@
 #include "ethtool.h"
 #include "falcon.h"
 #include "gmii.h"
+#include "spi.h"
 #include "mac.h"
=20
 const char *efx_loopback_mode_names[] =3D {
@@ -32,8 +33,6 @@ const char *efx_loopback_mode_names[] =3D {
 	[LOOPBACK_NETWORK]	=3D "NETWORK",
 };
=20
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 ena=
ble);
-
 struct ethtool_string {
 	char name[ETH_GSTRING_LEN];
 };
@@ -173,6 +172,11 @@ static struct efx_ethtool_stat efx_ethtool_stats[]=
 =3D {
 /* Number of ethtool statistics */
 #define EFX_ETHTOOL_NUM_STATS ARRAY_SIZE(efx_ethtool_stats)
=20
+/* EEPROM range with gPXE configuration */
+#define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
+#define EFX_ETHTOOL_EEPROM_MIN 0x100U
+#define EFX_ETHTOOL_EEPROM_MAX 0x400U
+
 /*********************************************************************=
*****
  *
  * Ethtool operations
@@ -183,7 +187,7 @@ static struct efx_ethtool_stat efx_ethtool_stats[] =
=3D {
 /* Identify device by flashing LEDs */
 static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds=
)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	efx->board_info.blink(efx, 1);
 	schedule_timeout_interruptible(seconds * HZ);
@@ -195,7 +199,7 @@ static int efx_ethtool_phys_id(struct net_device *n=
et_dev, u32 seconds)
 int efx_ethtool_get_settings(struct net_device *net_dev,
 			     struct ethtool_cmd *ecmd)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	int rc;
=20
 	mutex_lock(&efx->mac_lock);
@@ -209,7 +213,7 @@ int efx_ethtool_get_settings(struct net_device *net=
_dev,
 int efx_ethtool_set_settings(struct net_device *net_dev,
 			     struct ethtool_cmd *ecmd)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	int rc;
=20
 	mutex_lock(&efx->mac_lock);
@@ -224,7 +228,7 @@ int efx_ethtool_set_settings(struct net_device *net=
_dev,
 static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 				    struct ethtool_drvinfo *info)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	strlcpy(info->driver, EFX_DRIVER_NAME, sizeof(info->driver));
 	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
@@ -329,7 +333,10 @@ static int efx_ethtool_fill_self_tests(struct efx_=
nic *efx,
 	unsigned int n =3D 0;
 	enum efx_loopback_mode mode;
=20
-	/* Interrupt */
+	efx_fill_test(n++, strings, data, &tests->mii,
+		      "core", 0, "mii", NULL);
+	efx_fill_test(n++, strings, data, &tests->nvram,
+		      "core", 0, "nvram", NULL);
 	efx_fill_test(n++, strings, data, &tests->interrupt,
 		      "core", 0, "interrupt", NULL);
=20
@@ -349,16 +356,17 @@ static int efx_ethtool_fill_self_tests(struct efx=
_nic *efx,
 			      "eventq.poll", NULL);
 	}
=20
-	/* PHY presence */
-	efx_fill_test(n++, strings, data, &tests->phy_ok,
-		      EFX_PORT_NAME, "phy_ok", NULL);
+	efx_fill_test(n++, strings, data, &tests->registers,
+		      "core", 0, "registers", NULL);
+	efx_fill_test(n++, strings, data, &tests->phy,
+		      EFX_PORT_NAME, "phy", NULL);
=20
 	/* Loopback tests */
 	efx_fill_test(n++, strings, data, &tests->loopback_speed,
 		      EFX_PORT_NAME, "loopback.speed", NULL);
 	efx_fill_test(n++, strings, data, &tests->loopback_full_duplex,
 		      EFX_PORT_NAME, "loopback.full_duplex", NULL);
-	for (mode =3D LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+	for (mode =3D LOOPBACK_NONE; mode <=3D LOOPBACK_TEST_MAX; mode++) {
 		if (!(efx->loopback_modes & (1 << mode)))
 			continue;
 		n =3D efx_fill_loopback_test(efx,
@@ -369,22 +377,24 @@ static int efx_ethtool_fill_self_tests(struct efx=
_nic *efx,
 	return n;
 }
=20
-static int efx_ethtool_get_stats_count(struct net_device *net_dev)
+static int efx_ethtool_get_sset_count(struct net_device *net_dev,
+				      int string_set)
 {
-	return EFX_ETHTOOL_NUM_STATS;
-}
-
-static int efx_ethtool_self_test_count(struct net_device *net_dev)
-{
-	struct efx_nic *efx =3D net_dev->priv;
-
-	return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return EFX_ETHTOOL_NUM_STATS;
+	case ETH_SS_TEST:
+		return efx_ethtool_fill_self_tests(netdev_priv(net_dev),
+						   NULL, NULL, NULL);
+	default:
+		return -EINVAL;
+	}
 }
=20
 static void efx_ethtool_get_strings(struct net_device *net_dev,
 				    u32 string_set, u8 *strings)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct ethtool_string *ethtool_strings =3D
 		(struct ethtool_string *)strings;
 	int i;
@@ -410,7 +420,7 @@ static void efx_ethtool_get_stats(struct net_device=
 *net_dev,
 				  struct ethtool_stats *stats,
 				  u64 *data)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	struct efx_ethtool_stat *stat;
 	struct efx_channel *channel;
@@ -442,60 +452,21 @@ static void efx_ethtool_get_stats(struct net_devi=
ce *net_dev,
 	}
 }
=20
-static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
-{
-	int rc;
-
-	/* Our TSO requires TX checksumming, so force TX checksumming
-	 * on when TSO is enabled.
-	 */
-	if (enable) {
-		rc =3D efx_ethtool_set_tx_csum(net_dev, 1);
-		if (rc)
-			return rc;
-	}
-
-	return ethtool_op_set_tso(net_dev, enable);
-}
-
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 ena=
ble)
-{
-	struct efx_nic *efx =3D net_dev->priv;
-	int rc;
-
-	rc =3D ethtool_op_set_tx_csum(net_dev, enable);
-	if (rc)
-		return rc;
-
-	efx_flush_queues(efx);
-
-	/* Our TSO requires TX checksumming, so disable TSO when
-	 * checksumming is disabled
-	 */
-	if (!enable) {
-		rc =3D efx_ethtool_set_tso(net_dev, 0);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
-
 static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 ena=
ble)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	/* No way to stop the hardware doing the checks; we just
 	 * ignore the result.
 	 */
-	efx->rx_checksum_enabled =3D (enable ? 1 : 0);
+	efx->rx_checksum_enabled =3D !!enable;
=20
 	return 0;
 }
=20
 static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	return efx->rx_checksum_enabled;
 }
@@ -503,7 +474,7 @@ static u32 efx_ethtool_get_rx_csum(struct net_devic=
e *net_dev)
 static void efx_ethtool_self_test(struct net_device *net_dev,
 				  struct ethtool_test *test, u64 *data)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_self_tests efx_tests;
 	int offline, already_up;
 	int rc;
@@ -533,15 +504,9 @@ static void efx_ethtool_self_test(struct net_devic=
e *net_dev,
 		goto out;
=20
 	/* Perform offline tests only if online tests passed */
-	if (offline) {
-		/* Stop the kernel from sending packets during the test. */
-		efx_stop_queue(efx);
-		rc =3D efx_flush_queues(efx);
-		if (!rc)
-			rc =3D efx_offline_test(efx, &efx_tests,
-					      efx->loopback_modes);
-		efx_wake_queue(efx);
-	}
+	if (offline)
+		rc =3D efx_offline_test(efx, &efx_tests,
+				      efx->loopback_modes);
=20
  out:
 	if (!already_up)
@@ -561,22 +526,65 @@ static void efx_ethtool_self_test(struct net_devi=
ce *net_dev,
 /* Restart autonegotiation */
 static int efx_ethtool_nway_reset(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	return mii_nway_restart(&efx->mii);
 }
=20
 static u32 efx_ethtool_get_link(struct net_device *net_dev)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
 	return efx->link_up;
 }
=20
+static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
+{
+	struct efx_nic *efx =3D netdev_priv(net_dev);
+	struct efx_spi_device *spi =3D efx->spi_eeprom;
+
+	if (!spi)
+		return 0;
+	return min(spi->size, EFX_ETHTOOL_EEPROM_MAX) -
+		min(spi->size, EFX_ETHTOOL_EEPROM_MIN);
+}
+
+static int efx_ethtool_get_eeprom(struct net_device *net_dev,
+				  struct ethtool_eeprom *eeprom, u8 *buf)
+{
+	struct efx_nic *efx =3D netdev_priv(net_dev);
+	struct efx_spi_device *spi =3D efx->spi_eeprom;
+	size_t len;
+	int rc;
+
+	rc =3D falcon_spi_read(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+			     eeprom->len, &len, buf);
+	eeprom->magic =3D EFX_ETHTOOL_EEPROM_MAGIC;
+	eeprom->len =3D len;
+	return rc;
+}
+
+static int efx_ethtool_set_eeprom(struct net_device *net_dev,
+				  struct ethtool_eeprom *eeprom, u8 *buf)
+{
+	struct efx_nic *efx =3D netdev_priv(net_dev);
+	struct efx_spi_device *spi =3D efx->spi_eeprom;
+	size_t len;
+	int rc;
+
+	if (eeprom->magic !=3D EFX_ETHTOOL_EEPROM_MAGIC)
+		return -EINVAL;
+
+	rc =3D falcon_spi_write(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+			      eeprom->len, &len, buf);
+	eeprom->len =3D len;
+	return rc;
+}
+
 static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	struct efx_channel *channel;
@@ -614,7 +622,7 @@ static int efx_ethtool_get_coalesce(struct net_devi=
ce *net_dev,
 static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	unsigned tx_usecs, rx_usecs;
@@ -657,7 +665,7 @@ static int efx_ethtool_set_coalesce(struct net_devi=
ce *net_dev,
 static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 				      struct ethtool_pauseparam *pause)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	enum efx_fc_type flow_control =3D efx->flow_control;
 	int rc;
=20
@@ -680,11 +688,11 @@ static int efx_ethtool_set_pauseparam(struct net_=
device *net_dev,
 static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
 				       struct ethtool_pauseparam *pause)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
-	pause->rx_pause =3D (efx->flow_control & EFX_FC_RX) ? 1 : 0;
-	pause->tx_pause =3D (efx->flow_control & EFX_FC_TX) ? 1 : 0;
-	pause->autoneg =3D (efx->flow_control & EFX_FC_AUTO) ? 1 : 0;
+	pause->rx_pause =3D !!(efx->flow_control & EFX_FC_RX);
+	pause->tx_pause =3D !!(efx->flow_control & EFX_FC_TX);
+	pause->autoneg =3D !!(efx->flow_control & EFX_FC_AUTO);
 }
=20
=20
@@ -694,6 +702,9 @@ struct ethtool_ops efx_ethtool_ops =3D {
 	.get_drvinfo		=3D efx_ethtool_get_drvinfo,
 	.nway_reset		=3D efx_ethtool_nway_reset,
 	.get_link		=3D efx_ethtool_get_link,
+	.get_eeprom_len		=3D efx_ethtool_get_eeprom_len,
+	.get_eeprom		=3D efx_ethtool_get_eeprom,
+	.set_eeprom		=3D efx_ethtool_set_eeprom,
 	.get_coalesce		=3D efx_ethtool_get_coalesce,
 	.set_coalesce		=3D efx_ethtool_set_coalesce,
 	.get_pauseparam         =3D efx_ethtool_get_pauseparam,
@@ -701,17 +712,16 @@ struct ethtool_ops efx_ethtool_ops =3D {
 	.get_rx_csum		=3D efx_ethtool_get_rx_csum,
 	.set_rx_csum		=3D efx_ethtool_set_rx_csum,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D efx_ethtool_set_tx_csum,
+	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_sg			=3D ethtool_op_get_sg,
 	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D efx_ethtool_set_tso,
+	.set_tso		=3D ethtool_op_set_tso,
 	.get_flags		=3D ethtool_op_get_flags,
 	.set_flags		=3D ethtool_op_set_flags,
-	.self_test_count	=3D efx_ethtool_self_test_count,
+	.get_sset_count		=3D efx_ethtool_get_sset_count,
 	.self_test		=3D efx_ethtool_self_test,
 	.get_strings		=3D efx_ethtool_get_strings,
 	.phys_id		=3D efx_ethtool_phys_id,
-	.get_stats_count	=3D efx_ethtool_get_stats_count,
 	.get_ethtool_stats	=3D efx_ethtool_get_stats,
 };
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9138ee5..e0c0b23 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -242,7 +242,7 @@ static struct i2c_algo_bit_data falcon_i2c_bit_oper=
ations =3D {
  * falcon_alloc_special_buffer()) in Falcon's buffer table, allowing
  * it to be used for event queues, descriptor rings etc.
  */
-static int
+static void
 falcon_init_special_buffer(struct efx_nic *efx,
 			   struct efx_special_buffer *buffer)
 {
@@ -266,8 +266,6 @@ falcon_init_special_buffer(struct efx_nic *efx,
 				     BUF_OWNER_ID_FBUF, 0);
 		falcon_write_sram(efx, &buf_desc, index);
 	}
-
-	return 0;
 }
=20
 /* Unmaps a buffer from Falcon and clears the buffer table entries */
@@ -449,16 +447,13 @@ int falcon_probe_tx(struct efx_tx_queue *tx_queue=
)
 					   sizeof(efx_qword_t));
 }
=20
-int falcon_init_tx(struct efx_tx_queue *tx_queue)
+void falcon_init_tx(struct efx_tx_queue *tx_queue)
 {
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx =3D tx_queue->efx;
-	int rc;
=20
 	/* Pin TX descriptor ring */
-	rc =3D falcon_init_special_buffer(efx, &tx_queue->txd);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &tx_queue->txd);
=20
 	/* Push TX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(tx_desc_ptr,
@@ -466,7 +461,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_ISCSI_DDIG_EN, 0,
 			      TX_ISCSI_HDIG_EN, 0,
 			      TX_DESCQ_BUF_BASE_ID, tx_queue->txd.index,
-			      TX_DESCQ_EVQ_ID, tx_queue->channel->evqnum,
+			      TX_DESCQ_EVQ_ID, tx_queue->channel->channel,
 			      TX_DESCQ_OWNER_ID, 0,
 			      TX_DESCQ_LABEL, tx_queue->queue,
 			      TX_DESCQ_SIZE, FALCON_TXD_RING_ORDER,
@@ -474,9 +469,9 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_NON_IP_DROP_DIS_B0, 1);
=20
 	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
-		int csum =3D !(efx->net_dev->features & NETIF_F_IP_CSUM);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, csum);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, csum);
+		int csum =3D tx_queue->queue =3D=3D EFX_TX_QUEUE_OFFLOAD_CSUM;
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, !csum);
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, !csum);
 	}
=20
 	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
@@ -485,17 +480,16 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 	if (falcon_rev(efx) < FALCON_REV_B0) {
 		efx_oword_t reg;
=20
-		BUG_ON(tx_queue->queue >=3D 128); /* HW limit */
+		/* Only 128 bits in this register */
+		BUILD_BUG_ON(EFX_TX_QUEUE_COUNT >=3D 128);
=20
 		falcon_read(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
-		if (efx->net_dev->features & NETIF_F_IP_CSUM)
+		if (tx_queue->queue =3D=3D EFX_TX_QUEUE_OFFLOAD_CSUM)
 			clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
 			set_bit_le(tx_queue->queue, (void *)&reg);
 		falcon_write(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
 	}
-
-	return 0;
 }
=20
 static int falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
@@ -538,7 +532,7 @@ static int falcon_flush_tx_queue(struct efx_tx_queu=
e *tx_queue)
=20
 	if (EFX_WORKAROUND_11557(efx)) {
 		efx_oword_t reg;
-		int enabled;
+		bool enabled;
=20
 		falcon_read_table(efx, &reg, efx->type->txd_ptr_tbl_base,
 				  tx_queue->queue);
@@ -638,29 +632,26 @@ int falcon_probe_rx(struct efx_rx_queue *rx_queue=
)
 					   sizeof(efx_qword_t));
 }
=20
-int falcon_init_rx(struct efx_rx_queue *rx_queue)
+void falcon_init_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx =3D rx_queue->efx;
-	int rc;
-	int is_b0 =3D falcon_rev(efx) >=3D FALCON_REV_B0;
-	int iscsi_digest_en =3D is_b0;
+	bool is_b0 =3D falcon_rev(efx) >=3D FALCON_REV_B0;
+	bool iscsi_digest_en =3D is_b0;
=20
 	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
 		rx_queue->queue, rx_queue->rxd.index,
 		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
=20
 	/* Pin RX descriptor ring */
-	rc =3D falcon_init_special_buffer(efx, &rx_queue->rxd);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &rx_queue->rxd);
=20
 	/* Push RX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(rx_desc_ptr,
 			      RX_ISCSI_DDIG_EN, iscsi_digest_en,
 			      RX_ISCSI_HDIG_EN, iscsi_digest_en,
 			      RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
-			      RX_DESCQ_EVQ_ID, rx_queue->channel->evqnum,
+			      RX_DESCQ_EVQ_ID, rx_queue->channel->channel,
 			      RX_DESCQ_OWNER_ID, 0,
 			      RX_DESCQ_LABEL, rx_queue->queue,
 			      RX_DESCQ_SIZE, FALCON_RXD_RING_ORDER,
@@ -670,7 +661,6 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 			      RX_DESCQ_EN, 1);
 	falcon_write_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
 			   rx_queue->queue);
-	return 0;
 }
=20
 static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
@@ -694,7 +684,8 @@ static int falcon_flush_rx_queue(struct efx_rx_queu=
e *rx_queue)
 	read_ptr =3D channel->eventq_read_ptr;
 	for (i =3D 0; i < FALCON_EVQ_SIZE; ++i) {
 		efx_qword_t *event =3D falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue, ev_failed;
+		int ev_code, ev_sub_code, ev_queue;
+		bool ev_failed;
 		if (!falcon_event_present(event))
 			break;
=20
@@ -721,7 +712,7 @@ static int falcon_flush_rx_queue(struct efx_rx_queu=
e *rx_queue)
=20
 	if (EFX_WORKAROUND_11557(efx)) {
 		efx_oword_t reg;
-		int enabled;
+		bool enabled;
=20
 		falcon_read_table(efx, &reg, efx->type->rxd_ptr_tbl_base,
 				  rx_queue->queue);
@@ -793,7 +784,7 @@ void falcon_eventq_read_ack(struct efx_channel *cha=
nnel)
=20
 	EFX_POPULATE_DWORD_1(reg, EVQ_RPTR_DWORD, channel->eventq_read_ptr);
 	falcon_writel_table(efx, &reg, efx->type->evq_rptr_tbl_base,
-			    channel->evqnum);
+			    channel->channel);
 }
=20
 /* Use HW to insert a SW defined event */
@@ -802,7 +793,7 @@ void falcon_generate_event(struct efx_channel *chan=
nel, efx_qword_t *event)
 	efx_oword_t drv_ev_reg;
=20
 	EFX_POPULATE_OWORD_2(drv_ev_reg,
-			     DRV_EV_QID, channel->evqnum,
+			     DRV_EV_QID, channel->channel,
 			     DRV_EV_DATA,
 			     EFX_QWORD_FIELD64(*event, WHOLE_EVENT));
 	falcon_write(channel->efx, &drv_ev_reg, DRV_EV_REG_KER);
@@ -813,8 +804,8 @@ void falcon_generate_event(struct efx_channel *chan=
nel, efx_qword_t *event)
  * Falcon batches TX completion events; the message we receive is of
  * the form "complete all TX events up to this index".
  */
-static inline void falcon_handle_tx_event(struct efx_channel *channel,
-					  efx_qword_t *event)
+static void falcon_handle_tx_event(struct efx_channel *channel,
+				   efx_qword_t *event)
 {
 	unsigned int tx_ev_desc_ptr;
 	unsigned int tx_ev_q_label;
@@ -847,39 +838,19 @@ static inline void falcon_handle_tx_event(struct =
efx_channel *channel,
 	}
 }
=20
-/* Check received packet's destination MAC address. */
-static int check_dest_mac(struct efx_rx_queue *rx_queue,
-			  const efx_qword_t *event)
-{
-	struct efx_rx_buffer *rx_buf;
-	struct efx_nic *efx =3D rx_queue->efx;
-	int rx_ev_desc_ptr;
-	struct ethhdr *eh;
-
-	if (efx->promiscuous)
-		return 1;
-
-	rx_ev_desc_ptr =3D EFX_QWORD_FIELD(*event, RX_EV_DESC_PTR);
-	rx_buf =3D efx_rx_buffer(rx_queue, rx_ev_desc_ptr);
-	eh =3D (struct ethhdr *)rx_buf->data;
-	if (memcmp(eh->h_dest, efx->net_dev->dev_addr, ETH_ALEN))
-		return 0;
-	return 1;
-}
-
 /* Detect errors included in the rx_evt_pkt_ok bit. */
 static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 				    const efx_qword_t *event,
-				    unsigned *rx_ev_pkt_ok,
-				    int *discard, int byte_count)
+				    bool *rx_ev_pkt_ok,
+				    bool *discard)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
-	unsigned rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
-	unsigned rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
-	unsigned rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
-	unsigned rx_ev_pkt_type, rx_ev_other_err, rx_ev_pause_frm;
-	unsigned rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
-	int snap, non_ip;
+	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
+	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
+	bool rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
+	bool rx_ev_other_err, rx_ev_pause_frm;
+	bool rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned rx_ev_pkt_type;
=20
 	rx_ev_hdr_type =3D EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
 	rx_ev_mcast_pkt =3D EFX_QWORD_FIELD(*event, RX_EV_MCAST_PKT);
@@ -903,41 +874,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_=
queue *rx_queue,
 			   rx_ev_buf_owner_id_err | rx_ev_eth_crc_err |
 			   rx_ev_frm_trunc | rx_ev_ip_hdr_chksum_err);
=20
-	snap =3D (rx_ev_pkt_type =3D=3D RX_EV_PKT_TYPE_LLC_DECODE) ||
-		(rx_ev_pkt_type =3D=3D RX_EV_PKT_TYPE_VLAN_LLC_DECODE);
-	non_ip =3D (rx_ev_hdr_type =3D=3D RX_EV_HDR_TYPE_NON_IP_DECODE);
-
-	/* SFC bug 5475/8970: The Falcon XMAC incorrectly calculates the
-	 * length field of an LLC frame, which sets TOBE_DISC. We could set
-	 * PASS_LEN_ERR, but we want the MAC to filter out short frames (to
-	 * protect the RX block).
-	 *
-	 * bug5475 - LLC/SNAP: Falcon identifies SNAP packets.
-	 * bug8970 - LLC/noSNAP: Falcon does not provide an LLC flag.
-	 *                       LLC can't encapsulate IP, so by definition
-	 *                       these packets are NON_IP.
-	 *
-	 * Unicast mismatch will also cause TOBE_DISC, so the driver needs
-	 * to check this.
-	 */
-	if (EFX_WORKAROUND_5475(efx) && rx_ev_tobe_disc && (snap || non_ip)) =
{
-		/* If all the other flags are zero then we can state the
-		 * entire packet is ok, which will flag to the kernel not
-		 * to recalculate checksums.
-		 */
-		if (!(non_ip | rx_ev_other_err | rx_ev_pause_frm))
-			*rx_ev_pkt_ok =3D 1;
-
-		rx_ev_tobe_disc =3D 0;
-
-		/* TOBE_DISC is set for unicast mismatch.  But given that
-		 * we can't trust TOBE_DISC here, we must validate the dest
-		 * MAC address ourselves.
-		 */
-		if (!rx_ev_mcast_pkt && !check_dest_mac(rx_queue, event))
-			rx_ev_tobe_disc =3D 1;
-	}
-
 	/* Count errors that are not in MAC stats. */
 	if (rx_ev_frm_trunc)
 		++rx_queue->channel->n_rx_frm_trunc;
@@ -961,7 +897,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_q=
ueue *rx_queue,
 #ifdef EFX_ENABLE_DEBUG
 	if (rx_ev_other_err) {
 		EFX_INFO_RL(efx, " RX queue %d unexpected RX event "
-			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s%s\n",
+			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
 			    rx_queue->queue, EFX_QWORD_VAL(*event),
 			    rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
 			    rx_ev_ip_hdr_chksum_err ?
@@ -972,8 +908,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_q=
ueue *rx_queue,
 			    rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
 			    rx_ev_drib_nib ? " [DRIB_NIB]" : "",
 			    rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
-			    rx_ev_pause_frm ? " [PAUSE]" : "",
-			    snap ? " [SNAP/LLC]" : "");
+			    rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
=20
@@ -1006,13 +941,13 @@ static void falcon_handle_rx_bad_index(struct ef=
x_rx_queue *rx_queue,
  * Also "is multicast" and "matches multicast filter" flags can be use=
d to
  * discard non-matching multicast packets.
  */
-static inline int falcon_handle_rx_event(struct efx_channel *channel,
-					 const efx_qword_t *event)
+static void falcon_handle_rx_event(struct efx_channel *channel,
+				   const efx_qword_t *event)
 {
-	unsigned int rx_ev_q_label, rx_ev_desc_ptr, rx_ev_byte_cnt;
-	unsigned int rx_ev_pkt_ok, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned int rx_ev_desc_ptr, rx_ev_byte_cnt;
+	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned expected_ptr;
-	int discard =3D 0, checksummed;
+	bool rx_ev_pkt_ok, discard =3D false, checksummed;
 	struct efx_rx_queue *rx_queue;
 	struct efx_nic *efx =3D channel->efx;
=20
@@ -1022,16 +957,14 @@ static inline int falcon_handle_rx_event(struct =
efx_channel *channel,
 	rx_ev_hdr_type =3D EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
 	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_JUMBO_CONT));
 	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_SOP) !=3D 1);
+	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_Q_LABEL) !=3D channel->channel)=
;
=20
-	rx_ev_q_label =3D EFX_QWORD_FIELD(*event, RX_EV_Q_LABEL);
-	rx_queue =3D &efx->rx_queue[rx_ev_q_label];
+	rx_queue =3D &efx->rx_queue[channel->channel];
=20
 	rx_ev_desc_ptr =3D EFX_QWORD_FIELD(*event, RX_EV_DESC_PTR);
 	expected_ptr =3D rx_queue->removed_count & FALCON_RXD_RING_MASK;
-	if (unlikely(rx_ev_desc_ptr !=3D expected_ptr)) {
+	if (unlikely(rx_ev_desc_ptr !=3D expected_ptr))
 		falcon_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
-		return rx_ev_q_label;
-	}
=20
 	if (likely(rx_ev_pkt_ok)) {
 		/* If packet is marked as OK and packet type is TCP/IPv4 or
@@ -1040,8 +973,8 @@ static inline int falcon_handle_rx_event(struct ef=
x_channel *channel,
 		checksummed =3D RX_EV_HDR_TYPE_HAS_CHECKSUMS(rx_ev_hdr_type);
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
-					&discard, rx_ev_byte_cnt);
-		checksummed =3D 0;
+					&discard);
+		checksummed =3D false;
 	}
=20
 	/* Detect multicast packets that didn't match the filter */
@@ -1051,14 +984,12 @@ static inline int falcon_handle_rx_event(struct =
efx_channel *channel,
 			EFX_QWORD_FIELD(*event, RX_EV_MCAST_HASH_MATCH);
=20
 		if (unlikely(!rx_ev_mcast_hash_match))
-			discard =3D 1;
+			discard =3D true;
 	}
=20
 	/* Handle received packet */
 	efx_rx_packet(rx_queue, rx_ev_desc_ptr, rx_ev_byte_cnt,
 		      checksummed, discard);
-
-	return rx_ev_q_label;
 }
=20
 /* Global events are basically PHY events */
@@ -1066,23 +997,23 @@ static void falcon_handle_global_event(struct ef=
x_channel *channel,
 				       efx_qword_t *event)
 {
 	struct efx_nic *efx =3D channel->efx;
-	int is_phy_event =3D 0, handled =3D 0;
+	bool is_phy_event =3D false, handled =3D false;
=20
 	/* Check for interrupt on either port.  Some boards have a
 	 * single PHY wired to the interrupt line for port 1. */
 	if (EFX_QWORD_FIELD(*event, G_PHY0_INTR) ||
 	    EFX_QWORD_FIELD(*event, G_PHY1_INTR) ||
 	    EFX_QWORD_FIELD(*event, XG_PHY_INTR))
-		is_phy_event =3D 1;
+		is_phy_event =3D true;
=20
 	if ((falcon_rev(efx) >=3D FALCON_REV_B0) &&
 	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
-		is_phy_event =3D 1;
+		is_phy_event =3D true;
=20
 	if (is_phy_event) {
 		efx->phy_op->clear_interrupt(efx);
 		queue_work(efx->workqueue, &efx->reconfigure_work);
-		handled =3D 1;
+		handled =3D true;
 	}
=20
 	if (EFX_QWORD_FIELD_VER(efx, *event, RX_RECOVERY)) {
@@ -1092,7 +1023,7 @@ static void falcon_handle_global_event(struct efx=
_channel *channel,
 		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
 				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
-		handled =3D 1;
+		handled =3D true;
 	}
=20
 	if (!handled)
@@ -1163,13 +1094,12 @@ static void falcon_handle_driver_event(struct e=
fx_channel *channel,
 	}
 }
=20
-int falcon_process_eventq(struct efx_channel *channel, int *rx_quota)
+int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 {
 	unsigned int read_ptr;
 	efx_qword_t event, *p_event;
 	int ev_code;
-	int rxq;
-	int rxdmaqs =3D 0;
+	int rx_packets =3D 0;
=20
 	read_ptr =3D channel->eventq_read_ptr;
=20
@@ -1191,9 +1121,8 @@ int falcon_process_eventq(struct efx_channel *cha=
nnel, int *rx_quota)
=20
 		switch (ev_code) {
 		case RX_IP_EV_DECODE:
-			rxq =3D falcon_handle_rx_event(channel, &event);
-			rxdmaqs |=3D (1 << rxq);
-			(*rx_quota)--;
+			falcon_handle_rx_event(channel, &event);
+			++rx_packets;
 			break;
 		case TX_IP_EV_DECODE:
 			falcon_handle_tx_event(channel, &event);
@@ -1220,10 +1149,10 @@ int falcon_process_eventq(struct efx_channel *c=
hannel, int *rx_quota)
 		/* Increment read pointer */
 		read_ptr =3D (read_ptr + 1) & FALCON_EVQ_MASK;
=20
-	} while (*rx_quota);
+	} while (rx_packets < rx_quota);
=20
 	channel->eventq_read_ptr =3D read_ptr;
-	return rxdmaqs;
+	return rx_packets;
 }
=20
 void falcon_set_int_moderation(struct efx_channel *channel)
@@ -1251,7 +1180,7 @@ void falcon_set_int_moderation(struct efx_channel=
 *channel)
 				     TIMER_VAL, 0);
 	}
 	falcon_writel_page_locked(efx, &timer_cmd, TIMER_CMD_REG_KER,
-				  channel->evqnum);
+				  channel->channel);
=20
 }
=20
@@ -1265,20 +1194,17 @@ int falcon_probe_eventq(struct efx_channel *cha=
nnel)
 	return falcon_alloc_special_buffer(efx, &channel->eventq, evq_size);
 }
=20
-int falcon_init_eventq(struct efx_channel *channel)
+void falcon_init_eventq(struct efx_channel *channel)
 {
 	efx_oword_t evq_ptr;
 	struct efx_nic *efx =3D channel->efx;
-	int rc;
=20
 	EFX_LOG(efx, "channel %d event queue in special buffers %d-%d\n",
 		channel->channel, channel->eventq.index,
 		channel->eventq.index + channel->eventq.entries - 1);
=20
 	/* Pin event queue buffer */
-	rc =3D falcon_init_special_buffer(efx, &channel->eventq);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &channel->eventq);
=20
 	/* Fill event queue with all ones (i.e. empty events) */
 	memset(channel->eventq.addr, 0xff, channel->eventq.len);
@@ -1289,11 +1215,9 @@ int falcon_init_eventq(struct efx_channel *chann=
el)
 			     EVQ_SIZE, FALCON_EVQ_ORDER,
 			     EVQ_BUF_BASE_ID, channel->eventq.index);
 	falcon_write_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->evqnum);
+			   channel->channel);
=20
 	falcon_set_int_moderation(channel);
-
-	return 0;
 }
=20
 void falcon_fini_eventq(struct efx_channel *channel)
@@ -1304,7 +1228,7 @@ void falcon_fini_eventq(struct efx_channel *chann=
el)
 	/* Remove event queue from card */
 	EFX_ZERO_OWORD(eventq_ptr);
 	falcon_write_table(efx, &eventq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->evqnum);
+			   channel->channel);
=20
 	/* Unpin event queue */
 	falcon_fini_special_buffer(efx, &channel->eventq);
@@ -1371,7 +1295,7 @@ void falcon_enable_interrupts(struct efx_nic *efx=
)
=20
 	/* Force processing of all the channels to get the EVQ RPTRs up to
 	   date */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		efx_schedule_channel(channel);
 }
=20
@@ -1589,7 +1513,7 @@ static void falcon_setup_rss_indir_table(struct e=
fx_nic *efx)
 	     offset < RX_RSS_INDIR_TBL_B0 + 0x800;
 	     offset +=3D 0x10) {
 		EFX_POPULATE_DWORD_1(dword, RX_RSS_INDIR_ENT_B0,
-				     i % efx->rss_queues);
+				     i % efx->n_rx_queues);
 		falcon_writel(efx, &dword, offset);
 		i++;
 	}
@@ -1621,7 +1545,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	}
=20
 	/* Hook MSI or MSI-X interrupt */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		rc =3D request_irq(channel->irq, falcon_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
 				 efx->name, channel);
@@ -1634,7 +1558,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	return 0;
=20
  fail2:
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		free_irq(channel->irq, channel);
  fail1:
 	return rc;
@@ -1646,7 +1570,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	efx_oword_t reg;
=20
 	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
 			free_irq(channel->irq, channel);
 	}
@@ -1674,64 +1598,195 @@ void falcon_fini_interrupt(struct efx_nic *efx=
)
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
 {
+	unsigned long timeout =3D jiffies + DIV_ROUND_UP(HZ, 10);
 	efx_oword_t reg;
-	int cmd_en, timer_active;
-	int count;
+	bool cmd_en, timer_active;
=20
-	count =3D 0;
-	do {
+	for (;;) {
 		falcon_read(efx, &reg, EE_SPI_HCMD_REG_KER);
 		cmd_en =3D EFX_OWORD_FIELD(reg, EE_SPI_HCMD_CMD_EN);
 		timer_active =3D EFX_OWORD_FIELD(reg, EE_WR_TIMER_ACTIVE);
 		if (!cmd_en && !timer_active)
 			return 0;
-		udelay(10);
-	} while (++count < 10000); /* wait upto 100msec */
-	EFX_ERR(efx, "timed out waiting for SPI\n");
-	return -ETIMEDOUT;
+		if (time_after_eq(jiffies, timeout)) {
+			EFX_ERR(efx, "timed out waiting for SPI\n");
+			return -ETIMEDOUT;
+		}
+		cpu_relax();
+	}
 }
=20
-static int
-falcon_spi_read(struct efx_nic *efx, int device_id, unsigned int comma=
nd,
-		unsigned int address, unsigned int addr_len,
-		void *data, unsigned int len)
+static int falcon_spi_cmd(const struct efx_spi_device *spi,
+			  unsigned int command, int address,
+			  const void *in, void *out, unsigned int len)
 {
+	struct efx_nic *efx =3D spi->efx;
+	bool addressed =3D (address >=3D 0);
+	bool reading =3D (out !=3D NULL);
 	efx_oword_t reg;
 	int rc;
=20
-	BUG_ON(len > FALCON_SPI_MAX_LEN);
+	/* Input validation */
+	if (len > FALCON_SPI_MAX_LEN)
+		return -EINVAL;
=20
 	/* Check SPI not currently being accessed */
 	rc =3D falcon_spi_wait(efx);
 	if (rc)
 		return rc;
=20
-	/* Program address register */
-	EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
-	falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	/* Program address register, if we have an address */
+	if (addressed) {
+		EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
+		falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	}
+
+	/* Program data register, if we have data */
+	if (in !=3D NULL) {
+		memcpy(&reg, in, len);
+		falcon_write(efx, &reg, EE_SPI_HDATA_REG_KER);
+	}
=20
-	/* Issue read command */
+	/* Issue read/write command */
 	EFX_POPULATE_OWORD_7(reg,
 			     EE_SPI_HCMD_CMD_EN, 1,
-			     EE_SPI_HCMD_SF_SEL, device_id,
+			     EE_SPI_HCMD_SF_SEL, spi->device_id,
 			     EE_SPI_HCMD_DABCNT, len,
-			     EE_SPI_HCMD_READ, EE_SPI_READ,
+			     EE_SPI_HCMD_READ, reading,
 			     EE_SPI_HCMD_DUBCNT, 0,
-			     EE_SPI_HCMD_ADBCNT, addr_len,
+			     EE_SPI_HCMD_ADBCNT,
+			     (addressed ? spi->addr_len : 0),
 			     EE_SPI_HCMD_ENC, command);
 	falcon_write(efx, &reg, EE_SPI_HCMD_REG_KER);
=20
-	/* Wait for read to complete */
+	/* Wait for read/write to complete */
 	rc =3D falcon_spi_wait(efx);
 	if (rc)
 		return rc;
=20
 	/* Read data */
-	falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
-	memcpy(data, &reg, len);
+	if (out !=3D NULL) {
+		falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
+		memcpy(out, &reg, len);
+	}
+
 	return 0;
 }
=20
+static unsigned int
+falcon_spi_write_limit(const struct efx_spi_device *spi, unsigned int =
start)
+{
+	return min(FALCON_SPI_MAX_LEN,
+		   (spi->block_size - (start & (spi->block_size - 1))));
+}
+
+static inline u8
+efx_spi_munge_command(const struct efx_spi_device *spi,
+		      const u8 command, const unsigned int address)
+{
+	return command | (((address >> 8) & spi->munge_address) << 3);
+}
+
+
+static int falcon_spi_fast_wait(const struct efx_spi_device *spi)
+{
+	u8 status;
+	int i, rc;
+
+	/* Wait up to 1000us for flash/EEPROM to finish a fast operation. */
+	for (i =3D 0; i < 50; i++) {
+		udelay(20);
+
+		rc =3D falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+	}
+	EFX_ERR(spi->efx,
+		"timed out waiting for device %d last status=3D0x%02x\n",
+		spi->device_id, status);
+	return -ETIMEDOUT;
+}
+
+int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
+		    size_t len, size_t *retlen, u8 *buffer)
+{
+	unsigned int command, block_len, pos =3D 0;
+	int rc =3D 0;
+
+	while (pos < len) {
+		block_len =3D min((unsigned int)len - pos,
+				FALCON_SPI_MAX_LEN);
+
+		command =3D efx_spi_munge_command(spi, SPI_READ, start + pos);
+		rc =3D falcon_spi_cmd(spi, command, start + pos, NULL,
+				    buffer + pos, block_len);
+		if (rc)
+			break;
+		pos +=3D block_len;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc =3D -EINTR;
+			break;
+		}
+	}
+
+	if (retlen)
+		*retlen =3D pos;
+	return rc;
+}
+
+int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
+		     size_t len, size_t *retlen, const u8 *buffer)
+{
+	u8 verify_buffer[FALCON_SPI_MAX_LEN];
+	unsigned int command, block_len, pos =3D 0;
+	int rc =3D 0;
+
+	while (pos < len) {
+		rc =3D falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+		if (rc)
+			break;
+
+		block_len =3D min((unsigned int)len - pos,
+				falcon_spi_write_limit(spi, start + pos));
+		command =3D efx_spi_munge_command(spi, SPI_WRITE, start + pos);
+		rc =3D falcon_spi_cmd(spi, command, start + pos,
+				    buffer + pos, NULL, block_len);
+		if (rc)
+			break;
+
+		rc =3D falcon_spi_fast_wait(spi);
+		if (rc)
+			break;
+
+		command =3D efx_spi_munge_command(spi, SPI_READ, start + pos);
+		rc =3D falcon_spi_cmd(spi, command, start + pos,
+				    NULL, verify_buffer, block_len);
+		if (memcmp(verify_buffer, buffer + pos, block_len)) {
+			rc =3D -EIO;
+			break;
+		}
+
+		pos +=3D block_len;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc =3D -EINTR;
+			break;
+		}
+	}
+
+	if (retlen)
+		*retlen =3D pos;
+	return rc;
+}
+
 /*********************************************************************=
*****
  *
  * MAC wrapper
@@ -1812,7 +1867,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_ni=
c *efx)
 {
 	efx_oword_t reg;
 	int link_speed;
-	unsigned int tx_fc;
+	bool tx_fc;
=20
 	if (efx->link_options & GM_LPA_10000)
 		link_speed =3D 0x3;
@@ -1847,7 +1902,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_ni=
c *efx)
 	/* Transmission of pause frames when RX crosses the threshold is
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
-	tx_fc =3D (efx->flow_control & EFX_FC_TX) ? 1 : 0;
+	tx_fc =3D !!(efx->flow_control & EFX_FC_TX);
 	falcon_read(efx, &reg, RX_CFG_REG_KER);
 	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
=20
@@ -1951,7 +2006,7 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
 			      int addr, int value)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	unsigned int phy_id2 =3D phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
=20
@@ -2019,7 +2074,7 @@ static void falcon_mdio_write(struct net_device *=
net_dev, int phy_id,
  * could be read, -1 will be returned. */
 static int falcon_mdio_read(struct net_device *net_dev, int phy_id, in=
t addr)
 {
-	struct efx_nic *efx =3D net_dev->priv;
+	struct efx_nic *efx =3D netdev_priv(net_dev);
 	unsigned int phy_addr =3D phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
 	int value =3D -1;
@@ -2120,7 +2175,7 @@ int falcon_probe_port(struct efx_nic *efx)
 		return rc;
=20
 	/* Set up GMII structure for PHY */
-	efx->mii.supports_gmii =3D 1;
+	efx->mii.supports_gmii =3D true;
 	falcon_init_mdio(&efx->mii);
=20
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation=
 */
@@ -2168,6 +2223,170 @@ void falcon_set_multicast_hash(struct efx_nic *=
efx)
 	falcon_write(efx, &mc_hash->oword[1], MAC_MCAST_HASH_REG1_KER);
 }
=20
+
+/*********************************************************************=
*****
+ *
+ * Falcon test code
+ *
+ *********************************************************************=
*****/
+
+int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvc=
onfig_out)
+{
+	struct falcon_nvconfig *nvconfig;
+	struct efx_spi_device *spi;
+	void *region;
+	int rc, magic_num, struct_ver;
+	__le16 *word, *limit;
+	u32 csum;
+
+	region =3D kmalloc(NVCONFIG_END, GFP_KERNEL);
+	if (!region)
+		return -ENOMEM;
+	nvconfig =3D region + NVCONFIG_OFFSET;
+
+	spi =3D efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
+	rc =3D falcon_spi_read(spi, 0, NVCONFIG_END, NULL, region);
+	if (rc) {
+		EFX_ERR(efx, "Failed to read %s\n",
+			efx->spi_flash ? "flash" : "EEPROM");
+		rc =3D -EIO;
+		goto out;
+	}
+
+	magic_num =3D le16_to_cpu(nvconfig->board_magic_num);
+	struct_ver =3D le16_to_cpu(nvconfig->board_struct_ver);
+
+	rc =3D -EINVAL;
+	if (magic_num !=3D NVCONFIG_BOARD_MAGIC_NUM) {
+		EFX_ERR(efx, "NVRAM bad magic 0x%x\n", magic_num);
+		goto out;
+	}
+	if (struct_ver < 2) {
+		EFX_ERR(efx, "NVRAM has ancient version 0x%x\n", struct_ver);
+		goto out;
+	} else if (struct_ver < 4) {
+		word =3D &nvconfig->board_magic_num;
+		limit =3D (__le16 *) (nvconfig + 1);
+	} else {
+		word =3D region;
+		limit =3D region + NVCONFIG_END;
+	}
+	for (csum =3D 0; word < limit; ++word)
+		csum +=3D le16_to_cpu(*word);
+
+	if (~csum & 0xffff) {
+		EFX_ERR(efx, "NVRAM has incorrect checksum\n");
+		goto out;
+	}
+
+	rc =3D 0;
+	if (nvconfig_out)
+		memcpy(nvconfig_out, nvconfig, sizeof(*nvconfig));
+
+ out:
+	kfree(region);
+	return rc;
+}
+
+/* Registers tested in the falcon register test */
+static struct {
+	unsigned address;
+	efx_oword_t mask;
+} efx_test_registers[] =3D {
+	{ ADR_REGION_REG_KER,
+	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
+	{ RX_CFG_REG_KER,
+	  EFX_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
+	{ TX_CFG_REG_KER,
+	  EFX_OWORD32(0x7FFF0037, 0x00000000, 0x00000000, 0x00000000) },
+	{ TX_CFG2_REG_KER,
+	  EFX_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
+	{ MAC0_CTRL_REG_KER,
+	  EFX_OWORD32(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000) },
+	{ SRM_TX_DC_CFG_REG_KER,
+	  EFX_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ RX_DC_CFG_REG_KER,
+	  EFX_OWORD32(0x0000000F, 0x00000000, 0x00000000, 0x00000000) },
+	{ RX_DC_PF_WM_REG_KER,
+	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
+	{ DP_CTRL_REG,
+	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_GLB_CFG_REG,
+	  EFX_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_TX_CFG_REG,
+	  EFX_OWORD32(0x00080164, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_RX_CFG_REG,
+	  EFX_OWORD32(0x07100A0C, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_RX_PARAM_REG,
+	  EFX_OWORD32(0x00001FF8, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_FC_REG,
+	  EFX_OWORD32(0xFFFF0001, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_ADR_LO_REG,
+	  EFX_OWORD32(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ XX_SD_CTL_REG,
+	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
+};
+
+static bool efx_masked_compare_oword(const efx_oword_t *a, const efx_o=
word_t *b,
+				     const efx_oword_t *mask)
+{
+	return ((a->u64[0] ^ b->u64[0]) & mask->u64[0]) ||
+		((a->u64[1] ^ b->u64[1]) & mask->u64[1]);
+}
+
+int falcon_test_registers(struct efx_nic *efx)
+{
+	unsigned address =3D 0, i, j;
+	efx_oword_t mask, imask, original, reg, buf;
+
+	/* Falcon should be in loopback to isolate the XMAC from the PHY */
+	WARN_ON(!LOOPBACK_INTERNAL(efx));
+
+	for (i =3D 0; i < ARRAY_SIZE(efx_test_registers); ++i) {
+		address =3D efx_test_registers[i].address;
+		mask =3D imask =3D efx_test_registers[i].mask;
+		EFX_INVERT_OWORD(imask);
+
+		falcon_read(efx, &original, address);
+
+		/* bit sweep on and off */
+		for (j =3D 0; j < 128; j++) {
+			if (!EFX_EXTRACT_OWORD32(mask, j, j))
+				continue;
+
+			/* Test this testable bit can be set in isolation */
+			EFX_AND_OWORD(reg, original, mask);
+			EFX_SET_OWORD32(reg, j, j, 1);
+
+			falcon_write(efx, &reg, address);
+			falcon_read(efx, &buf, address);
+
+			if (efx_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+
+			/* Test this testable bit can be cleared in isolation */
+			EFX_OR_OWORD(reg, original, mask);
+			EFX_SET_OWORD32(reg, j, j, 0);
+
+			falcon_write(efx, &reg, address);
+			falcon_read(efx, &buf, address);
+
+			if (efx_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+		}
+
+		falcon_write(efx, &original, address);
+	}
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "wrote "EFX_OWORD_FMT" read "EFX_OWORD_FMT
+		" at address 0x%x mask "EFX_OWORD_FMT"\n", EFX_OWORD_VAL(reg),
+		EFX_OWORD_VAL(buf), address, EFX_OWORD_VAL(mask));
+	return -EIO;
+}
+
 /*********************************************************************=
*****
  *
  * Device reset
@@ -2305,68 +2524,103 @@ static int falcon_reset_sram(struct efx_nic *e=
fx)
 	return -ETIMEDOUT;
 }
=20
+static int falcon_spi_device_init(struct efx_nic *efx,
+				  struct efx_spi_device **spi_device_ret,
+				  unsigned int device_id, u32 device_type)
+{
+	struct efx_spi_device *spi_device;
+
+	if (device_type !=3D 0) {
+		spi_device =3D kmalloc(sizeof(*spi_device), GFP_KERNEL);
+		if (!spi_device)
+			return -ENOMEM;
+		spi_device->device_id =3D device_id;
+		spi_device->size =3D
+			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
+		spi_device->addr_len =3D
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
+		spi_device->munge_address =3D (spi_device->size =3D=3D 1 << 9 &&
+					     spi_device->addr_len =3D=3D 1);
+		spi_device->block_size =3D
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_BLOCK_SIZE);
+
+		spi_device->efx =3D efx;
+	} else {
+		spi_device =3D NULL;
+	}
+
+	kfree(*spi_device_ret);
+	*spi_device_ret =3D spi_device;
+	return 0;
+}
+
+
+static void falcon_remove_spi_devices(struct efx_nic *efx)
+{
+	kfree(efx->spi_eeprom);
+	efx->spi_eeprom =3D NULL;
+	kfree(efx->spi_flash);
+	efx->spi_flash =3D NULL;
+}
+
 /* Extract non-volatile configuration */
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
 	struct falcon_nvconfig *nvconfig;
-	efx_oword_t nic_stat;
-	int device_id;
-	unsigned addr_len;
-	size_t offset, len;
-	int magic_num, struct_ver, board_rev;
+	int board_rev;
 	int rc;
=20
-	/* Find the boot device. */
-	falcon_read(efx, &nic_stat, NIC_STAT_REG);
-	if (EFX_OWORD_FIELD(nic_stat, SF_PRST)) {
-		device_id =3D EE_SPI_FLASH;
-		addr_len =3D 3;
-	} else if (EFX_OWORD_FIELD(nic_stat, EE_PRST)) {
-		device_id =3D EE_SPI_EEPROM;
-		addr_len =3D 2;
-	} else {
-		return -ENODEV;
-	}
-
 	nvconfig =3D kmalloc(sizeof(*nvconfig), GFP_KERNEL);
+	if (!nvconfig)
+		return -ENOMEM;
=20
-	/* Read the whole configuration structure into memory. */
-	for (offset =3D 0; offset < sizeof(*nvconfig); offset +=3D len) {
-		len =3D min(sizeof(*nvconfig) - offset,
-			  (size_t) FALCON_SPI_MAX_LEN);
-		rc =3D falcon_spi_read(efx, device_id, SPI_READ,
-				     NVCONFIG_BASE + offset, addr_len,
-				     (char *)nvconfig + offset, len);
-		if (rc)
-			goto out;
-	}
-
-	/* Read the MAC addresses */
-	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
-
-	/* Read the board configuration. */
-	magic_num =3D le16_to_cpu(nvconfig->board_magic_num);
-	struct_ver =3D le16_to_cpu(nvconfig->board_struct_ver);
-
-	if (magic_num !=3D NVCONFIG_BOARD_MAGIC_NUM || struct_ver < 2) {
-		EFX_ERR(efx, "Non volatile memory bad magic=3D%x ver=3D%x "
-			"therefore using defaults\n", magic_num, struct_ver);
+	rc =3D falcon_read_nvram(efx, nvconfig);
+	if (rc =3D=3D -EINVAL) {
+		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
 		efx->phy_type =3D PHY_TYPE_NONE;
 		efx->mii.phy_id =3D PHY_ADDR_INVALID;
 		board_rev =3D 0;
+		rc =3D 0;
+	} else if (rc) {
+		goto fail1;
 	} else {
 		struct falcon_nvconfig_board_v2 *v2 =3D &nvconfig->board_v2;
+		struct falcon_nvconfig_board_v3 *v3 =3D &nvconfig->board_v3;
=20
 		efx->phy_type =3D v2->port0_phy_type;
 		efx->mii.phy_id =3D v2->port0_phy_addr;
 		board_rev =3D le16_to_cpu(v2->board_revision);
+
+		if (le16_to_cpu(nvconfig->board_struct_ver) >=3D 3) {
+			__le32 fl =3D v3->spi_device_type[EE_SPI_FLASH];
+			__le32 ee =3D v3->spi_device_type[EE_SPI_EEPROM];
+			rc =3D falcon_spi_device_init(efx, &efx->spi_flash,
+						    EE_SPI_FLASH,
+						    le32_to_cpu(fl));
+			if (rc)
+				goto fail2;
+			rc =3D falcon_spi_device_init(efx, &efx->spi_eeprom,
+						    EE_SPI_EEPROM,
+						    le32_to_cpu(ee));
+			if (rc)
+				goto fail2;
+		}
 	}
=20
+	/* Read the MAC addresses */
+	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
+
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mii.phy_id)=
;
=20
 	efx_set_board_info(efx, board_rev);
=20
- out:
+	kfree(nvconfig);
+	return 0;
+
+ fail2:
+	falcon_remove_spi_devices(efx);
+ fail1:
 	kfree(nvconfig);
 	return rc;
 }
@@ -2417,6 +2671,86 @@ static int falcon_probe_nic_variant(struct efx_n=
ic *efx)
 	return 0;
 }
=20
+/* Probe all SPI devices on the NIC */
+static void falcon_probe_spi_devices(struct efx_nic *efx)
+{
+	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
+	bool has_flash, has_eeprom, boot_is_external;
+
+	falcon_read(efx, &gpio_ctl, GPIO_CTL_REG_KER);
+	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+	falcon_read(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+
+	has_flash =3D EFX_OWORD_FIELD(nic_stat, SF_PRST);
+	has_eeprom =3D EFX_OWORD_FIELD(nic_stat, EE_PRST);
+	boot_is_external =3D EFX_OWORD_FIELD(gpio_ctl, BOOTED_USING_NVDEVICE)=
;
+
+	if (has_flash) {
+		/* Default flash SPI device: Atmel AT25F1024
+		 * 128 KB, 24-bit address, 32 KB erase block,
+		 * 256 B write block
+		 */
+		u32 flash_device_type =3D
+			(17 << SPI_DEV_TYPE_SIZE_LBN)
+			| (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+			| (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
+			| (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
+			| (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+
+		falcon_spi_device_init(efx, &efx->spi_flash,
+				       EE_SPI_FLASH, flash_device_type);
+
+		if (!boot_is_external) {
+			/* Disable VPD and set clock dividers to safe
+			 * values for initial programming.
+			 */
+			EFX_LOG(efx, "Booted from internal ASIC settings;"
+				" setting SPI config\n");
+			EFX_POPULATE_OWORD_3(ee_vpd_cfg, EE_VPD_EN, 0,
+					     /* 125 MHz / 7 ~=3D 20 MHz */
+					     EE_SF_CLOCK_DIV, 7,
+					     /* 125 MHz / 63 ~=3D 2 MHz */
+					     EE_EE_CLOCK_DIV, 63);
+			falcon_write(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+		}
+	}
+
+	if (has_eeprom) {
+		u32 eeprom_device_type;
+
+		/* If it has no flash, it must have a large EEPROM
+		 * for chip config; otherwise check whether 9-bit
+		 * addressing is used for VPD configuration
+		 */
+		if (has_flash &&
+		    (!boot_is_external ||
+		     EFX_OWORD_FIELD(ee_vpd_cfg, EE_VPD_EN_AD9_MODE))) {
+			/* Default SPI device: Atmel AT25040 or similar
+			 * 512 B, 9-bit address, 8 B write block
+			 */
+			eeprom_device_type =3D
+				(9 << SPI_DEV_TYPE_SIZE_LBN)
+				| (1 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+				| (3 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+		} else {
+			/* "Large" SPI device: Atmel AT25640 or similar
+			 * 8 KB, 16-bit address, 32 B write block
+			 */
+			eeprom_device_type =3D
+				(13 << SPI_DEV_TYPE_SIZE_LBN)
+				| (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+				| (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+		}
+
+		falcon_spi_device_init(efx, &efx->spi_eeprom,
+				       EE_SPI_EEPROM, eeprom_device_type);
+	}
+
+	EFX_LOG(efx, "flash is %s, EEPROM is %s\n",
+		(has_flash ? "present" : "absent"),
+		(has_eeprom ? "present" : "absent"));
+}
+
 int falcon_probe_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data;
@@ -2467,6 +2801,8 @@ int falcon_probe_nic(struct efx_nic *efx)
 		(unsigned long long)efx->irq_status.dma_addr,
 		efx->irq_status.addr, virt_to_phys(efx->irq_status.addr));
=20
+	falcon_probe_spi_devices(efx);
+
 	/* Read in the non-volatile configuration */
 	rc =3D falcon_probe_nvconfig(efx);
 	if (rc)
@@ -2486,6 +2822,7 @@ int falcon_probe_nic(struct efx_nic *efx)
 	return 0;
=20
  fail5:
+	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
  fail4:
  fail3:
@@ -2573,19 +2910,14 @@ int falcon_init_nic(struct efx_nic *efx)
 	EFX_INVERT_OWORD(temp);
 	falcon_write(efx, &temp, FATAL_INTR_REG_KER);
=20
-	/* Set number of RSS queues for receive path. */
-	falcon_read(efx, &temp, RX_FILTER_CTL_REG);
-	if (falcon_rev(efx) >=3D FALCON_REV_B0)
-		EFX_SET_OWORD_FIELD(temp, NUM_KER, 0);
-	else
-		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->rss_queues - 1);
 	if (EFX_WORKAROUND_7244(efx)) {
+		falcon_read(efx, &temp, RX_FILTER_CTL_REG);
 		EFX_SET_OWORD_FIELD(temp, UDP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, UDP_WILD_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, TCP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, TCP_WILD_SRCH_LIMIT, 8);
+		falcon_write(efx, &temp, RX_FILTER_CTL_REG);
 	}
-	falcon_write(efx, &temp, RX_FILTER_CTL_REG);
=20
 	falcon_setup_rss_indir_table(efx);
=20
@@ -2641,8 +2973,8 @@ int falcon_init_nic(struct efx_nic *efx)
 		  rx_xoff_thresh_bytes : efx->type->rx_xoff_thresh);
 	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_MAC_TH, thresh / 256);
 	/* RX control FIFO thresholds [32 entries] */
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_TX_TH, 25);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_TX_TH, 20);
+	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_TX_TH, 20);
+	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_TX_TH, 25);
 	falcon_write(efx, &temp, RX_CFG_REG_KER);
=20
 	/* Set destination of both TX and RX Flush events */
@@ -2662,6 +2994,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 	rc =3D i2c_del_adapter(&efx->i2c_adap);
 	BUG_ON(rc);
=20
+	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
=20
 	falcon_reset_hw(efx, RESET_TYPE_ALL);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 492f9bc..30d61e4 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -40,24 +40,24 @@ extern struct efx_nic_type falcon_b_nic_type;
=20
 /* TX data path */
 extern int falcon_probe_tx(struct efx_tx_queue *tx_queue);
-extern int falcon_init_tx(struct efx_tx_queue *tx_queue);
+extern void falcon_init_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_fini_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_remove_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_push_buffers(struct efx_tx_queue *tx_queue);
=20
 /* RX data path */
 extern int falcon_probe_rx(struct efx_rx_queue *rx_queue);
-extern int falcon_init_rx(struct efx_rx_queue *rx_queue);
+extern void falcon_init_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_fini_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_remove_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue);
=20
 /* Event data path */
 extern int falcon_probe_eventq(struct efx_channel *channel);
-extern int falcon_init_eventq(struct efx_channel *channel);
+extern void falcon_init_eventq(struct efx_channel *channel);
 extern void falcon_fini_eventq(struct efx_channel *channel);
 extern void falcon_remove_eventq(struct efx_channel *channel);
-extern int falcon_process_eventq(struct efx_channel *channel, int *rx_=
quota);
+extern int falcon_process_eventq(struct efx_channel *channel, int rx_q=
uota);
 extern void falcon_eventq_read_ack(struct efx_channel *channel);
=20
 /* Ports */
@@ -65,7 +65,7 @@ extern int falcon_probe_port(struct efx_nic *efx);
 extern void falcon_remove_port(struct efx_nic *efx);
=20
 /* MAC/PHY */
-extern int falcon_xaui_link_ok(struct efx_nic *efx);
+extern bool falcon_xaui_link_ok(struct efx_nic *efx);
 extern int falcon_dma_stats(struct efx_nic *efx,
 			    unsigned int done_offset);
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
@@ -93,6 +93,12 @@ extern void falcon_update_nic_stats(struct efx_nic *=
efx);
 extern void falcon_set_multicast_hash(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
=20
+/* Tests */
+struct falcon_nvconfig;
+extern int falcon_read_nvram(struct efx_nic *efx,
+			     struct falcon_nvconfig *nvconfig);
+extern int falcon_test_registers(struct efx_nic *efx);
+
 /*********************************************************************=
*****
  *
  * Falcon MAC stats
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_h=
wdefs.h
index 6d00311..e319fd6 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -92,6 +92,17 @@
 /* SPI host data register */
 #define EE_SPI_HDATA_REG_KER 0x0120
=20
+/* SPI/VPD config register */
+#define EE_VPD_CFG_REG_KER 0x0140
+#define EE_VPD_EN_LBN 0
+#define EE_VPD_EN_WIDTH 1
+#define EE_VPD_EN_AD9_MODE_LBN 1
+#define EE_VPD_EN_AD9_MODE_WIDTH 1
+#define EE_EE_CLOCK_DIV_LBN 112
+#define EE_EE_CLOCK_DIV_WIDTH 7
+#define EE_SF_CLOCK_DIV_LBN 120
+#define EE_SF_CLOCK_DIV_WIDTH 7
+
 /* PCIE CORE ACCESS REG */
 #define PCIE_CORE_ADDR_PCIE_DEVICE_CTRL_STAT 0x68
 #define PCIE_CORE_ADDR_PCIE_LINK_CTRL_STAT 0x70
@@ -115,6 +126,9 @@
 #define STRAP_PCIE_LBN 0
 #define STRAP_PCIE_WIDTH 1
=20
+#define BOOTED_USING_NVDEVICE_LBN 3
+#define BOOTED_USING_NVDEVICE_WIDTH 1
+
 /* GPIO control register */
 #define GPIO_CTL_REG_KER 0x0210
 #define GPIO_OUTPUTS_LBN   (16)
@@ -479,18 +493,8 @@
 #define MAC_MCAST_HASH_REG0_KER 0xca0
 #define MAC_MCAST_HASH_REG1_KER 0xcb0
=20
-/* GMAC registers */
-#define FALCON_GMAC_REGBANK 0xe00
-#define FALCON_GMAC_REGBANK_SIZE 0x200
-#define FALCON_GMAC_REG_SIZE 0x10
-
-/* XMAC registers */
-#define FALCON_XMAC_REGBANK 0x1200
-#define FALCON_XMAC_REGBANK_SIZE 0x200
-#define FALCON_XMAC_REG_SIZE 0x10
-
 /* XGMAC address register low */
-#define XM_ADR_LO_REG_MAC 0x00
+#define XM_ADR_LO_REG 0x1200
 #define XM_ADR_3_LBN 24
 #define XM_ADR_3_WIDTH 8
 #define XM_ADR_2_LBN 16
@@ -501,14 +505,14 @@
 #define XM_ADR_0_WIDTH 8
=20
 /* XGMAC address register high */
-#define XM_ADR_HI_REG_MAC 0x01
+#define XM_ADR_HI_REG 0x1210
 #define XM_ADR_5_LBN 8
 #define XM_ADR_5_WIDTH 8
 #define XM_ADR_4_LBN 0
 #define XM_ADR_4_WIDTH 8
=20
 /* XGMAC global configuration */
-#define XM_GLB_CFG_REG_MAC 0x02
+#define XM_GLB_CFG_REG 0x1220
 #define XM_RX_STAT_EN_LBN 11
 #define XM_RX_STAT_EN_WIDTH 1
 #define XM_TX_STAT_EN_LBN 10
@@ -521,7 +525,7 @@
 #define XM_CORE_RST_WIDTH 1
=20
 /* XGMAC transmit configuration */
-#define XM_TX_CFG_REG_MAC 0x03
+#define XM_TX_CFG_REG 0x1230
 #define XM_IPG_LBN 16
 #define XM_IPG_WIDTH 4
 #define XM_FCNTL_LBN 10
@@ -536,7 +540,7 @@
 #define XM_TXEN_WIDTH 1
=20
 /* XGMAC receive configuration */
-#define XM_RX_CFG_REG_MAC 0x04
+#define XM_RX_CFG_REG 0x1240
 #define XM_PASS_CRC_ERR_LBN 25
 #define XM_PASS_CRC_ERR_WIDTH 1
 #define XM_ACPT_ALL_MCAST_LBN 11
@@ -549,7 +553,7 @@
 #define XM_RXEN_WIDTH 1
=20
 /* XGMAC management interrupt mask register */
-#define XM_MGT_INT_MSK_REG_MAC_B0 0x5
+#define XM_MGT_INT_MSK_REG_B0 0x1250
 #define XM_MSK_PRMBLE_ERR_LBN 2
 #define XM_MSK_PRMBLE_ERR_WIDTH 1
 #define XM_MSK_RMTFLT_LBN 1
@@ -558,29 +562,29 @@
 #define XM_MSK_LCLFLT_WIDTH 1
=20
 /* XGMAC flow control register */
-#define XM_FC_REG_MAC 0x7
+#define XM_FC_REG 0x1270
 #define XM_PAUSE_TIME_LBN 16
 #define XM_PAUSE_TIME_WIDTH 16
 #define XM_DIS_FCNTL_LBN 0
 #define XM_DIS_FCNTL_WIDTH 1
=20
 /* XGMAC pause time count register */
-#define XM_PAUSE_TIME_REG_MAC 0x9
+#define XM_PAUSE_TIME_REG 0x1290
=20
 /* XGMAC transmit parameter register */
-#define XM_TX_PARAM_REG_MAC 0x0d
+#define XM_TX_PARAM_REG 0x012d0
 #define XM_TX_JUMBO_MODE_LBN 31
 #define XM_TX_JUMBO_MODE_WIDTH 1
 #define XM_MAX_TX_FRM_SIZE_LBN 16
 #define XM_MAX_TX_FRM_SIZE_WIDTH 14
=20
 /* XGMAC receive parameter register */
-#define XM_RX_PARAM_REG_MAC 0x0e
+#define XM_RX_PARAM_REG 0x12e0
 #define XM_MAX_RX_FRM_SIZE_LBN 0
 #define XM_MAX_RX_FRM_SIZE_WIDTH 14
=20
 /* XGMAC management interrupt status register */
-#define XM_MGT_INT_REG_MAC_B0 0x0f
+#define XM_MGT_INT_REG_B0 0x12f0
 #define XM_PRMBLE_ERR 2
 #define XM_PRMBLE_WIDTH 1
 #define XM_RMTFLT_LBN 1
@@ -589,7 +593,7 @@
 #define XM_LCLFLT_WIDTH 1
=20
 /* XGXS/XAUI powerdown/reset register */
-#define XX_PWR_RST_REG_MAC 0x10
+#define XX_PWR_RST_REG 0x1300
=20
 #define XX_PWRDND_EN_LBN 15
 #define XX_PWRDND_EN_WIDTH 1
@@ -619,7 +623,7 @@
 #define XX_RST_XX_EN_WIDTH 1
=20
 /* XGXS/XAUI powerdown/reset control register */
-#define XX_SD_CTL_REG_MAC 0x11
+#define XX_SD_CTL_REG 0x1310
 #define XX_HIDRVD_LBN 15
 #define XX_HIDRVD_WIDTH 1
 #define XX_LODRVD_LBN 14
@@ -645,7 +649,7 @@
 #define XX_LPBKA_LBN 0
 #define XX_LPBKA_WIDTH 1
=20
-#define XX_TXDRV_CTL_REG_MAC 0x12
+#define XX_TXDRV_CTL_REG 0x1320
 #define XX_DEQD_LBN 28
 #define XX_DEQD_WIDTH 4
 #define XX_DEQC_LBN 24
@@ -664,7 +668,7 @@
 #define XX_DTXA_WIDTH 4
=20
 /* XAUI XGXS core status register */
-#define XX_CORE_STAT_REG_MAC 0x16
+#define XX_CORE_STAT_REG 0x1360
 #define XX_FORCE_SIG_LBN 24
 #define XX_FORCE_SIG_WIDTH 8
 #define XX_FORCE_SIG_DECODE_FORCED 0xff
@@ -1127,7 +1131,28 @@ struct falcon_nvconfig_board_v2 {
 	__le16 board_revision;
 } __packed;
=20
-#define NVCONFIG_BASE 0x300
+/* Board configuration v3 extra information */
+struct falcon_nvconfig_board_v3 {
+	__le32 spi_device_type[2];
+} __packed;
+
+/* Bit numbers for spi_device_type */
+#define SPI_DEV_TYPE_SIZE_LBN 0
+#define SPI_DEV_TYPE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
+#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
+#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
+#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
+#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
+#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
+#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_FIELD(type, field)					\
+	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
+
+#define NVCONFIG_OFFSET 0x300
+#define NVCONFIG_END 0x400
+
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
 struct falcon_nvconfig {
 	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
@@ -1144,6 +1169,8 @@ struct falcon_nvconfig {
 	__le16 board_struct_ver;
 	__le16 board_checksum;
 	struct falcon_nvconfig_board_v2 board_v2;
+	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
+	struct falcon_nvconfig_board_v3 board_v3;
 } __packed;
=20
 #endif /* EFX_FALCON_HWDEFS_H */
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xma=
c.c
index 55c0d97..0d9f68f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -23,56 +23,24 @@
=20
 /*********************************************************************=
*****
  *
- * MAC register access
- *
- *********************************************************************=
*****/
-
-/* Offset of an XMAC register within Falcon */
-#define FALCON_XMAC_REG(mac_reg)					\
-	(FALCON_XMAC_REGBANK + ((mac_reg) * FALCON_XMAC_REG_SIZE))
-
-void falcon_xmac_writel(struct efx_nic *efx,
-			 efx_dword_t *value, unsigned int mac_reg)
-{
-	efx_oword_t temp;
-
-	EFX_POPULATE_OWORD_1(temp, MAC_DATA, EFX_DWORD_FIELD(*value, MAC_DATA=
));
-	falcon_write(efx, &temp, FALCON_XMAC_REG(mac_reg));
-}
-
-void falcon_xmac_readl(struct efx_nic *efx,
-		       efx_dword_t *value, unsigned int mac_reg)
-{
-	efx_oword_t temp;
-
-	falcon_read(efx, &temp, FALCON_XMAC_REG(mac_reg));
-	EFX_POPULATE_DWORD_1(*value, MAC_DATA, EFX_OWORD_FIELD(temp, MAC_DATA=
));
-}
-
-/*********************************************************************=
*****
- *
  * MAC operations
  *
  *********************************************************************=
****/
 static int falcon_reset_xmac(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	int count;
=20
-	EFX_POPULATE_DWORD_1(reg, XM_CORE_RST, 1);
-	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+	EFX_POPULATE_OWORD_1(reg, XM_CORE_RST, 1);
+	falcon_write(efx, &reg, XM_GLB_CFG_REG);
=20
 	for (count =3D 0; count < 10000; count++) {	/* wait upto 100ms */
-		falcon_xmac_readl(efx, &reg, XM_GLB_CFG_REG_MAC);
-		if (EFX_DWORD_FIELD(reg, XM_CORE_RST) =3D=3D 0)
+		falcon_read(efx, &reg, XM_GLB_CFG_REG);
+		if (EFX_OWORD_FIELD(reg, XM_CORE_RST) =3D=3D 0)
 			return 0;
 		udelay(10);
 	}
=20
-	/* This often fails when DSP is disabled, ignore it */
-	if (sfe4001_phy_flash_cfg !=3D 0)
-		return 0;
-
 	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
 	return -ETIMEDOUT;
 }
@@ -80,25 +48,25 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 /* Configure the XAUI driver that is an output from Falcon */
 static void falcon_setup_xaui(struct efx_nic *efx)
 {
-	efx_dword_t sdctl, txdrv;
+	efx_oword_t sdctl, txdrv;
=20
 	/* Move the XAUI into low power, unless there is no PHY, in
 	 * which case the XAUI will have to drive a cable. */
 	if (efx->phy_type =3D=3D PHY_TYPE_NONE)
 		return;
=20
-	falcon_xmac_readl(efx, &sdctl, XX_SD_CTL_REG_MAC);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
-	falcon_xmac_writel(efx, &sdctl, XX_SD_CTL_REG_MAC);
-
-	EFX_POPULATE_DWORD_8(txdrv,
+	falcon_read(efx, &sdctl, XX_SD_CTL_REG);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
+	falcon_write(efx, &sdctl, XX_SD_CTL_REG);
+
+	EFX_POPULATE_OWORD_8(txdrv,
 			     XX_DEQD, XX_TXDRV_DEQ_DEFAULT,
 			     XX_DEQC, XX_TXDRV_DEQ_DEFAULT,
 			     XX_DEQB, XX_TXDRV_DEQ_DEFAULT,
@@ -107,67 +75,67 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 			     XX_DTXC, XX_TXDRV_DTX_DEFAULT,
 			     XX_DTXB, XX_TXDRV_DTX_DEFAULT,
 			     XX_DTXA, XX_TXDRV_DTX_DEFAULT);
-	falcon_xmac_writel(efx, &txdrv, XX_TXDRV_CTL_REG_MAC);
+	falcon_write(efx, &txdrv, XX_TXDRV_CTL_REG);
 }
=20
 static void falcon_hold_xaui_in_rst(struct efx_nic *efx)
 {
-	efx_dword_t reg;
-
-	EFX_ZERO_DWORD(reg);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	efx_oword_t reg;
+
+	EFX_ZERO_OWORD(reg);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 }
=20
 static int _falcon_reset_xaui_a(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
=20
 	falcon_hold_xaui_in_rst(efx);
-	falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_read(efx, &reg, XX_PWR_RST_REG);
=20
 	/* Follow the RAMBUS XAUI data reset sequencing
 	 * Channels A and B first: power down, reset PLL, reset, clear
 	 */
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
-	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
 	/* Channels C and D: power down, reset PLL, reset, clear */
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
-	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
 	/* Setup XAUI */
@@ -175,8 +143,8 @@ static int _falcon_reset_xaui_a(struct efx_nic *efx=
)
 	udelay(10);
=20
 	/* Take XGXS out of reset */
-	EFX_ZERO_DWORD(reg);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_ZERO_OWORD(reg);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
 	return 0;
@@ -184,16 +152,16 @@ static int _falcon_reset_xaui_a(struct efx_nic *e=
fx)
=20
 static int _falcon_reset_xaui_b(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	int count;
=20
 	EFX_POPULATE_DWORD_1(reg, XX_RST_XX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
=20
 	/* Give some time for the link to establish */
 	for (count =3D 0; count < 1000; count++) { /* wait upto 10ms */
-		falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
-		if (EFX_DWORD_FIELD(reg, XX_RST_XX_EN) =3D=3D 0) {
+		falcon_read(efx, &reg, XX_PWR_RST_REG);
+		if (EFX_OWORD_FIELD(reg, XX_RST_XX_EN) =3D=3D 0) {
 			falcon_setup_xaui(efx);
 			return 0;
 		}
@@ -217,41 +185,41 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	return rc;
 }
=20
-static int falcon_xgmii_status(struct efx_nic *efx)
+static bool falcon_xgmii_status(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
=20
 	if (falcon_rev(efx) < FALCON_REV_B0)
-		return 1;
+		return true;
=20
 	/* The ISR latches, so clear it and re-read */
-	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
-	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
+	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
+	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
=20
-	if (EFX_DWORD_FIELD(reg, XM_LCLFLT) ||
-	    EFX_DWORD_FIELD(reg, XM_RMTFLT)) {
+	if (EFX_OWORD_FIELD(reg, XM_LCLFLT) ||
+	    EFX_OWORD_FIELD(reg, XM_RMTFLT)) {
 		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));
-		return 0;
+		return false;
 	}
=20
-	return 1;
+	return true;
 }
=20
-static void falcon_mask_status_intr(struct efx_nic *efx, int enable)
+static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
=20
 	if ((falcon_rev(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
=20
 	/* Flush the ISR */
 	if (enable)
-		falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
+		falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
=20
-	EFX_POPULATE_DWORD_2(reg,
+	EFX_POPULATE_OWORD_2(reg,
 			     XM_MSK_RMTFLT, !enable,
 			     XM_MSK_LCLFLT, !enable);
-	falcon_xmac_writel(efx, &reg, XM_MGT_INT_MSK_REG_MAC_B0);
+	falcon_write(efx, &reg, XM_MGT_INT_MSK_REG_B0);
 }
=20
 int falcon_init_xmac(struct efx_nic *efx)
@@ -274,7 +242,7 @@ int falcon_init_xmac(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
=20
-	falcon_mask_status_intr(efx, 1);
+	falcon_mask_status_intr(efx, true);
 	return 0;
=20
  fail2:
@@ -283,34 +251,34 @@ int falcon_init_xmac(struct efx_nic *efx)
 	return rc;
 }
=20
-int falcon_xaui_link_ok(struct efx_nic *efx)
+bool falcon_xaui_link_ok(struct efx_nic *efx)
 {
-	efx_dword_t reg;
-	int align_done, sync_status, link_ok =3D 0;
+	efx_oword_t reg;
+	bool align_done, link_ok =3D false;
+	int sync_status;
=20
 	if (LOOPBACK_INTERNAL(efx))
-		return 1;
+		return true;
=20
 	/* Read link status */
-	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+	falcon_read(efx, &reg, XX_CORE_STAT_REG);
=20
-	align_done =3D EFX_DWORD_FIELD(reg, XX_ALIGN_DONE);
-	sync_status =3D EFX_DWORD_FIELD(reg, XX_SYNC_STAT);
+	align_done =3D EFX_OWORD_FIELD(reg, XX_ALIGN_DONE);
+	sync_status =3D EFX_OWORD_FIELD(reg, XX_SYNC_STAT);
 	if (align_done && (sync_status =3D=3D XX_SYNC_STAT_DECODE_SYNCED))
-		link_ok =3D 1;
+		link_ok =3D true;
=20
 	/* Clear link status ready for next read */
-	EFX_SET_DWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
-	EFX_SET_DWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
-	EFX_SET_DWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
-	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
+	EFX_SET_OWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
+	EFX_SET_OWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
+	falcon_write(efx, &reg, XX_CORE_STAT_REG);
=20
 	/* If the link is up, then check the phy side of the xaui link
 	 * (error conditions from the wire side propoagate back through
 	 * the phy to the xaui side). */
 	if (efx->link_up && link_ok) {
-		int has_phyxs =3D efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS);
-		if (has_phyxs)
+		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
 			link_ok =3D mdio_clause45_phyxgxs_lane_sync(efx);
 	}
=20
@@ -325,15 +293,15 @@ int falcon_xaui_link_ok(struct efx_nic *efx)
 static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
-	efx_dword_t reg;
-	int rx_fc =3D (efx->flow_control & EFX_FC_RX) ? 1 : 0;
+	efx_oword_t reg;
+	bool rx_fc =3D !!(efx->flow_control & EFX_FC_RX);
=20
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_DWORD_3(reg,
 			     XM_RX_JUMBO_MODE, 1,
 			     XM_TX_STAT_EN, 1,
 			     XM_RX_STAT_EN, 1);
-	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_GLB_CFG_REG);
=20
 	/* Configure TX */
 	EFX_POPULATE_DWORD_6(reg,
@@ -343,7 +311,7 @@ static void falcon_reconfigure_xmac_core(struct efx=
_nic *efx)
 			     XM_TXCRC, 1,
 			     XM_FCNTL, 1,
 			     XM_IPG, 0x3);
-	falcon_xmac_writel(efx, &reg, XM_TX_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_TX_CFG_REG);
=20
 	/* Configure RX */
 	EFX_POPULATE_DWORD_5(reg,
@@ -352,21 +320,21 @@ static void falcon_reconfigure_xmac_core(struct e=
fx_nic *efx)
 			     XM_ACPT_ALL_MCAST, 1,
 			     XM_ACPT_ALL_UCAST, efx->promiscuous,
 			     XM_PASS_CRC_ERR, 1);
-	falcon_xmac_writel(efx, &reg, XM_RX_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_RX_CFG_REG);
=20
 	/* Set frame length */
 	max_frame_len =3D EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
 	EFX_POPULATE_DWORD_1(reg, XM_MAX_RX_FRM_SIZE, max_frame_len);
-	falcon_xmac_writel(efx, &reg, XM_RX_PARAM_REG_MAC);
+	falcon_write(efx, &reg, XM_RX_PARAM_REG);
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_MAX_TX_FRM_SIZE, max_frame_len,
 			     XM_TX_JUMBO_MODE, 1);
-	falcon_xmac_writel(efx, &reg, XM_TX_PARAM_REG_MAC);
+	falcon_write(efx, &reg, XM_TX_PARAM_REG);
=20
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
-			     XM_DIS_FCNTL, rx_fc ? 0 : 1);
-	falcon_xmac_writel(efx, &reg, XM_FC_REG_MAC);
+			     XM_DIS_FCNTL, !rx_fc);
+	falcon_write(efx, &reg, XM_FC_REG);
=20
 	/* Set MAC address */
 	EFX_POPULATE_DWORD_4(reg,
@@ -374,83 +342,75 @@ static void falcon_reconfigure_xmac_core(struct e=
fx_nic *efx)
 			     XM_ADR_1, efx->net_dev->dev_addr[1],
 			     XM_ADR_2, efx->net_dev->dev_addr[2],
 			     XM_ADR_3, efx->net_dev->dev_addr[3]);
-	falcon_xmac_writel(efx, &reg, XM_ADR_LO_REG_MAC);
+	falcon_write(efx, &reg, XM_ADR_LO_REG);
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_ADR_4, efx->net_dev->dev_addr[4],
 			     XM_ADR_5, efx->net_dev->dev_addr[5]);
-	falcon_xmac_writel(efx, &reg, XM_ADR_HI_REG_MAC);
+	falcon_write(efx, &reg, XM_ADR_HI_REG);
 }
=20
 static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 {
-	efx_dword_t reg;
-	int xgxs_loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_XGXS) ? 1 :=
 0;
-	int xaui_loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_XAUI) ? 1 :=
 0;
-	int xgmii_loopback =3D
-		(efx->loopback_mode =3D=3D LOOPBACK_XGMII) ? 1 : 0;
+	efx_oword_t reg;
+	bool xgxs_loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_XGXS);
+	bool xaui_loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_XAUI);
+	bool xgmii_loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_XGMII);
=20
 	/* XGXS block is flaky and will need to be reset if moving
 	 * into our out of XGMII, XGXS or XAUI loopbacks. */
 	if (EFX_WORKAROUND_5147(efx)) {
-		int old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
-		int reset_xgxs;
+		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
+		bool reset_xgxs;
=20
-		falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
-		old_xgxs_loopback =3D EFX_DWORD_FIELD(reg, XX_XGXS_LB_EN);
-		old_xgmii_loopback =3D EFX_DWORD_FIELD(reg, XX_XGMII_LB_EN);
+		falcon_read(efx, &reg, XX_CORE_STAT_REG);
+		old_xgxs_loopback =3D EFX_OWORD_FIELD(reg, XX_XGXS_LB_EN);
+		old_xgmii_loopback =3D EFX_OWORD_FIELD(reg, XX_XGMII_LB_EN);
=20
-		falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
-		old_xaui_loopback =3D EFX_DWORD_FIELD(reg, XX_LPBKA);
+		falcon_read(efx, &reg, XX_SD_CTL_REG);
+		old_xaui_loopback =3D EFX_OWORD_FIELD(reg, XX_LPBKA);
=20
 		/* The PHY driver may have turned XAUI off */
 		reset_xgxs =3D ((xgxs_loopback !=3D old_xgxs_loopback) ||
 			      (xaui_loopback !=3D old_xaui_loopback) ||
 			      (xgmii_loopback !=3D old_xgmii_loopback));
-		if (reset_xgxs) {
-			falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
-			udelay(1);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
-			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
-			udelay(1);
-		}
+
+		if (reset_xgxs)
+			falcon_reset_xaui(efx);
 	}
=20
-	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
-	EFX_SET_DWORD_FIELD(reg, XX_FORCE_SIG,
+	falcon_read(efx, &reg, XX_CORE_STAT_REG);
+	EFX_SET_OWORD_FIELD(reg, XX_FORCE_SIG,
 			    (xgxs_loopback || xaui_loopback) ?
 			    XX_FORCE_SIG_DECODE_FORCED : 0);
-	EFX_SET_DWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
-	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
-
-	falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
-	falcon_xmac_writel(efx, &reg, XX_SD_CTL_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
+	falcon_write(efx, &reg, XX_CORE_STAT_REG);
+
+	falcon_read(efx, &reg, XX_SD_CTL_REG);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
+	falcon_write(efx, &reg, XX_SD_CTL_REG);
 }
=20
=20
 /* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
  * to come back up. Bash it until it comes back up */
-static int falcon_check_xaui_link_up(struct efx_nic *efx)
+static bool falcon_check_xaui_link_up(struct efx_nic *efx)
 {
 	int max_tries, tries;
 	tries =3D EFX_WORKAROUND_5147(efx) ? 5 : 1;
 	max_tries =3D tries;
=20
 	if ((efx->loopback_mode =3D=3D LOOPBACK_NETWORK) ||
-	    (efx->phy_type =3D=3D PHY_TYPE_NONE))
-		return 0;
+	    (efx->phy_type =3D=3D PHY_TYPE_NONE) ||
+	    efx_phy_mode_disabled(efx->phy_mode))
+		return false;
=20
 	while (tries) {
 		if (falcon_xaui_link_ok(efx))
-			return 1;
+			return true;
=20
 		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
 			__func__, tries);
@@ -461,18 +421,22 @@ static int falcon_check_xaui_link_up(struct efx_n=
ic *efx)
=20
 	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
 		max_tries);
-	return 0;
+	return false;
 }
=20
 void falcon_reconfigure_xmac(struct efx_nic *efx)
 {
-	int xaui_link_ok;
+	bool xaui_link_ok;
=20
-	falcon_mask_status_intr(efx, 0);
+	falcon_mask_status_intr(efx, false);
=20
 	falcon_deconfigure_mac_wrapper(efx);
=20
-	efx->tx_disabled =3D LOOPBACK_INTERNAL(efx);
+	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
+	if (LOOPBACK_INTERNAL(efx))
+		efx->phy_mode |=3D PHY_MODE_TX_DISABLED;
+	else
+		efx->phy_mode &=3D ~PHY_MODE_TX_DISABLED;
 	efx->phy_op->reconfigure(efx);
=20
 	falcon_reconfigure_xgxs_core(efx);
@@ -484,7 +448,7 @@ void falcon_reconfigure_xmac(struct efx_nic *efx)
 	xaui_link_ok =3D falcon_check_xaui_link_up(efx);
=20
 	if (xaui_link_ok && efx->link_up)
-		falcon_mask_status_intr(efx, 1);
+		falcon_mask_status_intr(efx, true);
 }
=20
 void falcon_fini_xmac(struct efx_nic *efx)
@@ -554,21 +518,23 @@ void falcon_update_stats_xmac(struct efx_nic *efx=
)
=20
 	/* Update derived statistics */
 	mac_stats->tx_good_bytes =3D
-		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes);
+		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes -
+		 mac_stats->tx_control * 64);
 	mac_stats->rx_bad_bytes =3D
-		(mac_stats->rx_bytes - mac_stats->rx_good_bytes);
+		(mac_stats->rx_bytes - mac_stats->rx_good_bytes -
+		 mac_stats->rx_control * 64);
 }
=20
 int falcon_check_xmac(struct efx_nic *efx)
 {
-	unsigned xaui_link_ok;
+	bool xaui_link_ok;
 	int rc;
=20
 	if ((efx->loopback_mode =3D=3D LOOPBACK_NETWORK) ||
-	    (efx->phy_type =3D=3D PHY_TYPE_NONE))
+	    efx_phy_mode_disabled(efx->phy_mode))
 		return 0;
=20
-	falcon_mask_status_intr(efx, 0);
+	falcon_mask_status_intr(efx, false);
 	xaui_link_ok =3D falcon_xaui_link_ok(efx);
=20
 	if (EFX_WORKAROUND_5147(efx) && !xaui_link_ok)
@@ -579,7 +545,7 @@ int falcon_check_xmac(struct efx_nic *efx)
=20
 	/* Unmask interrupt if everything was (and still is) ok */
 	if (xaui_link_ok && efx->link_up)
-		falcon_mask_status_intr(efx, 1);
+		falcon_mask_status_intr(efx, true);
=20
 	return rc;
 }
@@ -620,7 +586,7 @@ int falcon_xmac_set_settings(struct efx_nic *efx, s=
truct ethtool_cmd *ecmd)
=20
 int falcon_xmac_set_pause(struct efx_nic *efx, enum efx_fc_type flow_c=
ontrol)
 {
-	int reset;
+	bool reset;
=20
 	if (flow_control & EFX_FC_AUTO) {
 		EFX_LOG(efx, "10G does not support flow control "
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index edd07d4..a31571c 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -13,10 +13,6 @@
=20
 #include "net_driver.h"
=20
-extern void falcon_xmac_writel(struct efx_nic *efx,
-			       efx_dword_t *value, unsigned int mac_reg);
-extern void falcon_xmac_readl(struct efx_nic *efx,
-			      efx_dword_t *value, unsigned int mac_reg);
 extern int falcon_init_xmac(struct efx_nic *efx);
 extern void falcon_reconfigure_xmac(struct efx_nic *efx);
 extern void falcon_update_stats_xmac(struct efx_nic *efx);
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index c4f540e..003e48d 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -159,20 +159,21 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 	return 0;
 }
=20
-int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
+bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask=
)
 {
 	int phy_id =3D efx->mii.phy_id;
 	int status;
-	int ok =3D 1;
+	bool ok =3D true;
 	int mmd =3D 0;
-	int good;
=20
 	/* If the port is in loopback, then we should only consider a subset
 	 * of mmd's */
 	if (LOOPBACK_INTERNAL(efx))
-		return 1;
+		return true;
 	else if (efx->loopback_mode =3D=3D LOOPBACK_NETWORK)
-		return 0;
+		return false;
+	else if (efx_phy_mode_disabled(efx->phy_mode))
+		return false;
 	else if (efx->loopback_mode =3D=3D LOOPBACK_PHYXS)
 		mmd_mask &=3D ~(MDIO_MMDREG_DEVS0_PHYXS |
 			      MDIO_MMDREG_DEVS0_PCS |
@@ -192,8 +193,7 @@ int mdio_clause45_links_ok(struct efx_nic *efx, uns=
igned int mmd_mask)
 			status =3D mdio_clause45_read(efx, phy_id,
 						    mmd, MDIO_MMDREG_STAT1);
=20
-			good =3D status & (1 << MDIO_MMDREG_STAT1_LINK_LBN);
-			ok =3D ok && good;
+			ok =3D ok && (status & (1 << MDIO_MMDREG_STAT1_LINK_LBN));
 		}
 		mmd_mask =3D (mmd_mask >> 1);
 		mmd++;
@@ -208,7 +208,7 @@ void mdio_clause45_transmit_disable(struct efx_nic =
*efx)
=20
 	ctrl1 =3D ctrl2 =3D mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
 					   MDIO_MMDREG_TXDIS);
-	if (efx->tx_disabled)
+	if (efx->phy_mode & PHY_MODE_TX_DISABLED)
 		ctrl2 |=3D (1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
 	else
 		ctrl1 &=3D ~(1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index cb99f3f..19c42ea 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -199,18 +199,19 @@ static inline u32 mdio_clause45_read_id(struct ef=
x_nic *efx, int mmd)
 	return (id_hi << 16) | (id_low);
 }
=20
-static inline int mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
+static inline bool mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx=
)
 {
-	int i, sync, lane_status;
+	int i, lane_status;
+	bool sync;
=20
 	for (i =3D 0; i < 2; ++i)
 		lane_status =3D mdio_clause45_read(efx, efx->mii.phy_id,
 						 MDIO_MMD_PHYXS,
 						 MDIO_PHYXS_LANE_STATE);
=20
-	sync =3D (lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN)) !=3D 0;
+	sync =3D !!(lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN));
 	if (!sync)
-		EFX_INFO(efx, "XGXS lane status: %x\n", lane_status);
+		EFX_LOG(efx, "XGXS lane status: %x\n", lane_status);
 	return sync;
 }
=20
@@ -230,8 +231,8 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 			     unsigned int mmd_mask, unsigned int fatal_mask);
=20
 /* Check the link status of specified mmds in bit mask */
-extern int mdio_clause45_links_ok(struct efx_nic *efx,
-				  unsigned int mmd_mask);
+extern bool mdio_clause45_links_ok(struct efx_nic *efx,
+				   unsigned int mmd_mask);
=20
 /* Generic transmit disable support though PMAPMD */
 extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index 219c74a..567df00 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -88,9 +88,12 @@ do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); =
} while (0)
  *********************************************************************=
*****/
=20
 #define EFX_MAX_CHANNELS 32
-#define EFX_MAX_TX_QUEUES 1
 #define EFX_MAX_RX_QUEUES EFX_MAX_CHANNELS
=20
+#define EFX_TX_QUEUE_OFFLOAD_CSUM	0
+#define EFX_TX_QUEUE_NO_CSUM		1
+#define EFX_TX_QUEUE_COUNT		2
+
 /**
  * struct efx_special_buffer - An Efx special buffer
  * @addr: CPU base address of the buffer
@@ -127,7 +130,6 @@ struct efx_special_buffer {
  *	This field is zero when the queue slot is empty.
  * @continuation: True if this fragment is not the end of a packet.
  * @unmap_single: True if pci_unmap_single should be used.
- * @unmap_addr: DMA address to unmap
  * @unmap_len: Length of this fragment to unmap
  */
 struct efx_tx_buffer {
@@ -135,9 +137,8 @@ struct efx_tx_buffer {
 	struct efx_tso_header *tsoh;
 	dma_addr_t dma_addr;
 	unsigned short len;
-	unsigned char continuation;
-	unsigned char unmap_single;
-	dma_addr_t unmap_addr;
+	bool continuation;
+	bool unmap_single;
 	unsigned short unmap_len;
 };
=20
@@ -156,13 +157,12 @@ struct efx_tx_buffer {
  *
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
- * @used: Queue is used by net driver
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both ring=
s.
- * @stopped: Stopped flag.
+ * @stopped: Stopped count.
  *	Set if this TX queue is currently stopping its port.
  * @insert_count: Current insert pointer
  *	This is the number of buffers that have been added to the
@@ -188,7 +188,6 @@ struct efx_tx_queue {
 	/* Members which don't change on the fast path */
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
 	int queue;
-	int used;
 	struct efx_channel *channel;
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
@@ -232,7 +231,6 @@ struct efx_rx_buffer {
  * struct efx_rx_queue - An Efx RX queue
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
- * @used: Queue is used by net driver
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
@@ -266,7 +264,6 @@ struct efx_rx_buffer {
 struct efx_rx_queue {
 	struct efx_nic *efx;
 	int queue;
-	int used;
 	struct efx_channel *channel;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
@@ -325,12 +322,10 @@ enum efx_rx_alloc_method {
  * queue.
  *
  * @efx: Associated Efx NIC
- * @evqnum: Event queue number
  * @channel: Channel instance number
  * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
- * @has_interrupt: Channel has an interrupt
  * @irq_moderation: IRQ moderation value (in us)
  * @napi_dev: Net device used with NAPI
  * @napi_str: NAPI control structure
@@ -357,17 +352,14 @@ enum efx_rx_alloc_method {
  */
 struct efx_channel {
 	struct efx_nic *efx;
-	int evqnum;
 	int channel;
 	int used_flags;
-	int enabled;
+	bool enabled;
 	int irq;
-	unsigned int has_interrupt;
 	unsigned int irq_moderation;
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
-	struct work_struct reset_work;
-	int work_pending;
+	bool work_pending;
 	struct efx_special_buffer eventq;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
@@ -390,7 +382,7 @@ struct efx_channel {
 	 * access with prefetches.
 	 */
 	struct efx_rx_buffer *rx_pkt;
-	int rx_pkt_csummed;
+	bool rx_pkt_csummed;
=20
 };
=20
@@ -403,8 +395,8 @@ struct efx_channel {
  */
 struct efx_blinker {
 	int led_num;
-	int state;
-	int resubmit;
+	bool state;
+	bool resubmit;
 	struct timer_list timer;
 };
=20
@@ -432,8 +424,8 @@ struct efx_board {
 	 * have a separate init callback that happens later than
 	 * board init. */
 	int (*init_leds)(struct efx_nic *efx);
-	void (*set_fault_led) (struct efx_nic *efx, int state);
-	void (*blink) (struct efx_nic *efx, int start);
+	void (*set_fault_led) (struct efx_nic *efx, bool state);
+	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
 	struct efx_blinker blinker;
 	struct i2c_client *hwmon_client, *ioexp_client;
@@ -467,8 +459,7 @@ enum nic_state {
 	STATE_INIT =3D 0,
 	STATE_RUNNING =3D 1,
 	STATE_FINI =3D 2,
-	STATE_RESETTING =3D 3, /* rtnl_lock always held */
-	STATE_DISABLED =3D 4,
+	STATE_DISABLED =3D 3,
 	STATE_MAX,
 };
=20
@@ -523,10 +514,28 @@ struct efx_phy_operations {
 	void (*clear_interrupt) (struct efx_nic *efx);
 	int (*check_hw) (struct efx_nic *efx);
 	void (*reset_xaui) (struct efx_nic *efx);
+	int (*test) (struct efx_nic *efx);
 	int mmds;
 	unsigned loopbacks;
 };
=20
+/**
+ * @enum efx_phy_mode - PHY operating mode flags
+ * @PHY_MODE_NORMAL: on and should pass traffic
+ * @PHY_MODE_TX_DISABLED: on with TX disabled
+ * @PHY_MODE_SPECIAL: on but will not pass traffic
+ */
+enum efx_phy_mode {
+	PHY_MODE_NORMAL		=3D 0,
+	PHY_MODE_TX_DISABLED	=3D 1,
+	PHY_MODE_SPECIAL	=3D 8,
+};
+
+static inline bool efx_phy_mode_disabled(enum efx_phy_mode mode)
+{
+	return !!(mode & ~PHY_MODE_TX_DISABLED);
+}
+
 /*
  * Efx extended statistics
  *
@@ -632,7 +641,7 @@ union efx_multicast_hash {
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
- * @rss_queues: Number of RSS queues
+ * @n_rx_queues: Number of RX queues
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffe=
r
  * @irq_status: Interrupt status buffer
@@ -640,15 +649,20 @@ union efx_multicast_hash {
  *	This register is written with the SMP processor ID whenever an
  *	interrupt is handled.  It is used by falcon_test_interrupt()
  *	to verify that an interrupt has occurred.
+ * @spi_flash: SPI flash device
+ *	This field will be %NULL if no flash device is present.
+ * @spi_eeprom: SPI EEPROM device
+ *	This field will be %NULL if no EEPROM device is present.
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
- * @mac_lock: MAC access lock. Protects @port_enabled, efx_monitor() a=
nd
- *	efx_reconfigure_port()
+ * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
+ *	@port_inhibited, efx_monitor() and efx_reconfigure_port()
  * @port_enabled: Port enabled indicator.
  *	Serialises efx_stop_all(), efx_start_all() and efx_monitor() and
  *	efx_reconfigure_work with kernel interfaces. Safe to read under any
  *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three mus=
t
  *	be held to modify it.
+ * @port_inhibited: If set, the netif_carrier is always off. Hold the =
mac_lock
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtn=
l lock
  * @rx_checksum_enabled: RX checksumming enabled
@@ -658,14 +672,16 @@ union efx_multicast_hash {
  *	can provide.  Generic code converts these into a standard
  *	&struct net_device_stats.
  * @stats_buffer: DMA buffer for statistics
- * @stats_lock: Statistics update lock
+ * @stats_lock: Statistics update lock. Serialises statistics fetches
+ * @stats_enabled: Temporarily disable statistics fetches.
+ *	Serialised by @stats_lock
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
  * @phy_lock: PHY access lock
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
- * @tx_disabled: PHY transmitter turned off
+ * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
  * @n_link_state_changes: Number of times the link has changed state
@@ -700,27 +716,31 @@ struct efx_nic {
 	enum nic_state state;
 	enum reset_type reset_pending;
=20
-	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
+	struct efx_tx_queue tx_queue[EFX_TX_QUEUE_COUNT];
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
=20
-	int rss_queues;
+	int n_rx_queues;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
=20
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
=20
+	struct efx_spi_device *spi_flash;
+	struct efx_spi_device *spi_eeprom;
+
 	unsigned n_rx_nodesc_drop_cnt;
=20
 	struct falcon_nic_data *nic_data;
=20
 	struct mutex mac_lock;
-	int port_enabled;
+	bool port_enabled;
+	bool port_inhibited;
=20
-	int port_initialized;
+	bool port_initialized;
 	struct net_device *net_dev;
-	int rx_checksum_enabled;
+	bool rx_checksum_enabled;
=20
 	atomic_t netif_stop_count;
 	spinlock_t netif_stop_lock;
@@ -728,6 +748,7 @@ struct efx_nic {
 	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
 	spinlock_t stats_lock;
+	bool stats_enabled;
=20
 	unsigned char mac_address[ETH_ALEN];
=20
@@ -736,13 +757,13 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mii_if_info mii;
-	unsigned tx_disabled;
+	enum efx_phy_mode phy_mode;
=20
-	int link_up;
+	bool link_up;
 	unsigned int link_options;
 	unsigned int n_link_state_changes;
=20
-	int promiscuous;
+	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
 	enum efx_fc_type flow_control;
 	struct work_struct reconfigure_work;
@@ -829,50 +850,33 @@ struct efx_nic_type {
 			continue;					\
 		else
=20
-/* Iterate over all used channels with interrupts */
-#define efx_for_each_channel_with_interrupt(_channel, _efx)		\
-	for (_channel =3D &_efx->channel[0];				\
-	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
-	     _channel++)						\
-		if (!(_channel->used_flags && _channel->has_interrupt))	\
-			continue;					\
-		else
-
 /* Iterate over all used TX queues */
 #define efx_for_each_tx_queue(_tx_queue, _efx)				\
 	for (_tx_queue =3D &_efx->tx_queue[0];				\
-	     _tx_queue < &_efx->tx_queue[EFX_MAX_TX_QUEUES];		\
-	     _tx_queue++)						\
-		if (!_tx_queue->used)					\
-			continue;					\
-		else
+	     _tx_queue < &_efx->tx_queue[EFX_TX_QUEUE_COUNT];		\
+	     _tx_queue++)
=20
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
 	for (_tx_queue =3D &_channel->efx->tx_queue[0];			\
-	     _tx_queue < &_channel->efx->tx_queue[EFX_MAX_TX_QUEUES];	\
+	     _tx_queue < &_channel->efx->tx_queue[EFX_TX_QUEUE_COUNT];	\
 	     _tx_queue++)						\
-		if ((!_tx_queue->used) ||				\
-		    (_tx_queue->channel !=3D _channel))			\
+		if (_tx_queue->channel !=3D _channel)			\
 			continue;					\
 		else
=20
 /* Iterate over all used RX queues */
 #define efx_for_each_rx_queue(_rx_queue, _efx)				\
 	for (_rx_queue =3D &_efx->rx_queue[0];				\
-	     _rx_queue < &_efx->rx_queue[EFX_MAX_RX_QUEUES];		\
-	     _rx_queue++)						\
-		if (!_rx_queue->used)					\
-			continue;					\
-		else
+	     _rx_queue < &_efx->rx_queue[_efx->n_rx_queues];		\
+	     _rx_queue++)
=20
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
-	for (_rx_queue =3D &_channel->efx->rx_queue[0];			\
-	     _rx_queue < &_channel->efx->rx_queue[EFX_MAX_RX_QUEUES];	\
-	     _rx_queue++)						\
-		if ((!_rx_queue->used) ||				\
-		    (_rx_queue->channel !=3D _channel))			\
+	for (_rx_queue =3D &_channel->efx->rx_queue[_channel->channel];	\
+	     _rx_queue;							\
+	     _rx_queue =3D NULL)						\
+		if (_rx_queue->channel !=3D _channel)			\
 			continue;					\
 		else
=20
@@ -886,13 +890,13 @@ static inline struct efx_rx_buffer *efx_rx_buffer=
(struct efx_rx_queue *rx_queue,
 }
=20
 /* Set bit in a little-endian bitfield */
-static inline void set_bit_le(int nr, unsigned char *addr)
+static inline void set_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] |=3D (1 << (nr % 8));
 }
=20
 /* Clear bit in a little-endian bitfield */
-static inline void clear_bit_le(int nr, unsigned char *addr)
+static inline void clear_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] &=3D ~(1 << (nr % 8));
 }
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 9d02c84..f746536 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -15,15 +15,7 @@
  */
 extern struct efx_phy_operations falcon_tenxpress_phy_ops;
=20
-enum tenxpress_state {
-	TENXPRESS_STATUS_OFF =3D 0,
-	TENXPRESS_STATUS_OTEMP =3D 1,
-	TENXPRESS_STATUS_NORMAL =3D 2,
-};
-
-extern void tenxpress_set_state(struct efx_nic *efx,
-				enum tenxpress_state state);
-extern void tenxpress_phy_blink(struct efx_nic *efx, int blink);
+extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern void tenxpress_crc_err(struct efx_nic *efx);
=20
 /*********************************************************************=
*******
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 0d27dd3..0f805da 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -212,8 +212,8 @@ void efx_lro_fini(struct net_lro_mgr *lro_mgr)
  * and populates a struct efx_rx_buffer with the relevant
  * information.  Return a negative error code or 0 on success.
  */
-static inline int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue=
,
-					 struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
+				  struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
 	struct net_device *net_dev =3D efx->net_dev;
@@ -252,8 +252,8 @@ static inline int efx_init_rx_buffer_skb(struct efx=
_rx_queue *rx_queue,
  * and populates a struct efx_rx_buffer with the relevant
  * information.  Return a negative error code or 0 on success.
  */
-static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queu=
e,
-					  struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
+				   struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
 	int bytes, space, offset;
@@ -319,8 +319,8 @@ static inline int efx_init_rx_buffer_page(struct ef=
x_rx_queue *rx_queue,
  * and populates a struct efx_rx_buffer with the relevant
  * information.
  */
-static inline int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
-				     struct efx_rx_buffer *new_rx_buf)
+static int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
+			      struct efx_rx_buffer *new_rx_buf)
 {
 	int rc =3D 0;
=20
@@ -340,8 +340,8 @@ static inline int efx_init_rx_buffer(struct efx_rx_=
queue *rx_queue,
 	return rc;
 }
=20
-static inline void efx_unmap_rx_buffer(struct efx_nic *efx,
-				       struct efx_rx_buffer *rx_buf)
+static void efx_unmap_rx_buffer(struct efx_nic *efx,
+				struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
@@ -357,8 +357,8 @@ static inline void efx_unmap_rx_buffer(struct efx_n=
ic *efx,
 	}
 }
=20
-static inline void efx_free_rx_buffer(struct efx_nic *efx,
-				      struct efx_rx_buffer *rx_buf)
+static void efx_free_rx_buffer(struct efx_nic *efx,
+			       struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
 		__free_pages(rx_buf->page, efx->rx_buffer_order);
@@ -369,8 +369,8 @@ static inline void efx_free_rx_buffer(struct efx_ni=
c *efx,
 	}
 }
=20
-static inline void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
-				      struct efx_rx_buffer *rx_buf)
+static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
+			       struct efx_rx_buffer *rx_buf)
 {
 	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
@@ -506,10 +506,10 @@ void efx_rx_work(struct work_struct *data)
 		efx_schedule_slow_fill(rx_queue, 1);
 }
=20
-static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_qu=
eue,
-					    struct efx_rx_buffer *rx_buf,
-					    int len, int *discard,
-					    int *leak_packet)
+static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
+				     struct efx_rx_buffer *rx_buf,
+				     int len, bool *discard,
+				     bool *leak_packet)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
 	unsigned max_len =3D rx_buf->len - efx->type->rx_buffer_padding;
@@ -520,7 +520,7 @@ static inline void efx_rx_packet__check_len(struct =
efx_rx_queue *rx_queue,
 	/* The packet must be discarded, but this is only a fatal error
 	 * if the caller indicated it was
 	 */
-	*discard =3D 1;
+	*discard =3D true;
=20
 	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
 		EFX_ERR_RL(efx, " RX queue %d seriously overlength "
@@ -546,8 +546,8 @@ static inline void efx_rx_packet__check_len(struct =
efx_rx_queue *rx_queue,
  * Handles driverlink veto, and passes the fragment up via
  * the appropriate LRO method
  */
-static inline void efx_rx_packet_lro(struct efx_channel *channel,
-				     struct efx_rx_buffer *rx_buf)
+static void efx_rx_packet_lro(struct efx_channel *channel,
+			      struct efx_rx_buffer *rx_buf)
 {
 	struct net_lro_mgr *lro_mgr =3D &channel->lro_mgr;
 	void *priv =3D channel;
@@ -574,9 +574,9 @@ static inline void efx_rx_packet_lro(struct efx_cha=
nnel *channel,
 }
=20
 /* Allocate and construct an SKB around a struct page.*/
-static inline struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_b=
uf,
-					    struct efx_nic *efx,
-					    int hdr_len)
+static struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
+				     struct efx_nic *efx,
+				     int hdr_len)
 {
 	struct sk_buff *skb;
=20
@@ -621,11 +621,11 @@ static inline struct sk_buff *efx_rx_mk_skb(struc=
t efx_rx_buffer *rx_buf,
 }
=20
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
-		   unsigned int len, int checksummed, int discard)
+		   unsigned int len, bool checksummed, bool discard)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
-	int leak_packet =3D 0;
+	bool leak_packet =3D false;
=20
 	rx_buf =3D efx_rx_buffer(rx_queue, index);
 	EFX_BUG_ON_PARANOID(!rx_buf->data);
@@ -683,11 +683,11 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue,=
 unsigned int index,
=20
 /* Handle a received packet.  Second half: Touches packet payload. */
 void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, int checksummed)
+		     struct efx_rx_buffer *rx_buf, bool checksummed)
 {
 	struct efx_nic *efx =3D channel->efx;
 	struct sk_buff *skb;
-	int lro =3D efx->net_dev->features & NETIF_F_LRO;
+	bool lro =3D !!(efx->net_dev->features & NETIF_F_LRO);
=20
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
@@ -789,27 +789,18 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_qu=
eue)
 	/* Allocate RX buffers */
 	rxq_size =3D (efx->type->rxd_ring_mask + 1) * sizeof(*rx_queue->buffe=
r);
 	rx_queue->buffer =3D kzalloc(rxq_size, GFP_KERNEL);
-	if (!rx_queue->buffer) {
-		rc =3D -ENOMEM;
-		goto fail1;
-	}
+	if (!rx_queue->buffer)
+		return -ENOMEM;
=20
 	rc =3D falcon_probe_rx(rx_queue);
-	if (rc)
-		goto fail2;
-
-	return 0;
-
- fail2:
-	kfree(rx_queue->buffer);
-	rx_queue->buffer =3D NULL;
- fail1:
-	rx_queue->used =3D 0;
-
+	if (rc) {
+		kfree(rx_queue->buffer);
+		rx_queue->buffer =3D NULL;
+	}
 	return rc;
 }
=20
-int efx_init_rx_queue(struct efx_rx_queue *rx_queue)
+void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx =3D rx_queue->efx;
 	unsigned int max_fill, trigger, limit;
@@ -833,7 +824,7 @@ int efx_init_rx_queue(struct efx_rx_queue *rx_queue=
)
 	rx_queue->fast_fill_limit =3D limit;
=20
 	/* Set up RX descriptor ring */
-	return falcon_init_rx(rx_queue);
+	falcon_init_rx(rx_queue);
 }
=20
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
@@ -872,7 +863,6 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_qu=
eue)
=20
 	kfree(rx_queue->buffer);
 	rx_queue->buffer =3D NULL;
-	rx_queue->used =3D 0;
 }
=20
 void efx_flush_lro(struct efx_channel *channel)
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
index f35e377..0e88a9d 100644
--- a/drivers/net/sfc/rx.h
+++ b/drivers/net/sfc/rx.h
@@ -14,7 +14,7 @@
=20
 int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
-int efx_init_rx_queue(struct efx_rx_queue *rx_queue);
+void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
=20
 int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx);
@@ -24,6 +24,6 @@ void efx_rx_strategy(struct efx_channel *channel);
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
 void efx_rx_work(struct work_struct *data);
 void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, int checksummed);
+		     struct efx_rx_buffer *rx_buf, bool checksummed);
=20
 #endif /* EFX_RX_H */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 3b2de9f..362956e 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -27,6 +27,9 @@
 #include "boards.h"
 #include "workarounds.h"
 #include "mac.h"
+#include "spi.h"
+#include "falcon_io.h"
+#include "mdio_10g.h"
=20
 /*
  * Loopback test packet structure
@@ -51,7 +54,7 @@ static const char *payload_msg =3D
 	"Hello world! This is an Efx loopback test in progress!";
=20
 /**
- * efx_selftest_state - persistent state during a selftest
+ * efx_loopback_state - persistent state during a loopback selftest
  * @flush:		Drop all packets in efx_loopback_rx_packet
  * @packet_count:	Number of packets being used in this test
  * @skbs:		An array of skbs transmitted
@@ -59,10 +62,14 @@ static const char *payload_msg =3D
  * @rx_bad:		RX bad packet count
  * @payload:		Payload used in tests
  */
-struct efx_selftest_state {
-	int flush;
+struct efx_loopback_state {
+	bool flush;
 	int packet_count;
 	struct sk_buff **skbs;
+
+	/* Checksums are being offloaded */
+	bool offload_csum;
+
 	atomic_t rx_good;
 	atomic_t rx_bad;
 	struct efx_loopback_payload payload;
@@ -70,21 +77,65 @@ struct efx_selftest_state {
=20
 /*********************************************************************=
*****
  *
- * Configurable values
+ * MII, NVRAM and register tests
  *
  *********************************************************************=
*****/
=20
-/* Level of loopback testing
- *
- * The maximum packet burst length is 16**(n-1), i.e.
- *
- * - Level 0 : no packets
- * - Level 1 : 1 packet
- * - Level 2 : 17 packets (1 * 1 packet, 1 * 16 packets)
- * - Level 3 : 273 packets (1 * 1 packet, 1 * 16 packet, 1 * 256 packe=
ts)
- *
- */
-static unsigned int loopback_test_level =3D 3;
+static int efx_test_mii(struct efx_nic *efx, struct efx_self_tests *te=
sts)
+{
+	int rc =3D 0;
+	u16 physid1, physid2;
+	struct mii_if_info *mii =3D &efx->mii;
+	struct net_device *net_dev =3D efx->net_dev;
+
+	if (efx->phy_type =3D=3D PHY_TYPE_NONE)
+		return 0;
+
+	mutex_lock(&efx->mac_lock);
+	tests->mii =3D -1;
+
+	physid1 =3D mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
+	physid2 =3D mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+
+	if ((physid1 =3D=3D 0x0000) || (physid1 =3D=3D 0xffff) ||
+	    (physid2 =3D=3D 0x0000) || (physid2 =3D=3D 0xffff)) {
+		EFX_ERR(efx, "no MII PHY present with ID %d\n",
+			mii->phy_id);
+		rc =3D -EINVAL;
+		goto out;
+	}
+
+	rc =3D mdio_clause45_check_mmds(efx, efx->phy_op->mmds, 0);
+	if (rc)
+		goto out;
+
+out:
+	mutex_unlock(&efx->mac_lock);
+	tests->mii =3D rc ? -1 : 1;
+	return rc;
+}
+
+static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *=
tests)
+{
+	int rc;
+
+	rc =3D falcon_read_nvram(efx, NULL);
+	tests->nvram =3D rc ? -1 : 1;
+	return rc;
+}
+
+static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *t=
ests)
+{
+	int rc;
+
+	/* Not supported on A-series silicon */
+	if (falcon_rev(efx) < FALCON_REV_B0)
+		return 0;
+
+	rc =3D falcon_test_registers(efx);
+	tests->registers =3D rc ? -1 : 1;
+	return rc;
+}
=20
 /*********************************************************************=
*****
  *
@@ -107,7 +158,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
=20
 	/* ACK each interrupting event queue. Receiving an interrupt due to
 	 * traffic before a test event is raised is considered a pass */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->work_pending)
 			efx_process_channel_now(channel);
 		if (efx->last_irq_cpu >=3D 0)
@@ -132,41 +183,6 @@ static int efx_test_interrupts(struct efx_nic *efx=
,
 	return 0;
 }
=20
-/* Test generation and receipt of non-interrupting events */
-static int efx_test_eventq(struct efx_channel *channel,
-			   struct efx_self_tests *tests)
-{
-	unsigned int magic;
-
-	/* Channel specific code, limited to 20 bits */
-	magic =3D (0x00010150 + channel->channel);
-	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n"=
,
-		channel->channel, magic);
-
-	tests->eventq_dma[channel->channel] =3D -1;
-	tests->eventq_int[channel->channel] =3D 1;	/* fake pass */
-	tests->eventq_poll[channel->channel] =3D 1;	/* fake pass */
-
-	/* Reset flag and zero magic word */
-	channel->efx->last_irq_cpu =3D -1;
-	channel->eventq_magic =3D 0;
-	smp_wmb();
-
-	falcon_generate_test_event(channel, magic);
-	udelay(1);
-
-	efx_process_channel_now(channel);
-	if (channel->eventq_magic !=3D magic) {
-		EFX_ERR(channel->efx, "channel %d  failed to see test event\n",
-			channel->channel);
-		return -ETIMEDOUT;
-	} else {
-		tests->eventq_dma[channel->channel] =3D 1;
-	}
-
-	return 0;
-}
-
 /* Test generation and receipt of interrupting events */
 static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
@@ -230,39 +246,18 @@ static int efx_test_eventq_irq(struct efx_channel=
 *channel,
 	return 0;
 }
=20
-/*********************************************************************=
*****
- *
- * PHY testing
- *
- *********************************************************************=
*****/
-
-/* Check PHY presence by reading the PHY ID registers */
-static int efx_test_phy(struct efx_nic *efx,
-			struct efx_self_tests *tests)
+static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *te=
sts)
 {
-	u16 physid1, physid2;
-	struct mii_if_info *mii =3D &efx->mii;
-	struct net_device *net_dev =3D efx->net_dev;
+	int rc;
=20
-	if (efx->phy_type =3D=3D PHY_TYPE_NONE)
+	if (!efx->phy_op->test)
 		return 0;
=20
-	EFX_LOG(efx, "testing PHY presence\n");
-	tests->phy_ok =3D -1;
-
-	physid1 =3D mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
-	physid2 =3D mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
-
-	if ((physid1 !=3D 0x0000) && (physid1 !=3D 0xffff) &&
-	    (physid2 !=3D 0x0000) && (physid2 !=3D 0xffff)) {
-		EFX_LOG(efx, "found MII PHY %d ID 0x%x:%x\n",
-			mii->phy_id, physid1, physid2);
-		tests->phy_ok =3D 1;
-		return 0;
-	}
-
-	EFX_ERR(efx, "no MII PHY present with ID %d\n", mii->phy_id);
-	return -ENODEV;
+	mutex_lock(&efx->mac_lock);
+	rc =3D efx->phy_op->test(efx);
+	mutex_unlock(&efx->mac_lock);
+	tests->phy =3D rc ? -1 : 1;
+	return rc;
 }
=20
 /*********************************************************************=
*****
@@ -278,7 +273,7 @@ static int efx_test_phy(struct efx_nic *efx,
 void efx_loopback_rx_packet(struct efx_nic *efx,
 			    const char *buf_ptr, int pkt_len)
 {
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
 	struct efx_loopback_payload *received;
 	struct efx_loopback_payload *payload;
=20
@@ -289,11 +284,12 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 		return;
=20
 	payload =3D &state->payload;
-=09
+
 	received =3D (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr =3D payload->ip.saddr;
-	received->ip.check =3D payload->ip.check;
-=09
+	if (state->offload_csum)
+		received->ip.check =3D payload->ip.check;
+
 	/* Check that header exists */
 	if (pkt_len < sizeof(received->header)) {
 		EFX_ERR(efx, "saw runt RX packet (length %d) in %s loopback "
@@ -362,7 +358,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 /* Initialise an efx_selftest_state for a new iteration */
 static void efx_iterate_state(struct efx_nic *efx)
 {
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
 	struct net_device *net_dev =3D efx->net_dev;
 	struct efx_loopback_payload *payload =3D &state->payload;
=20
@@ -395,17 +391,17 @@ static void efx_iterate_state(struct efx_nic *efx=
)
 	smp_wmb();
 }
=20
-static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
+static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx =3D tx_queue->efx;
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
 	struct efx_loopback_payload *payload;
 	struct sk_buff *skb;
 	int i, rc;
=20
 	/* Transmit N copies of buffer */
 	for (i =3D 0; i < state->packet_count; i++) {
-		/* Allocate an skb, holding an extra reference for=20
+		/* Allocate an skb, holding an extra reference for
 		 * transmit completion counting */
 		skb =3D alloc_skb(sizeof(state->payload), GFP_KERNEL);
 		if (!skb)
@@ -444,11 +440,25 @@ static int efx_tx_loopback(struct efx_tx_queue *t=
x_queue)
 	return 0;
 }
=20
-static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
-			   struct efx_loopback_self_tests *lb_tests)
+static int efx_poll_loopback(struct efx_nic *efx)
+{
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
+	struct efx_channel *channel;
+
+	/* NAPI polling is not enabled, so process channels
+	 * synchronously */
+	efx_for_each_channel(channel, efx) {
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+	}
+	return atomic_read(&state->rx_good) =3D=3D state->packet_count;
+}
+
+static int efx_end_loopback(struct efx_tx_queue *tx_queue,
+			    struct efx_loopback_self_tests *lb_tests)
 {
 	struct efx_nic *efx =3D tx_queue->efx;
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
 	struct sk_buff *skb;
 	int tx_done =3D 0, rx_good, rx_bad;
 	int i, rc =3D 0;
@@ -507,11 +517,10 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		  struct efx_loopback_self_tests *lb_tests)
 {
 	struct efx_nic *efx =3D tx_queue->efx;
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
-	struct efx_channel *channel;
-	int i, rc =3D 0;
+	struct efx_loopback_state *state =3D efx->loopback_selftest;
+	int i, begin_rc, end_rc;
=20
-	for (i =3D 0; i < loopback_test_level; i++) {
+	for (i =3D 0; i < 3; i++) {
 		/* Determine how many packets to send */
 		state->packet_count =3D (efx->type->txd_ring_mask + 1) / 3;
 		state->packet_count =3D min(1 << (i << 2), state->packet_count);
@@ -519,30 +528,31 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 				      state->packet_count, GFP_KERNEL);
 		if (!state->skbs)
 			return -ENOMEM;
-		state->flush =3D 0;
+		state->flush =3D false;
=20
 		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
 			"packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
 			state->packet_count);
=20
 		efx_iterate_state(efx);
-		rc =3D efx_tx_loopback(tx_queue);
-	=09
-		/* NAPI polling is not enabled, so process channels synchronously */
-		schedule_timeout_uninterruptible(HZ / 50);
-		efx_for_each_channel_with_interrupt(channel, efx) {
-			if (channel->work_pending)
-				efx_process_channel_now(channel);
+		begin_rc =3D efx_begin_loopback(tx_queue);
+
+		/* This will normally complete very quickly, but be
+		 * prepared to wait up to 100 ms. */
+		msleep(1);
+		if (!efx_poll_loopback(efx)) {
+			msleep(100);
+			efx_poll_loopback(efx);
 		}
=20
-		rc |=3D efx_rx_loopback(tx_queue, lb_tests);
+		end_rc =3D efx_end_loopback(tx_queue, lb_tests);
 		kfree(state->skbs);
=20
-		if (rc) {
+		if (begin_rc || end_rc) {
 			/* Wait a while to ensure there are no packets
 			 * floating around after a failure. */
 			schedule_timeout_uninterruptible(HZ / 10);
-			return rc;
+			return begin_rc ? begin_rc : end_rc;
 		}
 	}
=20
@@ -550,49 +560,36 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		"of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
 		state->packet_count);
=20
-	return rc;
+	return 0;
 }
=20
-static int efx_test_loopbacks(struct efx_nic *efx,
+static int efx_test_loopbacks(struct efx_nic *efx, struct ethtool_cmd =
ecmd,
 			      struct efx_self_tests *tests,
 			      unsigned int loopback_modes)
 {
-	struct efx_selftest_state *state =3D efx->loopback_selftest;
-	struct ethtool_cmd ecmd, ecmd_loopback;
+	enum efx_loopback_mode mode;
+	struct efx_loopback_state *state;
 	struct efx_tx_queue *tx_queue;
-	enum efx_loopback_mode old_mode, mode;
-	int count, rc =3D 0, link_up;
-=09
-	rc =3D efx_ethtool_get_settings(efx->net_dev, &ecmd);
-	if (rc) {
-		EFX_ERR(efx, "could not get GMII settings\n");
-		return rc;
-	}
-	old_mode =3D efx->loopback_mode;
-
-	/* Disable autonegotiation for the purposes of loopback */
-	memcpy(&ecmd_loopback, &ecmd, sizeof(ecmd_loopback));
-	if (ecmd_loopback.autoneg =3D=3D AUTONEG_ENABLE) {
-		ecmd_loopback.autoneg =3D AUTONEG_DISABLE;
-		ecmd_loopback.duplex =3D DUPLEX_FULL;
-		ecmd_loopback.speed =3D SPEED_10000;
-	}
+	bool link_up;
+	int count, rc =3D 0;
=20
-	rc =3D efx_ethtool_set_settings(efx->net_dev, &ecmd_loopback);
-	if (rc) {
-		EFX_ERR(efx, "could not disable autonegotiation\n");
-		goto out;
-	}
-	tests->loopback_speed =3D ecmd_loopback.speed;
-	tests->loopback_full_duplex =3D ecmd_loopback.duplex;
+	/* Set the port loopback_selftest member. From this point on
+	 * all received packets will be dropped. Mark the state as
+	 * "flushing" so all inflight packets are dropped */
+	state =3D kzalloc(sizeof(*state), GFP_KERNEL);
+	if (state =3D=3D NULL)
+		return -ENOMEM;
+	BUG_ON(efx->loopback_selftest);
+	state->flush =3D true;
+	efx->loopback_selftest =3D state;
=20
 	/* Test all supported loopback modes */
-	for (mode =3D LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+	for (mode =3D LOOPBACK_NONE; mode <=3D LOOPBACK_TEST_MAX; mode++) {
 		if (!(loopback_modes & (1 << mode)))
 			continue;
=20
 		/* Move the port into the specified loopback mode. */
-		state->flush =3D 1;
+		state->flush =3D true;
 		efx->loopback_mode =3D mode;
 		efx_reconfigure_port(efx);
=20
@@ -616,7 +613,7 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 			 */
 			link_up =3D efx->link_up;
 			if (!falcon_xaui_link_ok(efx))
-				link_up =3D 0;
+				link_up =3D false;
=20
 		} while ((++count < 20) && !link_up);
=20
@@ -634,18 +631,21 @@ static int efx_test_loopbacks(struct efx_nic *efx=
,
=20
 		/* Test every TX queue */
 		efx_for_each_tx_queue(tx_queue, efx) {
-			rc |=3D efx_test_loopback(tx_queue,
-						&tests->loopback[mode]);
+			state->offload_csum =3D (tx_queue->queue =3D=3D
+					       EFX_TX_QUEUE_OFFLOAD_CSUM);
+			rc =3D efx_test_loopback(tx_queue,
+					       &tests->loopback[mode]);
 			if (rc)
 				goto out;
 		}
 	}
=20
  out:
-	/* Take out of loopback and restore PHY settings */
-	state->flush =3D 1;
-	efx->loopback_mode =3D old_mode;
-	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+	/* Remove the flush. The caller will remove the loopback setting */
+	state->flush =3D true;
+	efx->loopback_selftest =3D NULL;
+	wmb();
+	kfree(state);
=20
 	return rc;
 }
@@ -661,23 +661,27 @@ static int efx_test_loopbacks(struct efx_nic *efx=
,
 int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	struct efx_channel *channel;
-	int rc =3D 0;
+	int rc, rc2 =3D 0;
+
+	rc =3D efx_test_mii(efx, tests);
+	if (rc && !rc2)
+		rc2 =3D rc;
=20
-	EFX_LOG(efx, "performing online self-tests\n");
+	rc =3D efx_test_nvram(efx, tests);
+	if (rc && !rc2)
+		rc2 =3D rc;
+
+	rc =3D efx_test_interrupts(efx, tests);
+	if (rc && !rc2)
+		rc2 =3D rc;
=20
-	rc |=3D efx_test_interrupts(efx, tests);
 	efx_for_each_channel(channel, efx) {
-		if (channel->has_interrupt)
-			rc |=3D efx_test_eventq_irq(channel, tests);
-		else
-			rc |=3D efx_test_eventq(channel, tests);
+		rc =3D efx_test_eventq_irq(channel, tests);
+		if (rc && !rc2)
+			rc2 =3D rc;
 	}
-	rc |=3D efx_test_phy(efx, tests);
-
-	if (rc)
-		EFX_ERR(efx, "failed online self-tests\n");
=20
-	return rc;
+	return rc2;
 }
=20
 /* Offline (i.e. disruptive) testing
@@ -685,35 +689,66 @@ int efx_online_test(struct efx_nic *efx, struct e=
fx_self_tests *tests)
 int efx_offline_test(struct efx_nic *efx,
 		     struct efx_self_tests *tests, unsigned int loopback_modes)
 {
-	struct efx_selftest_state *state;
-	int rc =3D 0;
-
-	EFX_LOG(efx, "performing offline self-tests\n");
+	enum efx_loopback_mode loopback_mode =3D efx->loopback_mode;
+	int phy_mode =3D efx->phy_mode;
+	struct ethtool_cmd ecmd, ecmd_test;
+	int rc, rc2 =3D 0;
+
+	/* force the carrier state off so the kernel doesn't transmit during
+	 * the loopback test, and the watchdog timeout doesn't fire. Also put
+	 * falcon into loopback for the register test.
+	 */
+	mutex_lock(&efx->mac_lock);
+	efx->port_inhibited =3D true;
+	if (efx->loopback_modes)
+		efx->loopback_mode =3D __ffs(efx->loopback_modes);
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	/* free up all consumers of SRAM (including all the queues) */
+	efx_reset_down(efx, &ecmd);
+
+	rc =3D efx_test_chip(efx, tests);
+	if (rc && !rc2)
+		rc2 =3D rc;
+
+	/* reset the chip to recover from the register test */
+	rc =3D falcon_reset_hw(efx, RESET_TYPE_ALL);
+
+	/* Modify the saved ecmd so that when efx_reset_up() restores the phy
+	 * state, AN is disabled, and the phy is powered, and out of loopback=
 */
+	memcpy(&ecmd_test, &ecmd, sizeof(ecmd_test));
+	if (ecmd_test.autoneg =3D=3D AUTONEG_ENABLE) {
+		ecmd_test.autoneg =3D AUTONEG_DISABLE;
+		ecmd_test.duplex =3D DUPLEX_FULL;
+		ecmd_test.speed =3D SPEED_10000;
+	}
+	efx->loopback_mode =3D LOOPBACK_NONE;
=20
-	/* Create a selftest_state structure to hold state for the test */
-	state =3D kzalloc(sizeof(*state), GFP_KERNEL);
-	if (state =3D=3D NULL) {
-		rc =3D -ENOMEM;
-		goto out;
+	rc =3D efx_reset_up(efx, &ecmd_test, rc =3D=3D 0);
+	if (rc) {
+		EFX_ERR(efx, "Unable to recover from chip test\n");
+		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+		return rc;
 	}
=20
-	/* Set the port loopback_selftest member. From this point on
-	 * all received packets will be dropped. Mark the state as
-	 * "flushing" so all inflight packets are dropped */
-	BUG_ON(efx->loopback_selftest);
-	state->flush =3D 1;
-	efx->loopback_selftest =3D state;
+	tests->loopback_speed =3D ecmd_test.speed;
+	tests->loopback_full_duplex =3D ecmd_test.duplex;
=20
-	rc =3D efx_test_loopbacks(efx, tests, loopback_modes);
+	rc =3D efx_test_phy(efx, tests);
+	if (rc && !rc2)
+		rc2 =3D rc;
=20
-	efx->loopback_selftest =3D NULL;
-	wmb();
-	kfree(state);
+	rc =3D efx_test_loopbacks(efx, ecmd_test, tests, loopback_modes);
+	if (rc && !rc2)
+		rc2 =3D rc;
=20
- out:
-	if (rc)
-		EFX_ERR(efx, "failed offline self-tests\n");
+	/* restore the PHY to the previous state */
+	efx->loopback_mode =3D loopback_mode;
+	efx->phy_mode =3D phy_mode;
+	efx->port_inhibited =3D false;
+	efx_ethtool_set_settings(efx->net_dev, &ecmd);
=20
-	return rc;
+	return rc2;
 }
=20
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index f6999c2..fc15df1 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -18,8 +18,8 @@
  */
=20
 struct efx_loopback_self_tests {
-	int tx_sent[EFX_MAX_TX_QUEUES];
-	int tx_done[EFX_MAX_TX_QUEUES];
+	int tx_sent[EFX_TX_QUEUE_COUNT];
+	int tx_done[EFX_TX_QUEUE_COUNT];
 	int rx_good;
 	int rx_bad;
 };
@@ -29,14 +29,19 @@ struct efx_loopback_self_tests {
  * indicates failure.
  */
 struct efx_self_tests {
+	/* online tests */
+	int mii;
+	int nvram;
 	int interrupt;
 	int eventq_dma[EFX_MAX_CHANNELS];
 	int eventq_int[EFX_MAX_CHANNELS];
 	int eventq_poll[EFX_MAX_CHANNELS];
-	int phy_ok;
+	/* offline tests */
+	int registers;
+	int phy;
 	int loopback_speed;
 	int loopback_full_duplex;
-	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX];
+	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
 };
=20
 extern void efx_loopback_rx_packet(struct efx_nic *efx,
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index b278495..b7005da 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -13,11 +13,13 @@
  * the PHY
  */
 #include <linux/delay.h>
+#include "net_driver.h"
 #include "efx.h"
 #include "phy.h"
 #include "boards.h"
 #include "falcon.h"
 #include "falcon_hwdefs.h"
+#include "falcon_io.h"
 #include "mac.h"
=20
 /*********************************************************************=
*****
@@ -120,111 +122,63 @@ static void sfe4001_poweroff(struct efx_nic *efx=
)
 	i2c_smbus_read_byte_data(hwmon_client, RSL);
 }
=20
-static void sfe4001_fini(struct efx_nic *efx)
-{
-	EFX_INFO(efx, "%s\n", __func__);
-
-	sfe4001_poweroff(efx);
- 	i2c_unregister_device(efx->board_info.ioexp_client);
- 	i2c_unregister_device(efx->board_info.hwmon_client);
-}
-
-/* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
- * to the FLASH_CFG_1 input on the DSP.  We must keep it high at power=
-
- * up to allow writing the flash (done through MDIO from userland).
- */
-unsigned int sfe4001_phy_flash_cfg;
-module_param_named(phy_flash_cfg, sfe4001_phy_flash_cfg, uint, 0444);
-MODULE_PARM_DESC(phy_flash_cfg,
-		 "Force PHY to enter flash configuration mode");
-
-/* This board uses an I2C expander to provider power to the PHY, which=
 needs to
- * be turned on before the PHY can be used.
- * Context: Process context, rtnl lock held
- */
-int sfe4001_init(struct efx_nic *efx)
+static int sfe4001_poweron(struct efx_nic *efx)
 {
-	struct i2c_client *hwmon_client, *ioexp_client;
-	unsigned int count;
+	struct i2c_client *hwmon_client =3D efx->board_info.hwmon_client;
+	struct i2c_client *ioexp_client =3D efx->board_info.ioexp_client;
+	unsigned int i, j;
 	int rc;
 	u8 out;
-	efx_dword_t reg;
-
-	hwmon_client =3D i2c_new_dummy(&efx->i2c_adap, MAX6647);
-	if (!hwmon_client)
-		return -EIO;
-	efx->board_info.hwmon_client =3D hwmon_client;
-
-	ioexp_client =3D i2c_new_dummy(&efx->i2c_adap, PCA9539);
-	if (!ioexp_client) {
-		rc =3D -EIO;
-		goto fail_hwmon;
-	}
-	efx->board_info.ioexp_client =3D ioexp_client;
-
-	/* 10Xpress has fixed-function LED pins, so there is no board-specifi=
c
-	 * blink code. */
-	efx->board_info.blink =3D tenxpress_phy_blink;
+	efx_oword_t reg;
=20
 	/* Ensure that XGXS and XAUI SerDes are held in reset */
-	EFX_POPULATE_DWORD_7(reg, XX_PWRDNA_EN, 1,
+	EFX_POPULATE_OWORD_7(reg, XX_PWRDNA_EN, 1,
 			     XX_PWRDNB_EN, 1,
 			     XX_RSTPLLAB_EN, 1,
 			     XX_RESETA_EN, 1,
 			     XX_RESETB_EN, 1,
 			     XX_RSTXGXSRX_EN, 1,
 			     XX_RSTXGXSTX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
=20
-	efx->board_info.fini =3D sfe4001_fini;
-
-	/* Set DSP over-temperature alert threshold */
-	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
-	rc =3D i2c_smbus_write_byte_data(hwmon_client, WLHO,
-				       xgphy_max_temperature);
-	if (rc)
-		goto fail_ioexp;
-
-	/* Read it back and verify */
-	rc =3D i2c_smbus_read_byte_data(hwmon_client, RLHN);
-	if (rc < 0)
-		goto fail_ioexp;
-	if (rc !=3D xgphy_max_temperature) {
-		rc =3D -EFAULT;
-		goto fail_ioexp;
-	}
-
 	/* Clear any previous over-temperature alert */
 	rc =3D i2c_smbus_read_byte_data(hwmon_client, RSL);
 	if (rc < 0)
-		goto fail_ioexp;
+		return rc;
=20
 	/* Enable port 0 and port 1 outputs on IO expander */
 	rc =3D i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0x00);
 	if (rc)
-		goto fail_ioexp;
+		return rc;
 	rc =3D i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG,
 				       0xff & ~(1 << P1_SPARE_LBN));
 	if (rc)
 		goto fail_on;
=20
-	/* Turn all power off then wait 1 sec. This ensures PHY is reset */
+	/* If PHY power is on, turn it all off and wait 1 second to
+	 * ensure a full reset.
+	 */
+	rc =3D i2c_smbus_read_byte_data(ioexp_client, P0_OUT);
+	if (rc < 0)
+		goto fail_on;
 	out =3D 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
 		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
 		       (0 << P0_EN_1V0X_LBN));
-	rc =3D i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
-	if (rc)
-		goto fail_on;
+	if (rc !=3D out) {
+		EFX_INFO(efx, "power-cycling PHY\n");
+		rc =3D i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
+		if (rc)
+			goto fail_on;
+		schedule_timeout_uninterruptible(HZ);
+	}
=20
-	schedule_timeout_uninterruptible(HZ);
-	count =3D 0;
-	do {
+	for (i =3D 0; i < 20; ++i) {
 		/* Turn on 1.2V, 2.5V, 3.3V and 5V power rails */
 		out =3D 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
 			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
 			       (1 << P0_X_TRST_LBN));
-		if (sfe4001_phy_flash_cfg)
+		if (efx->phy_mode & PHY_MODE_SPECIAL)
 			out |=3D 1 << P0_EN_3V3X_LBN;
=20
 		rc =3D i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
@@ -238,35 +192,145 @@ int sfe4001_init(struct efx_nic *efx)
 		if (rc)
 			goto fail_on;
=20
-		EFX_INFO(efx, "waiting for power (attempt %d)...\n", count);
+		EFX_INFO(efx, "waiting for DSP boot (attempt %d)...\n", i);
+
+		/* In flash config mode, DSP does not turn on AFE, so
+		 * just wait 1 second.
+		 */
+		if (efx->phy_mode & PHY_MODE_SPECIAL) {
+			schedule_timeout_uninterruptible(HZ);
+			return 0;
+		}
+
+		for (j =3D 0; j < 10; ++j) {
+			msleep(100);
+
+			/* Check DSP has asserted AFE power line */
+			rc =3D i2c_smbus_read_byte_data(ioexp_client, P1_IN);
+			if (rc < 0)
+				goto fail_on;
+			if (rc & (1 << P1_AFE_PWD_LBN))
+				return 0;
+		}
+	}
=20
-		schedule_timeout_uninterruptible(HZ);
+	EFX_INFO(efx, "timed out waiting for DSP boot\n");
+	rc =3D -ETIMEDOUT;
+fail_on:
+	sfe4001_poweroff(efx);
+	return rc;
+}
=20
-		/* Check DSP is powered */
-		rc =3D i2c_smbus_read_byte_data(ioexp_client, P1_IN);
-		if (rc < 0)
-			goto fail_on;
-		if (rc & (1 << P1_AFE_PWD_LBN))
-			goto done;
+/* On SFE4001 rev A2 and later, we can control the FLASH_CFG_1 pin
+ * using the 3V3X output of the IO-expander.  Allow the user to set
+ * this when the device is stopped, and keep it stopped then.
+ */
=20
-		/* DSP doesn't look powered in flash config mode */
-		if (sfe4001_phy_flash_cfg)
-			goto done;
-	} while (++count < 20);
+static ssize_t show_phy_flash_cfg(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct efx_nic *efx =3D pci_get_drvdata(to_pci_dev(dev));
+	return sprintf(buf, "%d\n", !!(efx->phy_mode & PHY_MODE_SPECIAL));
+}
=20
-	EFX_INFO(efx, "timed out waiting for power\n");
-	rc =3D -ETIMEDOUT;
-	goto fail_on;
+static ssize_t set_phy_flash_cfg(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct efx_nic *efx =3D pci_get_drvdata(to_pci_dev(dev));
+	enum efx_phy_mode old_mode, new_mode;
+	int err;
+
+	rtnl_lock();
+	old_mode =3D efx->phy_mode;
+	if (count =3D=3D 0 || *buf =3D=3D '0')
+		new_mode =3D old_mode & ~PHY_MODE_SPECIAL;
+	else
+		new_mode =3D PHY_MODE_SPECIAL;
+	if (old_mode =3D=3D new_mode) {
+		err =3D 0;
+	} else if (efx->state !=3D STATE_RUNNING || netif_running(efx->net_de=
v)) {
+		err =3D -EBUSY;
+	} else {
+		efx->phy_mode =3D new_mode;
+		err =3D sfe4001_poweron(efx);
+		efx_reconfigure_port(efx);
+	}
+	rtnl_unlock();
+
+	return err ? err : count;
+}
+
+static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_fl=
ash_cfg);
+
+static void sfe4001_fini(struct efx_nic *efx)
+{
+	EFX_INFO(efx, "%s\n", __func__);
+
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	sfe4001_poweroff(efx);
+	i2c_unregister_device(efx->board_info.ioexp_client);
+	i2c_unregister_device(efx->board_info.hwmon_client);
+}
+
+/* This board uses an I2C expander to provider power to the PHY, which=
 needs to
+ * be turned on before the PHY can be used.
+ * Context: Process context, rtnl lock held
+ */
+int sfe4001_init(struct efx_nic *efx)
+{
+	struct i2c_client *hwmon_client;
+	int rc;
+
+	hwmon_client =3D i2c_new_dummy(&efx->i2c_adap, MAX6647);
+	if (!hwmon_client)
+		return -EIO;
+	efx->board_info.hwmon_client =3D hwmon_client;
+
+	/* Set DSP over-temperature alert threshold */
+	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
+	rc =3D i2c_smbus_write_byte_data(hwmon_client, WLHO,
+				       xgphy_max_temperature);
+	if (rc)
+		goto fail_ioexp;
+
+	/* Read it back and verify */
+	rc =3D i2c_smbus_read_byte_data(hwmon_client, RLHN);
+	if (rc < 0)
+		goto fail_ioexp;
+	if (rc !=3D xgphy_max_temperature) {
+		rc =3D -EFAULT;
+		goto fail_ioexp;
+	}
+
+	efx->board_info.ioexp_client =3D i2c_new_dummy(&efx->i2c_adap, PCA953=
9);
+	if (!efx->board_info.ioexp_client) {
+		rc =3D -EIO;
+		goto fail_hwmon;
+	}
+
+	/* 10Xpress has fixed-function LED pins, so there is no board-specifi=
c
+	 * blink code. */
+	efx->board_info.blink =3D tenxpress_phy_blink;
+
+	efx->board_info.fini =3D sfe4001_fini;
+
+	rc =3D sfe4001_poweron(efx);
+	if (rc)
+		goto fail_ioexp;
+
+	rc =3D device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg=
);
+	if (rc)
+		goto fail_on;
=20
-done:
 	EFX_INFO(efx, "PHY is powered on\n");
 	return 0;
=20
 fail_on:
 	sfe4001_poweroff(efx);
 fail_ioexp:
- 	i2c_unregister_device(ioexp_client);
+	i2c_unregister_device(efx->board_info.ioexp_client);
 fail_hwmon:
- 	i2c_unregister_device(hwmon_client);
+	i2c_unregister_device(hwmon_client);
 	return rc;
 }
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 34412f3..feef619 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -19,53 +19,48 @@
  *
  *********************************************************************=
****/
=20
-/*
- * Commands common to all known devices.
- *
+#define SPI_WRSR 0x01		/* Write status register */
+#define SPI_WRITE 0x02		/* Write data to memory array */
+#define SPI_READ 0x03		/* Read data from memory array */
+#define SPI_WRDI 0x04		/* Reset write enable latch */
+#define SPI_RDSR 0x05		/* Read status register */
+#define SPI_WREN 0x06		/* Set write enable latch */
+
+#define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
+#define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
+#define SPI_STATUS_BP1 0x08	/* Block protection bit 1 */
+#define SPI_STATUS_BP0 0x04	/* Block protection bit 0 */
+#define SPI_STATUS_WEN 0x02	/* State of the write enable latch */
+#define SPI_STATUS_NRDY 0x01	/* Device busy flag */
+
+/**
+ * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) de=
vice
+ * @efx:		The Efx controller that owns this device
+ * @device_id:		Controller's id for the device
+ * @size:		Size (in bytes)
+ * @addr_len:		Number of address bytes in read/write commands
+ * @munge_address:	Flag whether addresses should be munged.
+ *	Some devices with 9-bit addresses (e.g. AT25040A EEPROM)
+ *	use bit 3 of the command byte as address bit A8, rather
+ *	than having a two-byte address.  If this flag is set, then
+ *	commands should be munged in this way.
+ * @block_size:		Write block size (in bytes).
+ *	Write commands are limited to blocks with this size and alignment.
+ * @read:		Read function for the device
+ * @write:		Write function for the device
  */
-
-/* Write status register */
-#define SPI_WRSR 0x01
-
-/* Write data to memory array */
-#define SPI_WRITE 0x02
-
-/* Read data from memory array */
-#define SPI_READ 0x03
-
-/* Reset write enable latch */
-#define SPI_WRDI 0x04
-
-/* Read status register */
-#define SPI_RDSR 0x05
-
-/* Set write enable latch */
-#define SPI_WREN 0x06
-
-/* SST: Enable write to status register */
-#define SPI_SST_EWSR 0x50
-
-/*
- * Status register bits.  Not all bits are supported on all devices.
- *
- */
-
-/* Write-protect pin enabled */
-#define SPI_STATUS_WPEN 0x80
-
-/* Block protection bit 2 */
-#define SPI_STATUS_BP2 0x10
-
-/* Block protection bit 1 */
-#define SPI_STATUS_BP1 0x08
-
-/* Block protection bit 0 */
-#define SPI_STATUS_BP0 0x04
-
-/* State of the write enable latch */
-#define SPI_STATUS_WEN 0x02
-
-/* Device busy flag */
-#define SPI_STATUS_NRDY 0x01
+struct efx_spi_device {
+	struct efx_nic *efx;
+	int device_id;
+	unsigned int size;
+	unsigned int addr_len;
+	unsigned int munge_address:1;
+	unsigned int block_size;
+};
+
+int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
+		    size_t len, size_t *retlen, u8 *buffer);
+int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
+		     size_t len, size_t *retlen, const u8 *buffer);
=20
 #endif /* EFX_SPI_H */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index c014606..8412dbe 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -65,25 +65,10 @@
 #define PMA_PMD_LED_DEFAULT	(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
=20
=20
-/* Self test (BIST) control register */
-#define PMA_PMD_BIST_CTRL_REG	(0xc014)
-#define PMA_PMD_BIST_BER_LBN	(2)	/* Run BER test */
-#define PMA_PMD_BIST_CONT_LBN	(1)	/* Run continuous BIST until cleared=
 */
-#define PMA_PMD_BIST_SINGLE_LBN	(0)	/* Run 1 BIST iteration (self clea=
rs) */
-/* Self test status register */
-#define PMA_PMD_BIST_STAT_REG	(0xc015)
-#define PMA_PMD_BIST_ENX_LBN	(3)
-#define PMA_PMD_BIST_PMA_LBN	(2)
-#define PMA_PMD_BIST_RXD_LBN	(1)
-#define PMA_PMD_BIST_AFE_LBN	(0)
-
 /* Special Software reset register */
 #define PMA_PMD_EXT_CTRL_REG 49152
 #define PMA_PMD_EXT_SSR_LBN 15
=20
-#define BIST_MAX_DELAY	(1000)
-#define BIST_POLL_DELAY	(10)
-
 /* Misc register defines */
 #define PCS_CLOCK_CTRL_REG 0xd801
 #define PLL312_RST_N_LBN 2
@@ -119,27 +104,12 @@ MODULE_PARM_DESC(crc_error_reset_threshold,
 		 "Max number of CRC errors before XAUI reset");
=20
 struct tenxpress_phy_data {
-	enum tenxpress_state state;
 	enum efx_loopback_mode loopback_mode;
 	atomic_t bad_crc_count;
-	int tx_disabled;
+	enum efx_phy_mode phy_mode;
 	int bad_lp_tries;
 };
=20
-static int tenxpress_state_is(struct efx_nic *efx, int state)
-{
-	struct tenxpress_phy_data *phy_data =3D efx->phy_data;
-	return (phy_data !=3D NULL) && (state =3D=3D phy_data->state);
-}
-
-void tenxpress_set_state(struct efx_nic *efx,
-				enum tenxpress_state state)
-{
-	struct tenxpress_phy_data *phy_data =3D efx->phy_data;
-	if (phy_data !=3D NULL)
-		phy_data->state =3D state;
-}
-
 void tenxpress_crc_err(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data =3D efx->phy_data;
@@ -214,15 +184,12 @@ static int tenxpress_phy_init(struct efx_nic *efx=
)
 	if (!phy_data)
 		return -ENOMEM;
 	efx->phy_data =3D phy_data;
+	phy_data->phy_mode =3D efx->phy_mode;
=20
-	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
-
-	if (!sfe4001_phy_flash_cfg) {
-		rc =3D mdio_clause45_wait_reset_mmds(efx,
-						   TENXPRESS_REQUIRED_DEVS);
-		if (rc < 0)
-			goto fail;
-	}
+	rc =3D mdio_clause45_wait_reset_mmds(efx,
+					   TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		goto fail;
=20
 	rc =3D mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
 	if (rc < 0)
@@ -274,7 +241,7 @@ static int tenxpress_special_reset(struct efx_nic *=
efx)
 	return 0;
 }
=20
-static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
+static void tenxpress_set_bad_lp(struct efx_nic *efx, bool bad_lp)
 {
 	struct tenxpress_phy_data *pd =3D efx->phy_data;
 	int reg;
@@ -311,15 +278,15 @@ static void tenxpress_set_bad_lp(struct efx_nic *=
efx, int bad_lp)
  * into a non-10GBT port and if so warn the user that they won't get
  * link any time soon as we are 10GBT only, unless caller specified
  * not to do this check (it isn't useful in loopback) */
-static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
+static bool tenxpress_link_ok(struct efx_nic *efx, bool check_lp)
 {
-	int ok =3D mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
+	bool ok =3D mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
=20
 	if (ok) {
-		tenxpress_set_bad_lp(efx, 0);
+		tenxpress_set_bad_lp(efx, false);
 	} else if (check_lp) {
 		/* Are we plugged into the wrong sort of link? */
-		int bad_lp =3D 0;
+		bool bad_lp =3D false;
 		int phy_id =3D efx->mii.phy_id;
 		int an_stat =3D mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
 						 MDIO_AN_STATUS);
@@ -332,7 +299,7 @@ static int tenxpress_link_ok(struct efx_nic *efx, i=
nt check_lp)
 		 * bit has the advantage of not clearing when autoneg
 		 * restarts. */
 		if (!(xphy_stat & (1 << PMA_PMD_XSTAT_FLP_LBN))) {
-			tenxpress_set_bad_lp(efx, 0);
+			tenxpress_set_bad_lp(efx, false);
 			return ok;
 		}
=20
@@ -367,16 +334,19 @@ static void tenxpress_phyxs_loopback(struct efx_n=
ic *efx)
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data =3D efx->phy_data;
-	int loop_change =3D LOOPBACK_OUT_OF(phy_data, efx,
-					  TENXPRESS_LOOPBACKS);
+	bool loop_change =3D LOOPBACK_OUT_OF(phy_data, efx,
+					   TENXPRESS_LOOPBACKS);
=20
-	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
+	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+		phy_data->phy_mode =3D efx->phy_mode;
 		return;
+	}
=20
 	/* When coming out of transmit disable, coming out of low power
 	 * mode, or moving out of any PHY internal loopback mode,
 	 * perform a special software reset */
-	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
+	if ((efx->phy_mode =3D=3D PHY_MODE_NORMAL &&
+	     phy_data->phy_mode !=3D PHY_MODE_NORMAL) ||
 	    loop_change) {
 		tenxpress_special_reset(efx);
 		falcon_reset_xaui(efx);
@@ -386,9 +356,9 @@ static void tenxpress_phy_reconfigure(struct efx_ni=
c *efx)
 	mdio_clause45_phy_reconfigure(efx);
 	tenxpress_phyxs_loopback(efx);
=20
-	phy_data->tx_disabled =3D efx->tx_disabled;
 	phy_data->loopback_mode =3D efx->loopback_mode;
-	efx->link_up =3D tenxpress_link_ok(efx, 0);
+	phy_data->phy_mode =3D efx->phy_mode;
+	efx->link_up =3D tenxpress_link_ok(efx, false);
 	efx->link_options =3D GM_LPA_10000FULL;
 }
=20
@@ -402,16 +372,15 @@ static void tenxpress_phy_clear_interrupt(struct =
efx_nic *efx)
 static int tenxpress_phy_check_hw(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data =3D efx->phy_data;
-	int phy_up =3D tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL);
-	int link_ok;
+	bool link_ok;
=20
-	link_ok =3D phy_up && tenxpress_link_ok(efx, 1);
+	link_ok =3D (phy_data->phy_mode =3D=3D PHY_MODE_NORMAL &&
+		   tenxpress_link_ok(efx, true));
=20
 	if (link_ok !=3D efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
=20
-	/* Nothing to check if we've already shut down the PHY */
-	if (!phy_up)
+	if (phy_data->phy_mode !=3D PHY_MODE_NORMAL)
 		return 0;
=20
 	if (atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold=
) {
@@ -444,7 +413,7 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
=20
 /* Set the RX and TX LEDs and Link LED flashing. The other LEDs
  * (which probably aren't wired anyway) are left in AUTO mode */
-void tenxpress_phy_blink(struct efx_nic *efx, int blink)
+void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 {
 	int reg;
=20
@@ -507,6 +476,12 @@ static void tenxpress_reset_xaui(struct efx_nic *e=
fx)
 	udelay(10);
 }
=20
+static int tenxpress_phy_test(struct efx_nic *efx)
+{
+	/* BIST is automatically run after a special software reset */
+	return tenxpress_special_reset(efx);
+}
+
 struct efx_phy_operations falcon_tenxpress_phy_ops =3D {
 	.init             =3D tenxpress_phy_init,
 	.reconfigure      =3D tenxpress_phy_reconfigure,
@@ -514,6 +489,7 @@ struct efx_phy_operations falcon_tenxpress_phy_ops =
=3D {
 	.fini             =3D tenxpress_phy_fini,
 	.clear_interrupt  =3D tenxpress_phy_clear_interrupt,
 	.reset_xaui       =3D tenxpress_reset_xaui,
+	.test             =3D tenxpress_phy_test,
 	.mmds             =3D TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        =3D TENXPRESS_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 5e8374a..cdee7c2 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -47,7 +47,7 @@ void efx_stop_queue(struct efx_nic *efx)
  * We want to be able to nest calls to netif_stop_queue(), since each
  * channel can have an individual stop on the queue.
  */
-inline void efx_wake_queue(struct efx_nic *efx)
+void efx_wake_queue(struct efx_nic *efx)
 {
 	local_bh_disable();
 	if (atomic_dec_and_lock(&efx->netif_stop_count,
@@ -59,19 +59,21 @@ inline void efx_wake_queue(struct efx_nic *efx)
 	local_bh_enable();
 }
=20
-static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
-				      struct efx_tx_buffer *buffer)
+static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
+			       struct efx_tx_buffer *buffer)
 {
 	if (buffer->unmap_len) {
 		struct pci_dev *pci_dev =3D tx_queue->efx->pci_dev;
+		dma_addr_t unmap_addr =3D (buffer->dma_addr + buffer->len -
+					 buffer->unmap_len);
 		if (buffer->unmap_single)
-			pci_unmap_single(pci_dev, buffer->unmap_addr,
-					 buffer->unmap_len, PCI_DMA_TODEVICE);
+			pci_unmap_single(pci_dev, unmap_addr, buffer->unmap_len,
+					 PCI_DMA_TODEVICE);
 		else
-			pci_unmap_page(pci_dev, buffer->unmap_addr,
-				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			pci_unmap_page(pci_dev, unmap_addr, buffer->unmap_len,
+				       PCI_DMA_TODEVICE);
 		buffer->unmap_len =3D 0;
-		buffer->unmap_single =3D 0;
+		buffer->unmap_single =3D false;
 	}
=20
 	if (buffer->skb) {
@@ -103,13 +105,13 @@ struct efx_tso_header {
 };
=20
 static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       const struct sk_buff *skb);
+			       struct sk_buff *skb);
 static void efx_fini_tso(struct efx_tx_queue *tx_queue);
 static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
 			       struct efx_tso_header *tsoh);
=20
-static inline void efx_tsoh_free(struct efx_tx_queue *tx_queue,
-				 struct efx_tx_buffer *buffer)
+static void efx_tsoh_free(struct efx_tx_queue *tx_queue,
+			  struct efx_tx_buffer *buffer)
 {
 	if (buffer->tsoh) {
 		if (likely(!buffer->tsoh->unmap_len)) {
@@ -136,8 +138,8 @@ static inline void efx_tsoh_free(struct efx_tx_queu=
e *tx_queue,
  * Returns NETDEV_TX_OK or NETDEV_TX_BUSY
  * You must hold netif_tx_lock() to call this function.
  */
-static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-				  const struct sk_buff *skb)
+static int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
+			   struct sk_buff *skb)
 {
 	struct efx_nic *efx =3D tx_queue->efx;
 	struct pci_dev *pci_dev =3D efx->pci_dev;
@@ -148,7 +150,7 @@ static inline int efx_enqueue_skb(struct efx_tx_que=
ue *tx_queue,
 	unsigned int len, unmap_len =3D 0, fill_level, insert_ptr, misalign;
 	dma_addr_t dma_addr, unmap_addr =3D 0;
 	unsigned int dma_len;
-	unsigned unmap_single;
+	bool unmap_single;
 	int q_space, i =3D 0;
 	int rc =3D NETDEV_TX_OK;
=20
@@ -167,7 +169,7 @@ static inline int efx_enqueue_skb(struct efx_tx_que=
ue *tx_queue,
 	 * since this is more efficient on machines with sparse
 	 * memory.
 	 */
-	unmap_single =3D 1;
+	unmap_single =3D true;
 	dma_addr =3D pci_map_single(pci_dev, skb->data, len, PCI_DMA_TODEVICE=
);
=20
 	/* Process all fragments */
@@ -213,7 +215,7 @@ static inline int efx_enqueue_skb(struct efx_tx_que=
ue *tx_queue,
 			EFX_BUG_ON_PARANOID(buffer->tsoh);
 			EFX_BUG_ON_PARANOID(buffer->skb);
 			EFX_BUG_ON_PARANOID(buffer->len);
-			EFX_BUG_ON_PARANOID(buffer->continuation !=3D 1);
+			EFX_BUG_ON_PARANOID(!buffer->continuation);
 			EFX_BUG_ON_PARANOID(buffer->unmap_len);
=20
 			dma_len =3D (((~dma_addr) & efx->type->tx_dma_mask) + 1);
@@ -233,7 +235,6 @@ static inline int efx_enqueue_skb(struct efx_tx_que=
ue *tx_queue,
 		} while (len);
=20
 		/* Transfer ownership of the unmapping to the final buffer */
-		buffer->unmap_addr =3D unmap_addr;
 		buffer->unmap_single =3D unmap_single;
 		buffer->unmap_len =3D unmap_len;
 		unmap_len =3D 0;
@@ -247,14 +248,14 @@ static inline int efx_enqueue_skb(struct efx_tx_q=
ueue *tx_queue,
 		page_offset =3D fragment->page_offset;
 		i++;
 		/* Map for DMA */
-		unmap_single =3D 0;
+		unmap_single =3D false;
 		dma_addr =3D pci_map_page(pci_dev, page, page_offset, len,
 					PCI_DMA_TODEVICE);
 	}
=20
 	/* Transfer ownership of the skb to the final buffer */
 	buffer->skb =3D skb;
-	buffer->continuation =3D 0;
+	buffer->continuation =3D false;
=20
 	/* Pass off to hardware */
 	falcon_push_buffers(tx_queue);
@@ -287,9 +288,14 @@ static inline int efx_enqueue_skb(struct efx_tx_qu=
eue *tx_queue,
 	}
=20
 	/* Free the fragment we were mid-way through pushing */
-	if (unmap_len)
-		pci_unmap_page(pci_dev, unmap_addr, unmap_len,
-			       PCI_DMA_TODEVICE);
+	if (unmap_len) {
+		if (unmap_single)
+			pci_unmap_single(pci_dev, unmap_addr, unmap_len,
+					 PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(pci_dev, unmap_addr, unmap_len,
+				       PCI_DMA_TODEVICE);
+	}
=20
 	return rc;
 }
@@ -299,8 +305,8 @@ static inline int efx_enqueue_skb(struct efx_tx_que=
ue *tx_queue,
  * This removes packets from the TX queue, up to and including the
  * specified index.
  */
-static inline void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
-				       unsigned int index)
+static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
+				unsigned int index)
 {
 	struct efx_nic *efx =3D tx_queue->efx;
 	unsigned int stop_index, read_ptr;
@@ -320,7 +326,7 @@ static inline void efx_dequeue_buffers(struct efx_t=
x_queue *tx_queue,
 		}
=20
 		efx_dequeue_buffer(tx_queue, buffer);
-		buffer->continuation =3D 1;
+		buffer->continuation =3D true;
 		buffer->len =3D 0;
=20
 		++tx_queue->read_count;
@@ -367,8 +373,15 @@ inline int efx_xmit(struct efx_nic *efx,
  */
 int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_de=
v)
 {
-	struct efx_nic *efx =3D net_dev->priv;
-	return efx_xmit(efx, &efx->tx_queue[0], skb);
+	struct efx_nic *efx =3D netdev_priv(net_dev);
+	struct efx_tx_queue *tx_queue;
+
+	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL))
+		tx_queue =3D &efx->tx_queue[EFX_TX_QUEUE_OFFLOAD_CSUM];
+	else
+		tx_queue =3D &efx->tx_queue[EFX_TX_QUEUE_NO_CSUM];
+
+	return efx_xmit(efx, tx_queue, skb);
 }
=20
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
@@ -412,30 +425,25 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_qu=
eue)
 	/* Allocate software ring */
 	txq_size =3D (efx->type->txd_ring_mask + 1) * sizeof(*tx_queue->buffe=
r);
 	tx_queue->buffer =3D kzalloc(txq_size, GFP_KERNEL);
-	if (!tx_queue->buffer) {
-		rc =3D -ENOMEM;
-		goto fail1;
-	}
+	if (!tx_queue->buffer)
+		return -ENOMEM;
 	for (i =3D 0; i <=3D efx->type->txd_ring_mask; ++i)
-		tx_queue->buffer[i].continuation =3D 1;
+		tx_queue->buffer[i].continuation =3D true;
=20
 	/* Allocate hardware ring */
 	rc =3D falcon_probe_tx(tx_queue);
 	if (rc)
-		goto fail2;
+		goto fail;
=20
 	return 0;
=20
- fail2:
+ fail:
 	kfree(tx_queue->buffer);
 	tx_queue->buffer =3D NULL;
- fail1:
-	tx_queue->used =3D 0;
-
 	return rc;
 }
=20
-int efx_init_tx_queue(struct efx_tx_queue *tx_queue)
+void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	EFX_LOG(tx_queue->efx, "initialising TX queue %d\n", tx_queue->queue)=
;
=20
@@ -446,7 +454,7 @@ int efx_init_tx_queue(struct efx_tx_queue *tx_queue=
)
 	BUG_ON(tx_queue->stopped);
=20
 	/* Set up TX descriptor ring */
-	return falcon_init_tx(tx_queue);
+	falcon_init_tx(tx_queue);
 }
=20
 void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
@@ -461,7 +469,7 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx=
_queue)
 		buffer =3D &tx_queue->buffer[tx_queue->read_count &
 					   tx_queue->efx->type->txd_ring_mask];
 		efx_dequeue_buffer(tx_queue, buffer);
-		buffer->continuation =3D 1;
+		buffer->continuation =3D true;
 		buffer->len =3D 0;
=20
 		++tx_queue->read_count;
@@ -494,7 +502,6 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_qu=
eue)
=20
 	kfree(tx_queue->buffer);
 	tx_queue->buffer =3D NULL;
-	tx_queue->used =3D 0;
 }
=20
=20
@@ -533,47 +540,37 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_=
queue)
=20
 /**
  * struct tso_state - TSO state for an SKB
- * @remaining_len: Bytes of data we've yet to segment
+ * @out_len: Remaining length in current segment
  * @seqnum: Current sequence number
+ * @ipv4_id: Current IPv4 ID, host endian
  * @packet_space: Remaining space in current packet
- * @ifc: Input fragment cursor.
- *	Where we are in the current fragment of the incoming SKB.  These
- *	values get updated in place when we split a fragment over
- *	multiple packets.
- * @p: Parameters.
- *	These values are set once at the start of the TSO send and do
- *	not get changed as the routine progresses.
+ * @dma_addr: DMA address of current position
+ * @in_len: Remaining length in current SKB fragment
+ * @unmap_len: Length of SKB fragment
+ * @unmap_addr: DMA address of SKB fragment
+ * @unmap_single: DMA single vs page mapping flag
+ * @header_len: Number of bytes of header
+ * @full_packet_size: Number of bytes to put in each outgoing segment
  *
  * The state used during segmentation.  It is put into this data struc=
ture
  * just to make it easy to pass into inline functions.
  */
 struct tso_state {
-	unsigned remaining_len;
+	/* Output position */
+	unsigned out_len;
 	unsigned seqnum;
+	unsigned ipv4_id;
 	unsigned packet_space;
=20
-	struct {
-		/* DMA address of current position */
-		dma_addr_t dma_addr;
-		/* Remaining length */
-		unsigned int len;
-		/* DMA address and length of the whole fragment */
-		unsigned int unmap_len;
-		dma_addr_t unmap_addr;
-		struct page *page;
-		unsigned page_off;
-	} ifc;
-
-	struct {
-		/* The number of bytes of header */
-		unsigned int header_length;
-
-		/* The number of bytes to put in each outgoing segment. */
-		int full_packet_size;
-
-		/* Current IPv4 ID, host endian. */
-		unsigned ipv4_id;
-	} p;
+	/* Input position */
+	dma_addr_t dma_addr;
+	unsigned in_len;
+	unsigned unmap_len;
+	dma_addr_t unmap_addr;
+	bool unmap_single;
+
+	unsigned header_len;
+	int full_packet_size;
 };
=20
=20
@@ -581,11 +578,24 @@ struct tso_state {
  * Verify that our various assumptions about sk_buffs and the conditio=
ns
  * under which TSO will be attempted hold true.
  */
-static inline void efx_tso_check_safe(const struct sk_buff *skb)
+static void efx_tso_check_safe(struct sk_buff *skb)
 {
-	EFX_BUG_ON_PARANOID(skb->protocol !=3D htons(ETH_P_IP));
+	__be16 protocol =3D skb->protocol;
+
 	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=3D
-			    skb->protocol);
+			    protocol);
+	if (protocol =3D=3D htons(ETH_P_8021Q)) {
+		/* Find the encapsulated protocol; reset network header
+		 * and transport header based on that. */
+		struct vlan_ethhdr *veh =3D (struct vlan_ethhdr *)skb->data;
+		protocol =3D veh->h_vlan_encapsulated_proto;
+		skb_set_network_header(skb, sizeof(*veh));
+		if (protocol =3D=3D htons(ETH_P_IP))
+			skb_set_transport_header(skb, sizeof(*veh) +
+						 4 * ip_hdr(skb)->ihl);
+	}
+
+	EFX_BUG_ON_PARANOID(protocol !=3D htons(ETH_P_IP));
 	EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol !=3D IPPROTO_TCP);
 	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
 			     + (tcp_hdr(skb)->doff << 2u)) >
@@ -685,18 +695,14 @@ efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,=
 struct efx_tso_header *tsoh)
  * @tx_queue:		Efx TX queue
  * @dma_addr:		DMA address of fragment
  * @len:		Length of fragment
- * @skb:		Only non-null for end of last segment
- * @end_of_packet:	True if last fragment in a packet
- * @unmap_addr:		DMA address of fragment for unmapping
- * @unmap_len:		Only set this in last segment of a fragment
+ * @final_buffer:	The final buffer inserted into the queue
  *
  * Push descriptors onto the TX queue.  Return 0 on success or 1 if
  * @tx_queue full.
  */
 static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			       dma_addr_t dma_addr, unsigned len,
-			       const struct sk_buff *skb, int end_of_packet,
-			       dma_addr_t unmap_addr, unsigned unmap_len)
+			       struct efx_tx_buffer **final_buffer)
 {
 	struct efx_tx_buffer *buffer;
 	struct efx_nic *efx =3D tx_queue->efx;
@@ -724,8 +730,10 @@ static int efx_tx_queue_insert(struct efx_tx_queue=
 *tx_queue,
 			fill_level =3D (tx_queue->insert_count
 				      - tx_queue->old_read_count);
 			q_space =3D efx->type->txd_ring_mask - 1 - fill_level;
-			if (unlikely(q_space-- <=3D 0))
+			if (unlikely(q_space-- <=3D 0)) {
+				*final_buffer =3D NULL;
 				return 1;
+			}
 			smp_mb();
 			--tx_queue->stopped;
 		}
@@ -742,7 +750,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue =
*tx_queue,
 		EFX_BUG_ON_PARANOID(buffer->len);
 		EFX_BUG_ON_PARANOID(buffer->unmap_len);
 		EFX_BUG_ON_PARANOID(buffer->skb);
-		EFX_BUG_ON_PARANOID(buffer->continuation !=3D 1);
+		EFX_BUG_ON_PARANOID(!buffer->continuation);
 		EFX_BUG_ON_PARANOID(buffer->tsoh);
=20
 		buffer->dma_addr =3D dma_addr;
@@ -765,10 +773,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue=
 *tx_queue,
=20
 	EFX_BUG_ON_PARANOID(!len);
 	buffer->len =3D len;
-	buffer->skb =3D skb;
-	buffer->continuation =3D !end_of_packet;
-	buffer->unmap_addr =3D unmap_addr;
-	buffer->unmap_len =3D unmap_len;
+	*final_buffer =3D buffer;
 	return 0;
 }
=20
@@ -780,8 +785,8 @@ static int efx_tx_queue_insert(struct efx_tx_queue =
*tx_queue,
  * a single fragment, and we know it doesn't cross a page boundary.  I=
t
  * also allows us to not worry about end-of-packet etc.
  */
-static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
-				      struct efx_tso_header *tsoh, unsigned len)
+static void efx_tso_put_header(struct efx_tx_queue *tx_queue,
+			       struct efx_tso_header *tsoh, unsigned len)
 {
 	struct efx_tx_buffer *buffer;
=20
@@ -791,7 +796,7 @@ static inline void efx_tso_put_header(struct efx_tx=
_queue *tx_queue,
 	EFX_BUG_ON_PARANOID(buffer->len);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
 	EFX_BUG_ON_PARANOID(buffer->skb);
-	EFX_BUG_ON_PARANOID(buffer->continuation !=3D 1);
+	EFX_BUG_ON_PARANOID(!buffer->continuation);
 	EFX_BUG_ON_PARANOID(buffer->tsoh);
 	buffer->len =3D len;
 	buffer->dma_addr =3D tsoh->dma_addr;
@@ -805,6 +810,7 @@ static inline void efx_tso_put_header(struct efx_tx=
_queue *tx_queue,
 static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 {
 	struct efx_tx_buffer *buffer;
+	dma_addr_t unmap_addr;
=20
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count !=3D tx_queue->write_count) {
@@ -814,11 +820,18 @@ static void efx_enqueue_unwind(struct efx_tx_queu=
e *tx_queue)
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->skb);
 		buffer->len =3D 0;
-		buffer->continuation =3D 1;
+		buffer->continuation =3D true;
 		if (buffer->unmap_len) {
-			pci_unmap_page(tx_queue->efx->pci_dev,
-				       buffer->unmap_addr,
-				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			unmap_addr =3D (buffer->dma_addr + buffer->len -
+				      buffer->unmap_len);
+			if (buffer->unmap_single)
+				pci_unmap_single(tx_queue->efx->pci_dev,
+						 unmap_addr, buffer->unmap_len,
+						 PCI_DMA_TODEVICE);
+			else
+				pci_unmap_page(tx_queue->efx->pci_dev,
+					       unmap_addr, buffer->unmap_len,
+					       PCI_DMA_TODEVICE);
 			buffer->unmap_len =3D 0;
 		}
 	}
@@ -826,50 +839,57 @@ static void efx_enqueue_unwind(struct efx_tx_queu=
e *tx_queue)
=20
=20
 /* Parse the SKB header and initialise state. */
-static inline void tso_start(struct tso_state *st, const struct sk_buf=
f *skb)
+static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 {
 	/* All ethernet/IP/TCP headers combined size is TCP header size
 	 * plus offset of TCP header relative to start of packet.
 	 */
-	st->p.header_length =3D ((tcp_hdr(skb)->doff << 2u)
-			       + PTR_DIFF(tcp_hdr(skb), skb->data));
-	st->p.full_packet_size =3D (st->p.header_length
-				  + skb_shinfo(skb)->gso_size);
+	st->header_len =3D ((tcp_hdr(skb)->doff << 2u)
+			  + PTR_DIFF(tcp_hdr(skb), skb->data));
+	st->full_packet_size =3D st->header_len + skb_shinfo(skb)->gso_size;
=20
-	st->p.ipv4_id =3D ntohs(ip_hdr(skb)->id);
+	st->ipv4_id =3D ntohs(ip_hdr(skb)->id);
 	st->seqnum =3D ntohl(tcp_hdr(skb)->seq);
=20
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
=20
-	st->packet_space =3D st->p.full_packet_size;
-	st->remaining_len =3D skb->len - st->p.header_length;
+	st->packet_space =3D st->full_packet_size;
+	st->out_len =3D skb->len - st->header_len;
+	st->unmap_len =3D 0;
+	st->unmap_single =3D false;
 }
=20
-
-/**
- * tso_get_fragment - record fragment details and map for DMA
- * @st:			TSO state
- * @efx:		Efx NIC
- * @data:		Pointer to fragment data
- * @len:		Length of fragment
- *
- * Record fragment details and map for DMA.  Return 0 on success, or
- * -%ENOMEM if DMA mapping fails.
- */
-static inline int tso_get_fragment(struct tso_state *st, struct efx_ni=
c *efx,
-				   int len, struct page *page, int page_off)
+static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
+			    skb_frag_t *frag)
 {
+	st->unmap_addr =3D pci_map_page(efx->pci_dev, frag->page,
+				      frag->page_offset, frag->size,
+				      PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+		st->unmap_single =3D false;
+		st->unmap_len =3D frag->size;
+		st->in_len =3D frag->size;
+		st->dma_addr =3D st->unmap_addr;
+		return 0;
+	}
+	return -ENOMEM;
+}
=20
-	st->ifc.unmap_addr =3D pci_map_page(efx->pci_dev, page, page_off,
-					  len, PCI_DMA_TODEVICE);
-	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr)))=
 {
-		st->ifc.unmap_len =3D len;
-		st->ifc.len =3D len;
-		st->ifc.dma_addr =3D st->ifc.unmap_addr;
-		st->ifc.page =3D page;
-		st->ifc.page_off =3D page_off;
+static int tso_get_head_fragment(struct tso_state *st, struct efx_nic =
*efx,
+				 const struct sk_buff *skb)
+{
+	int hl =3D st->header_len;
+	int len =3D skb_headlen(skb) - hl;
+
+	st->unmap_addr =3D pci_map_single(efx->pci_dev, skb->data + hl,
+					len, PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+		st->unmap_single =3D true;
+		st->unmap_len =3D len;
+		st->in_len =3D len;
+		st->dma_addr =3D st->unmap_addr;
 		return 0;
 	}
 	return -ENOMEM;
@@ -886,36 +906,45 @@ static inline int tso_get_fragment(struct tso_sta=
te *st, struct efx_nic *efx,
  * of fragment or end-of-packet.  Return 0 on success, 1 if not enough
  * space in @tx_queue.
  */
-static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *t=
x_queue,
-						const struct sk_buff *skb,
-						struct tso_state *st)
+static int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue=
,
+					 const struct sk_buff *skb,
+					 struct tso_state *st)
 {
-
+	struct efx_tx_buffer *buffer;
 	int n, end_of_packet, rc;
=20
-	if (st->ifc.len =3D=3D 0)
+	if (st->in_len =3D=3D 0)
 		return 0;
 	if (st->packet_space =3D=3D 0)
 		return 0;
=20
-	EFX_BUG_ON_PARANOID(st->ifc.len <=3D 0);
+	EFX_BUG_ON_PARANOID(st->in_len <=3D 0);
 	EFX_BUG_ON_PARANOID(st->packet_space <=3D 0);
=20
-	n =3D min(st->ifc.len, st->packet_space);
+	n =3D min(st->in_len, st->packet_space);
=20
 	st->packet_space -=3D n;
-	st->remaining_len -=3D n;
-	st->ifc.len -=3D n;
-	st->ifc.page_off +=3D n;
-	end_of_packet =3D st->remaining_len =3D=3D 0 || st->packet_space =3D=3D=
 0;
-
-	rc =3D efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n,
-				 st->remaining_len ? NULL : skb,
-				 end_of_packet, st->ifc.unmap_addr,
-				 st->ifc.len ? 0 : st->ifc.unmap_len);
-
-	st->ifc.dma_addr +=3D n;
+	st->out_len -=3D n;
+	st->in_len -=3D n;
+
+	rc =3D efx_tx_queue_insert(tx_queue, st->dma_addr, n, &buffer);
+	if (likely(rc =3D=3D 0)) {
+		if (st->out_len =3D=3D 0)
+			/* Transfer ownership of the skb */
+			buffer->skb =3D skb;
+
+		end_of_packet =3D st->out_len =3D=3D 0 || st->packet_space =3D=3D 0;
+		buffer->continuation =3D !end_of_packet;
+
+		if (st->in_len =3D=3D 0) {
+			/* Transfer ownership of the pci mapping */
+			buffer->unmap_len =3D st->unmap_len;
+			buffer->unmap_single =3D st->unmap_single;
+			st->unmap_len =3D 0;
+		}
+	}
=20
+	st->dma_addr +=3D n;
 	return rc;
 }
=20
@@ -929,9 +958,9 @@ static inline int tso_fill_packet_with_fragment(str=
uct efx_tx_queue *tx_queue,
  * Generate a new header and prepare for the new packet.  Return 0 on
  * success, or -1 if failed to alloc header.
  */
-static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
-				       const struct sk_buff *skb,
-				       struct tso_state *st)
+static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
+				const struct sk_buff *skb,
+				struct tso_state *st)
 {
 	struct efx_tso_header *tsoh;
 	struct iphdr *tsoh_iph;
@@ -940,7 +969,7 @@ static inline int tso_start_new_packet(struct efx_t=
x_queue *tx_queue,
 	u8 *header;
=20
 	/* Allocate a DMA-mapped header buffer. */
-	if (likely(TSOH_SIZE(st->p.header_length) <=3D TSOH_STD_SIZE)) {
+	if (likely(TSOH_SIZE(st->header_len) <=3D TSOH_STD_SIZE)) {
 		if (tx_queue->tso_headers_free =3D=3D NULL) {
 			if (efx_tsoh_block_alloc(tx_queue))
 				return -1;
@@ -951,7 +980,7 @@ static inline int tso_start_new_packet(struct efx_t=
x_queue *tx_queue,
 		tsoh->unmap_len =3D 0;
 	} else {
 		tx_queue->tso_long_headers++;
-		tsoh =3D efx_tsoh_heap_alloc(tx_queue, st->p.header_length);
+		tsoh =3D efx_tsoh_heap_alloc(tx_queue, st->header_len);
 		if (unlikely(!tsoh))
 			return -1;
 	}
@@ -961,33 +990,32 @@ static inline int tso_start_new_packet(struct efx=
_tx_queue *tx_queue,
 	tsoh_iph =3D (struct iphdr *)(header + SKB_IPV4_OFF(skb));
=20
 	/* Copy and update the headers. */
-	memcpy(header, skb->data, st->p.header_length);
+	memcpy(header, skb->data, st->header_len);
=20
 	tsoh_th->seq =3D htonl(st->seqnum);
 	st->seqnum +=3D skb_shinfo(skb)->gso_size;
-	if (st->remaining_len > skb_shinfo(skb)->gso_size) {
+	if (st->out_len > skb_shinfo(skb)->gso_size) {
 		/* This packet will not finish the TSO burst. */
-		ip_length =3D st->p.full_packet_size - ETH_HDR_LEN(skb);
+		ip_length =3D st->full_packet_size - ETH_HDR_LEN(skb);
 		tsoh_th->fin =3D 0;
 		tsoh_th->psh =3D 0;
 	} else {
 		/* This packet will be the last in the TSO burst. */
-		ip_length =3D (st->p.header_length - ETH_HDR_LEN(skb)
-			     + st->remaining_len);
+		ip_length =3D st->header_len - ETH_HDR_LEN(skb) + st->out_len;
 		tsoh_th->fin =3D tcp_hdr(skb)->fin;
 		tsoh_th->psh =3D tcp_hdr(skb)->psh;
 	}
 	tsoh_iph->tot_len =3D htons(ip_length);
=20
 	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
-	tsoh_iph->id =3D htons(st->p.ipv4_id);
-	st->p.ipv4_id++;
+	tsoh_iph->id =3D htons(st->ipv4_id);
+	st->ipv4_id++;
=20
 	st->packet_space =3D skb_shinfo(skb)->gso_size;
 	++tx_queue->tso_packets;
=20
 	/* Form a descriptor for this header. */
-	efx_tso_put_header(tx_queue, tsoh, st->p.header_length);
+	efx_tso_put_header(tx_queue, tsoh, st->header_len);
=20
 	return 0;
 }
@@ -1005,11 +1033,11 @@ static inline int tso_start_new_packet(struct e=
fx_tx_queue *tx_queue,
  * %NETDEV_TX_OK or %NETDEV_TX_BUSY.
  */
 static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       const struct sk_buff *skb)
+			       struct sk_buff *skb)
 {
+	struct efx_nic *efx =3D tx_queue->efx;
 	int frag_i, rc, rc2 =3D NETDEV_TX_OK;
 	struct tso_state state;
-	skb_frag_t *f;
=20
 	/* Verify TSO is safe - these checks should never fail. */
 	efx_tso_check_safe(skb);
@@ -1021,29 +1049,16 @@ static int efx_enqueue_skb_tso(struct efx_tx_qu=
eue *tx_queue,
 	/* Assume that skb header area contains exactly the headers, and
 	 * all payload is in the frag list.
 	 */
-	if (skb_headlen(skb) =3D=3D state.p.header_length) {
+	if (skb_headlen(skb) =3D=3D state.header_len) {
 		/* Grab the first payload fragment. */
 		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
 		frag_i =3D 0;
-		f =3D &skb_shinfo(skb)->frags[frag_i];
-		rc =3D tso_get_fragment(&state, tx_queue->efx,
-				      f->size, f->page, f->page_offset);
+		rc =3D tso_get_fragment(&state, efx,
+				      skb_shinfo(skb)->frags + frag_i);
 		if (rc)
 			goto mem_err;
 	} else {
-		/* It may look like this code fragment assumes that the
-		 * skb->data portion does not cross a page boundary, but
-		 * that is not the case.  It is guaranteed to be direct
-		 * mapped memory, and therefore is physically contiguous,
-		 * and so DMA will work fine.  kmap_atomic() on this region
-		 * will just return the direct mapping, so that will work
-		 * too.
-		 */
-		int page_off =3D (unsigned long)skb->data & (PAGE_SIZE - 1);
-		int hl =3D state.p.header_length;
-		rc =3D tso_get_fragment(&state, tx_queue->efx,
-				      skb_headlen(skb) - hl,
-				      virt_to_page(skb->data), page_off + hl);
+		rc =3D tso_get_head_fragment(&state, efx, skb);
 		if (rc)
 			goto mem_err;
 		frag_i =3D -1;
@@ -1058,13 +1073,12 @@ static int efx_enqueue_skb_tso(struct efx_tx_qu=
eue *tx_queue,
 			goto stop;
=20
 		/* Move onto the next fragment? */
-		if (state.ifc.len =3D=3D 0) {
+		if (state.in_len =3D=3D 0) {
 			if (++frag_i >=3D skb_shinfo(skb)->nr_frags)
 				/* End of payload reached. */
 				break;
-			f =3D &skb_shinfo(skb)->frags[frag_i];
-			rc =3D tso_get_fragment(&state, tx_queue->efx,
-					      f->size, f->page, f->page_offset);
+			rc =3D tso_get_fragment(&state, efx,
+					      skb_shinfo(skb)->frags + frag_i);
 			if (rc)
 				goto mem_err;
 		}
@@ -1082,8 +1096,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queu=
e *tx_queue,
 	return NETDEV_TX_OK;
=20
  mem_err:
-	EFX_ERR(tx_queue->efx, "Out of memory for TSO headers, or PCI mapping=
"
-		" error\n");
+	EFX_ERR(efx, "Out of memory for TSO headers, or PCI mapping error\n")=
;
 	dev_kfree_skb_any((struct sk_buff *)skb);
 	goto unwind;
=20
@@ -1092,9 +1105,19 @@ static int efx_enqueue_skb_tso(struct efx_tx_que=
ue *tx_queue,
=20
 	/* Stop the queue if it wasn't stopped before. */
 	if (tx_queue->stopped =3D=3D 1)
-		efx_stop_queue(tx_queue->efx);
+		efx_stop_queue(efx);
=20
  unwind:
+	/* Free the DMA mapping we were in the process of writing out */
+	if (state.unmap_len) {
+		if (state.unmap_single)
+			pci_unmap_single(efx->pci_dev, state.unmap_addr,
+					 state.unmap_len, PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(efx->pci_dev, state.unmap_addr,
+				       state.unmap_len, PCI_DMA_TODEVICE);
+	}
+
 	efx_enqueue_unwind(tx_queue);
 	return rc2;
 }
diff --git a/drivers/net/sfc/tx.h b/drivers/net/sfc/tx.h
index 1526a73..5e1cc23 100644
--- a/drivers/net/sfc/tx.h
+++ b/drivers/net/sfc/tx.h
@@ -15,7 +15,7 @@
=20
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
-int efx_init_tx_queue(struct efx_tx_queue *tx_queue);
+void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
=20
 int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_de=
v);
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workaround=
s.h
index 35ab19c..a824f59 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -20,8 +20,6 @@
=20
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
-/* SNAP frames have TOBE_DISC set */
-#define EFX_WORKAROUND_5475 EFX_WORKAROUND_ALWAYS
 /* RX PCIe double split performance issue */
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <=3D 16 byte TXes */
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index f3684ad..f6edecc 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -40,7 +40,7 @@ void xfp_set_led(struct efx_nic *p, int led, int mode=
)
 }
=20
 struct xfp_phy_data {
-	int tx_disabled;
+	enum efx_phy_mode phy_mode;
 };
=20
 #define XFP_MAX_RESET_TIME 500
@@ -93,7 +93,7 @@ static int xfp_phy_init(struct efx_nic *efx)
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
 		 MDIO_ID_REV(devid));
=20
-	phy_data->tx_disabled =3D efx->tx_disabled;
+	phy_data->phy_mode =3D efx->phy_mode;
=20
 	rc =3D xfp_reset_phy(efx);
=20
@@ -136,13 +136,14 @@ static void xfp_phy_reconfigure(struct efx_nic *e=
fx)
 	struct xfp_phy_data *phy_data =3D efx->phy_data;
=20
 	/* Reset the PHY when moving from tx off to tx on */
-	if (phy_data->tx_disabled && !efx->tx_disabled)
+	if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
+	    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
 		xfp_reset_phy(efx);
=20
 	mdio_clause45_transmit_disable(efx);
 	mdio_clause45_phy_reconfigure(efx);
=20
-	phy_data->tx_disabled =3D efx->tx_disabled;
+	phy_data->phy_mode =3D efx->phy_mode;
 	efx->link_up =3D xfp_link_ok(efx);
 	efx->link_options =3D GM_LPA_10000FULL;
 }
@@ -151,7 +152,7 @@ static void xfp_phy_reconfigure(struct efx_nic *efx=
)
 static void xfp_phy_fini(struct efx_nic *efx)
 {
 	/* Clobber the LED if it was blinking */
-	efx->board_info.blink(efx, 0);
+	efx->board_info.blink(efx, false);
=20
 	/* Free the context block */
 	kfree(efx->phy_data);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e24b25c..3805b93 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3732,27 +3732,63 @@ static int sky2_get_eeprom_len(struct net_devic=
e *dev)
 	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
=20
-static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
+static int sky2_vpd_wait(const struct sky2_hw *hw, int cap, u16 busy)
 {
-	u32 val;
+	unsigned long start =3D jiffies;
=20
-	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+	while ( (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) =3D=
=3D busy) {
+		/* Can take up to 10.6 ms for write */
+		if (time_after(jiffies, start + HZ/4)) {
+			dev_err(&hw->pdev->dev, PFX "VPD cycle timed out");
+			return -ETIMEDOUT;
+		}
+		mdelay(1);
+	}
=20
-	do {
-		offset =3D sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
-	} while (!(offset & PCI_VPD_ADDR_F));
+	return 0;
+}
+
+static int sky2_vpd_read(struct sky2_hw *hw, int cap, void *data,
+			 u16 offset, size_t length)
+{
+	int rc =3D 0;
+
+	while (length > 0) {
+		u32 val;
+
+		sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+		rc =3D sky2_vpd_wait(hw, cap, 0);
+		if (rc)
+			break;
=20
-	val =3D sky2_pci_read32(hw, cap + PCI_VPD_DATA);
-	return val;
+		val =3D sky2_pci_read32(hw, cap + PCI_VPD_DATA);
+
+		memcpy(data, &val, min(sizeof(val), length));
+		offset +=3D sizeof(u32);
+		data +=3D sizeof(u32);
+		length -=3D sizeof(u32);
+	}
+
+	return rc;
 }
=20
-static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u3=
2 val)
+static int sky2_vpd_write(struct sky2_hw *hw, int cap, const void *dat=
a,
+			  u16 offset, unsigned int length)
 {
-	sky2_pci_write16(hw, cap + PCI_VPD_DATA, val);
-	sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
-	do {
-		offset =3D sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
-	} while (offset & PCI_VPD_ADDR_F);
+	unsigned int i;
+	int rc =3D 0;
+
+	for (i =3D 0; i < length; i +=3D sizeof(u32)) {
+		u32 val =3D *(u32 *)(data + i);
+
+		sky2_pci_write32(hw, cap + PCI_VPD_DATA, val);
+		sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+
+		rc =3D sky2_vpd_wait(hw, cap, PCI_VPD_ADDR_F);
+		if (rc)
+			break;
+	}
+	return rc;
 }
=20
 static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eepr=
om *eeprom,
@@ -3760,24 +3796,13 @@ static int sky2_get_eeprom(struct net_device *d=
ev, struct ethtool_eeprom *eeprom
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	int cap =3D pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-	int length =3D eeprom->len;
-	u16 offset =3D eeprom->offset;
=20
 	if (!cap)
 		return -EINVAL;
=20
 	eeprom->magic =3D SKY2_EEPROM_MAGIC;
=20
-	while (length > 0) {
-		u32 val =3D sky2_vpd_read(sky2->hw, cap, offset);
-		int n =3D min_t(int, length, sizeof(val));
-
-		memcpy(data, &val, n);
-		length -=3D n;
-		data +=3D n;
-		offset +=3D n;
-	}
-	return 0;
+	return sky2_vpd_read(sky2->hw, cap, data, eeprom->offset, eeprom->len=
);
 }
=20
 static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eepr=
om *eeprom,
@@ -3785,8 +3810,6 @@ static int sky2_set_eeprom(struct net_device *dev=
, struct ethtool_eeprom *eeprom
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	int cap =3D pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-	int length =3D eeprom->len;
-	u16 offset =3D eeprom->offset;
=20
 	if (!cap)
 		return -EINVAL;
@@ -3794,21 +3817,11 @@ static int sky2_set_eeprom(struct net_device *d=
ev, struct ethtool_eeprom *eeprom
 	if (eeprom->magic !=3D SKY2_EEPROM_MAGIC)
 		return -EINVAL;
=20
-	while (length > 0) {
-		u32 val;
-		int n =3D min_t(int, length, sizeof(val));
-
-		if (n < sizeof(val))
-			val =3D sky2_vpd_read(sky2->hw, cap, offset);
-		memcpy(&val, data, n);
-
-		sky2_vpd_write(sky2->hw, cap, offset, val);
+	/* Partial writes not supported */
+	if ((eeprom->offset & 3) || (eeprom->len & 3))
+		return -EINVAL;
=20
-		length -=3D n;
-		data +=3D n;
-		offset +=3D n;
-	}
-	return 0;
+	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->le=
n);
 }
=20
=20
@@ -4178,6 +4191,69 @@ static int __devinit pci_wake_enabled(struct pci=
_dev *dev)
 	return value & PCI_PM_CTRL_PME_ENABLE;
 }
=20
+/*
+ * Read and parse the first part of Vital Product Data
+ */
+#define VPD_SIZE	128
+#define VPD_MAGIC	0x82
+
+static void __devinit sky2_vpd_info(struct sky2_hw *hw)
+{
+	int cap =3D pci_find_capability(hw->pdev, PCI_CAP_ID_VPD);
+	const u8 *p;
+	u8 *vpd_buf =3D NULL;
+	u16 len;
+	static struct vpd_tag {
+		char tag[2];
+		char *label;
+	} vpd_tags[] =3D {
+		{ "PN",	"Part Number" },
+		{ "EC", "Engineering Level" },
+		{ "MN", "Manufacturer" },
+	};
+
+	if (!cap)
+		goto out;
+
+	vpd_buf =3D kmalloc(VPD_SIZE, GFP_KERNEL);
+	if (!vpd_buf)
+		goto out;
+
+	if (sky2_vpd_read(hw, cap, vpd_buf, 0, VPD_SIZE))
+		goto out;
+
+	if (vpd_buf[0] !=3D VPD_MAGIC)
+		goto out;
+	len =3D vpd_buf[1];
+	if (len =3D=3D 0 || len > VPD_SIZE - 4)
+		goto out;
+	p =3D vpd_buf + 3;
+	dev_info(&hw->pdev->dev, "%.*s\n", len, p);
+	p +=3D len;
+
+	while (p < vpd_buf + VPD_SIZE - 4) {
+		int i;
+
+		if (!memcmp("RW", p, 2))	/* end marker */
+			break;
+
+		len =3D p[2];
+		if (len > (p - vpd_buf) - 4)
+			break;
+
+		for (i =3D 0; i < ARRAY_SIZE(vpd_tags); i++) {
+			if (!memcmp(vpd_tags[i].tag, p, 2)) {
+				printk(KERN_DEBUG " %s: %.*s\n",
+				       vpd_tags[i].label, len, p + 3);
+				break;
+			}
+		}
+		p +=3D len + 3;
+	}
+out:
+	kfree(vpd_buf);
+}
+
 /* This driver supports yukon2 chipset only */
 static const char *sky2_name(u8 chipid, char *buf, int sz)
 {
@@ -4276,13 +4352,13 @@ static int __devinit sky2_probe(struct pci_dev =
*pdev,
 	if (err)
 		goto err_out_iounmap;
=20
-	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s rev %d\n",
-		 DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
-		 pdev->irq, sky2_name(hw->chip_id, buf1, sizeof(buf1)),
-		 hw->chip_rev);
+	dev_info(&pdev->dev, "Yukon-2 %s chip revision %d\n",
+		 sky2_name(hw->chip_id, buf1, sizeof(buf1)), hw->chip_rev);
=20
 	sky2_reset(hw);
=20
+	sky2_vpd_info(hw);
+
 	dev =3D sky2_init_netdev(hw, 0, using_dac, wol_default);
 	if (!dev) {
 		err =3D -ENOMEM;
@@ -4533,6 +4609,8 @@ static struct pci_driver sky2_driver =3D {
=20
 static int __init sky2_init_module(void)
 {
+	pr_info(PFX "driver version " DRV_VERSION "\n");
+
 	sky2_debug_init();
 	return pci_register_driver(&sky2_driver);
 }
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenrin=
g/lanstreamer.c
index 47d84cd..59d1673 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -119,7 +119,6 @@
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
-#include <linux/version.h>
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
=20
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 96dff04..5b78700 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -914,7 +914,7 @@ static void alloc_rbufs(struct net_device *dev)
=20
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb =3D dev_alloc_skb(rp->rx_buf_sz);
+		struct sk_buff *skb =3D netdev_alloc_skb(dev, rp->rx_buf_sz);
 		rp->rx_skbuff[i] =3D skb;
 		if (skb =3D=3D NULL)
 			break;
@@ -1473,8 +1473,8 @@ static int rhine_rx(struct net_device *dev, int l=
imit)
 			/* Check if the packet is long enough to accept without
 			   copying to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-				(skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
+				(skb =3D netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN)) !=3D NULL)=
 {
+				skb_reserve(skb, NET_IP_ALIGN);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(rp->pdev,
 							    rp->rx_skbuff_dma[entry],
 							    rp->rx_buf_sz,
@@ -1518,7 +1518,7 @@ static int rhine_rx(struct net_device *dev, int l=
imit)
 		struct sk_buff *skb;
 		entry =3D rp->dirty_rx % RX_RING_SIZE;
 		if (rp->rx_skbuff[entry] =3D=3D NULL) {
-			skb =3D dev_alloc_skb(rp->rx_buf_sz);
+			skb =3D netdev_alloc_skb(dev, rp->rx_buf_sz);
 			rp->rx_skbuff[entry] =3D skb;
 			if (skb =3D=3D NULL)
 				break;	/* Better luck next round. */
