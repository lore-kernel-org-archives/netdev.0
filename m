From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/5] ethernet: Convert MAC_ADDR_LEN uses to ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:02 -0800
Message-ID: <64557f94a583ac17b9be62fe412a0bd7cd496537.1321472143.git.joe@perches.com>
References: <cover.1321472142.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of #defines, use the normal #define from if_ether.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   12 +++---
 drivers/net/ethernet/freescale/gianfar.h |    3 --
 drivers/net/ethernet/micrel/ksz884x.c    |   59 ++++++++++++++----------------
 drivers/net/ethernet/realtek/r8169.c     |    5 +--
 drivers/net/ethernet/sis/sis190.c        |    8 ++---
 5 files changed, 38 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 83199fd..d103475 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -734,7 +734,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
-		memcpy(dev->dev_addr, mac_addr, MAC_ADDR_LEN);
+		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
 
 	if (model && !strcasecmp(model, "TSEC"))
 		priv->device_flags =
@@ -3114,7 +3114,7 @@ static void gfar_set_multi(struct net_device *dev)
 static void gfar_clear_exact_match(struct net_device *dev)
 {
 	int idx;
-	static const u8 zero_arr[MAC_ADDR_LEN] = {0, 0, 0, 0, 0, 0};
+	static const u8 zero_arr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 
 	for(idx = 1;idx < GFAR_EM_NUM + 1;idx++)
 		gfar_set_mac_for_addr(dev, idx, zero_arr);
@@ -3137,7 +3137,7 @@ static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
 {
 	u32 tempval;
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 result = ether_crc(MAC_ADDR_LEN, addr);
+	u32 result = ether_crc(ETH_ALEN, addr);
 	int width = priv->hash_width;
 	u8 whichbit = (result >> (32 - width)) & 0x1f;
 	u8 whichreg = result >> (32 - width + 5);
@@ -3158,7 +3158,7 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	int idx;
-	char tmpbuf[MAC_ADDR_LEN];
+	char tmpbuf[ETH_ALEN];
 	u32 tempval;
 	u32 __iomem *macptr = &regs->macstnaddr1;
 
@@ -3166,8 +3166,8 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 
 	/* Now copy it into the mac registers backwards, cuz */
 	/* little endian is silly */
-	for (idx = 0; idx < MAC_ADDR_LEN; idx++)
-		tmpbuf[MAC_ADDR_LEN - 1 - idx] = addr[idx];
+	for (idx = 0; idx < ETH_ALEN; idx++)
+		tmpbuf[ETH_ALEN - 1 - idx] = addr[idx];
 
 	gfar_write(macptr, *((u32 *) (tmpbuf)));
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 9aa4377..d93d49c 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -74,9 +74,6 @@ struct ethtool_rx_list {
  * will be the next highest multiple of 512 bytes. */
 #define INCREMENTAL_BUFFER_SIZE 512
 
-
-#define MAC_ADDR_LEN 6
-
 #define PHY_INIT_TIMEOUT 100000
 #define GFAR_PHY_CHANGE_TIME 2
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 3b67fe6..cbdbc77d 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -743,8 +743,7 @@
 /* Change default LED mode. */
 #define SET_DEFAULT_LED			LED_SPEED_DUPLEX_ACT
 
-#define MAC_ADDR_LEN			6
-#define MAC_ADDR_ORDER(i)		(MAC_ADDR_LEN - 1 - (i))
+#define MAC_ADDR_ORDER(i)		(ETH_ALEN - 1 - (i))
 
 #define MAX_ETHERNET_BODY_SIZE		1500
 #define ETHERNET_HEADER_SIZE		14
@@ -1043,7 +1042,7 @@ enum {
  * @valid:	Valid setting indicating the entry is being used.
  */
 struct ksz_mac_table {
-	u8 mac_addr[MAC_ADDR_LEN];
+	u8 mac_addr[ETH_ALEN];
 	u16 vid;
 	u8 fid;
 	u8 ports;
@@ -1187,8 +1186,8 @@ struct ksz_switch {
 	u8 diffserv[DIFFSERV_ENTRIES];
 	u8 p_802_1p[PRIO_802_1P_ENTRIES];
 
-	u8 br_addr[MAC_ADDR_LEN];
-	u8 other_addr[MAC_ADDR_LEN];
+	u8 br_addr[ETH_ALEN];
+	u8 other_addr[ETH_ALEN];
 
 	u8 broad_per;
 	u8 member;
@@ -1292,14 +1291,14 @@ struct ksz_hw {
 	int tx_int_mask;
 	int tx_size;
 
-	u8 perm_addr[MAC_ADDR_LEN];
-	u8 override_addr[MAC_ADDR_LEN];
-	u8 address[ADDITIONAL_ENTRIES][MAC_ADDR_LEN];
+	u8 perm_addr[ETH_ALEN];
+	u8 override_addr[ETH_ALEN];
+	u8 address[ADDITIONAL_ENTRIES][ETH_ALEN];
 	u8 addr_list_size;
 	u8 mac_override;
 	u8 promiscuous;
 	u8 all_multi;
-	u8 multi_list[MAX_MULTICAST_LIST][MAC_ADDR_LEN];
+	u8 multi_list[MAX_MULTICAST_LIST][ETH_ALEN];
 	u8 multi_bits[HW_MULTICAST_SIZE];
 	u8 multi_list_size;
 
@@ -3654,7 +3653,7 @@ static void hw_add_wol_bcast(struct ksz_hw *hw)
 	static const u8 mask[] = { 0x3F };
 	static const u8 pattern[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 
-	hw_set_wol_frame(hw, 2, 1, mask, MAC_ADDR_LEN, pattern);
+	hw_set_wol_frame(hw, 2, 1, mask, ETH_ALEN, pattern);
 }
 
 /**
@@ -3689,7 +3688,7 @@ static void hw_add_wol_ucast(struct ksz_hw *hw)
 {
 	static const u8 mask[] = { 0x3F };
 
-	hw_set_wol_frame(hw, 0, 1, mask, MAC_ADDR_LEN, hw->override_addr);
+	hw_set_wol_frame(hw, 0, 1, mask, ETH_ALEN, hw->override_addr);
 }
 
 /**
@@ -4055,7 +4054,7 @@ static void hw_set_addr(struct ksz_hw *hw)
 {
 	int i;
 
-	for (i = 0; i < MAC_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		writeb(hw->override_addr[MAC_ADDR_ORDER(i)],
 			hw->io + KS884X_ADDR_0_OFFSET + i);
 
@@ -4072,17 +4071,16 @@ static void hw_read_addr(struct ksz_hw *hw)
 {
 	int i;
 
-	for (i = 0; i < MAC_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		hw->perm_addr[MAC_ADDR_ORDER(i)] = readb(hw->io +
 			KS884X_ADDR_0_OFFSET + i);
 
 	if (!hw->mac_override) {
-		memcpy(hw->override_addr, hw->perm_addr, MAC_ADDR_LEN);
+		memcpy(hw->override_addr, hw->perm_addr, ETH_ALEN);
 		if (empty_addr(hw->override_addr)) {
-			memcpy(hw->perm_addr, DEFAULT_MAC_ADDRESS,
-				MAC_ADDR_LEN);
+			memcpy(hw->perm_addr, DEFAULT_MAC_ADDRESS, ETH_ALEN);
 			memcpy(hw->override_addr, DEFAULT_MAC_ADDRESS,
-				MAC_ADDR_LEN);
+			       ETH_ALEN);
 			hw->override_addr[5] += hw->id;
 			hw_set_addr(hw);
 		}
@@ -4130,16 +4128,16 @@ static int hw_add_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 	int j = ADDITIONAL_ENTRIES;
 
-	if (!memcmp(hw->override_addr, mac_addr, MAC_ADDR_LEN))
+	if (!memcmp(hw->override_addr, mac_addr, ETH_ALEN))
 		return 0;
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, MAC_ADDR_LEN))
+		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN))
 			return 0;
 		if (ADDITIONAL_ENTRIES == j && empty_addr(hw->address[i]))
 			j = i;
 	}
 	if (j < ADDITIONAL_ENTRIES) {
-		memcpy(hw->address[j], mac_addr, MAC_ADDR_LEN);
+		memcpy(hw->address[j], mac_addr, ETH_ALEN);
 		hw_ena_add_addr(hw, j, hw->address[j]);
 		return 0;
 	}
@@ -4151,8 +4149,8 @@ static int hw_del_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, MAC_ADDR_LEN)) {
-			memset(hw->address[i], 0, MAC_ADDR_LEN);
+		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN)) {
+			memset(hw->address[i], 0, ETH_ALEN);
 			writel(0, hw->io + ADD_ADDR_INCR * i +
 				KS_ADD_ADDR_0_HI);
 			return 0;
@@ -5676,7 +5674,7 @@ static int netdev_set_mac_address(struct net_device *dev, void *addr)
 		hw_del_addr(hw, dev->dev_addr);
 	else {
 		hw->mac_override = 1;
-		memcpy(hw->override_addr, mac->sa_data, MAC_ADDR_LEN);
+		memcpy(hw->override_addr, mac->sa_data, ETH_ALEN);
 	}
 
 	memcpy(dev->dev_addr, mac->sa_data, MAX_ADDR_LEN);
@@ -5786,7 +5784,7 @@ static void netdev_set_rx_mode(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			if (i >= MAX_MULTICAST_LIST)
 				break;
-			memcpy(hw->multi_list[i++], ha->addr, MAC_ADDR_LEN);
+			memcpy(hw->multi_list[i++], ha->addr, ETH_ALEN);
 		}
 		hw->multi_list_size = (u8) i;
 		hw_set_grp_addr(hw);
@@ -6861,7 +6859,7 @@ static void get_mac_addr(struct dev_info *hw_priv, u8 *macaddr, int port)
 	int num;
 
 	i = j = num = got_num = 0;
-	while (j < MAC_ADDR_LEN) {
+	while (j < ETH_ALEN) {
 		if (macaddr[i]) {
 			int digit;
 
@@ -6892,7 +6890,7 @@ static void get_mac_addr(struct dev_info *hw_priv, u8 *macaddr, int port)
 		}
 		i++;
 	}
-	if (MAC_ADDR_LEN == j) {
+	if (ETH_ALEN == j) {
 		if (MAIN_PORT == port)
 			hw_priv->hw.mac_override = 1;
 	}
@@ -7059,7 +7057,7 @@ static int __devinit pcidev_init(struct pci_dev *pdev,
 
 	/* Multiple device interfaces mode requires a second MAC address. */
 	if (hw->dev_count > 1) {
-		memcpy(sw->other_addr, hw->override_addr, MAC_ADDR_LEN);
+		memcpy(sw->other_addr, hw->override_addr, ETH_ALEN);
 		read_other_addr(hw);
 		if (mac1addr[0] != ':')
 			get_mac_addr(hw_priv, mac1addr, OTHER_PORT);
@@ -7109,12 +7107,11 @@ static int __devinit pcidev_init(struct pci_dev *pdev,
 		dev->irq = pdev->irq;
 		if (MAIN_PORT == i)
 			memcpy(dev->dev_addr, hw_priv->hw.override_addr,
-				MAC_ADDR_LEN);
+			       ETH_ALEN);
 		else {
-			memcpy(dev->dev_addr, sw->other_addr,
-				MAC_ADDR_LEN);
+			memcpy(dev->dev_addr, sw->other_addr, ETH_ALEN);
 			if (!memcmp(sw->other_addr, hw->override_addr,
-					MAC_ADDR_LEN))
+				    ETH_ALEN))
 				dev->dev_addr[5] += port->first_port;
 		}
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cdf66d6..847d855 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -69,9 +69,6 @@
    The RTL chips use a 64 element hash table based on the Ethernet CRC. */
 static const int multicast_filter_limit = 32;
 
-/* MAC address length */
-#define MAC_ADDR_LEN	6
-
 #define MAX_READ_REQUEST_SHIFT	12
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
@@ -4099,7 +4096,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&tp->lock);
 
 	/* Get MAC address */
-	for (i = 0; i < MAC_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 220e982..5b118cd 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -47,8 +47,6 @@
 #define sis190_rx_skb			netif_rx
 #define sis190_rx_quota(count, quota)	count
 
-#define MAC_ADDR_LEN		6
-
 #define NUM_TX_DESC		64	/* [8..1024] */
 #define NUM_RX_DESC		64	/* [8..8192] */
 #define TX_RING_BYTES		(NUM_TX_DESC * sizeof(struct TxDesc))
@@ -1601,7 +1599,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 	}
 
 	/* Get MAC address from EEPROM */
-	for (i = 0; i < MAC_ADDR_LEN / 2; i++) {
+	for (i = 0; i < ETH_ALEN / 2; i++) {
 		u16 w = sis190_read_eeprom(ioaddr, EEPROMMACAddr + i);
 
 		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(w);
@@ -1653,7 +1651,7 @@ static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 	udelay(50);
 	pci_read_config_byte(isa_bridge, 0x48, &reg);
 
-        for (i = 0; i < MAC_ADDR_LEN; i++) {
+        for (i = 0; i < ETH_ALEN; i++) {
                 outb(0x9 + i, 0x78);
                 dev->dev_addr[i] = inb(0x79);
         }
@@ -1692,7 +1690,7 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 	 */
 	SIS_W16(RxMacControl, ctl & ~0x0f00);
 
-	for (i = 0; i < MAC_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		SIS_W8(RxMacAddr + i, dev->dev_addr[i]);
 
 	SIS_W16(RxMacControl, ctl);
-- 
1.7.6.405.gc1be0
