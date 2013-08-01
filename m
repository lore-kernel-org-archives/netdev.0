From: Joe Perches <joe@perches.com>
Subject: [PATCH V3 3/3] ethernet: Convert mac address uses of 6 to ETH_ALEN
Date: Thu,  1 Aug 2013 16:17:49 -0700
Message-ID: <9ab1185f349544b160632bfec566391928fa0768.1375398692.git.joe@perches.com>
References: <20130801.143137.331385226409040561.davem@davemloft.net>
Cc: Don Fry <pcnet32@frontier.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Sam Creasey <sammy@sammy.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Olof Johansson <olof@lixom.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38054 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757689Ab3HAXSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 19:18:33 -0400
In-Reply-To: <20130801.143137.331385226409040561.davem@davemloft.net>
In-Reply-To: <cover.1375398692.git.joe@perches.com>
References: <cover.1375398692.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal #define to help grep find mac addresses
and ensure that addresses are aligned.

pasemi.h has an unaligned access to mac_addr, unchanged
for now.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/8390/ax88796.c                |  4 ++--
 drivers/net/ethernet/amd/pcnet32.c                 |  6 +++---
 drivers/net/ethernet/broadcom/cnic_if.h            |  6 +++---
 drivers/net/ethernet/dec/tulip/tulip_core.c        |  8 +++++---
 drivers/net/ethernet/i825xx/sun3_82586.h           |  4 ++--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |  4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           | 13 +++++++------
 drivers/net/ethernet/pasemi/pasemi_mac.h           |  2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |  4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge.h            |  2 +-
 11 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index e1d2643..b7232a9 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -707,7 +707,7 @@ static int ax_init_dev(struct net_device *dev)
 
 #ifdef CONFIG_AX88796_93CX6
 	if (ax->plat->flags & AXFLG_HAS_93CX6) {
-		unsigned char mac_addr[6];
+		unsigned char mac_addr[ETH_ALEN];
 		struct eeprom_93cx6 eeprom;
 
 		eeprom.data = ei_local;
@@ -719,7 +719,7 @@ static int ax_init_dev(struct net_device *dev)
 				       (__le16 __force *)mac_addr,
 				       sizeof(mac_addr) >> 1);
 
-		memcpy(dev->dev_addr, mac_addr, 6);
+		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
 	}
 #endif
 	if (ax->plat->wordlength == 2) {
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index ed21307..2d8e288 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1521,7 +1521,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	char *chipname;
 	struct net_device *dev;
 	const struct pcnet32_access *a = NULL;
-	u8 promaddr[6];
+	u8 promaddr[ETH_ALEN];
 	int ret = -ENODEV;
 
 	/* reset the chip */
@@ -1665,10 +1665,10 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 
 	/* read PROM address and compare with CSR address */
-	for (i = 0; i < 6; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		promaddr[i] = inb(ioaddr + i);
 
-	if (memcmp(promaddr, dev->dev_addr, 6) ||
+	if (memcmp(promaddr, dev->dev_addr, ETH_ALEN) ||
 	    !is_valid_ether_addr(dev->dev_addr)) {
 		if (is_valid_ether_addr(promaddr)) {
 			if (pcnet32_debug & NETIF_MSG_PROBE) {
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 82a0312..95aff76 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -238,8 +238,8 @@ struct cnic_sock {
 	u16	src_port;
 	u16	dst_port;
 	u16	vlan_id;
-	unsigned char old_ha[6];
-	unsigned char ha[6];
+	unsigned char old_ha[ETH_ALEN];
+	unsigned char ha[ETH_ALEN];
 	u32	mtu;
 	u32	cid;
 	u32	l5_cid;
@@ -308,7 +308,7 @@ struct cnic_dev {
 #define CNIC_F_BNX2_CLASS	3
 #define CNIC_F_BNX2X_CLASS	4
 	atomic_t	ref_count;
-	u8		mac_addr[6];
+	u8		mac_addr[ETH_ALEN];
 
 	int		max_iscsi_conn;
 	int		max_fcoe_conn;
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index c94152f..4e8cfa2 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1304,7 +1304,9 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct tulip_private *tp;
 	/* See note below on the multiport cards. */
-	static unsigned char last_phys_addr[6] = {0x00, 'L', 'i', 'n', 'u', 'x'};
+	static unsigned char last_phys_addr[ETH_ALEN] = {
+		0x00, 'L', 'i', 'n', 'u', 'x'
+	};
 	static int last_irq;
 	static int multiport_cnt;	/* For four-port boards w/one EEPROM */
 	int i, irq;
@@ -1627,8 +1629,8 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->dev_addr[i] = last_phys_addr[i] + 1;
 #if defined(CONFIG_SPARC)
 		addr = of_get_property(dp, "local-mac-address", &len);
-		if (addr && len == 6)
-			memcpy(dev->dev_addr, addr, 6);
+		if (addr && len == ETH_ALEN)
+			memcpy(dev->dev_addr, addr, ETH_ALEN);
 #endif
 #if defined(__i386__) || defined(__x86_64__)	/* Patch up x86 BIOS bug. */
 		if (last_irq)
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.h b/drivers/net/ethernet/i825xx/sun3_82586.h
index 93346f0..79aef68 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.h
+++ b/drivers/net/ethernet/i825xx/sun3_82586.h
@@ -133,8 +133,8 @@ struct rfd_struct
   unsigned char  last;		/* Bit15,Last Frame on List / Bit14,suspend */
   unsigned short next;		/* linkoffset to next RFD */
   unsigned short rbd_offset;	/* pointeroffset to RBD-buffer */
-  unsigned char  dest[6];	/* ethernet-address, destination */
-  unsigned char  source[6];	/* ethernet-address, source */
+  unsigned char  dest[ETH_ALEN];	/* ethernet-address, destination */
+  unsigned char  source[ETH_ALEN];	/* ethernet-address, source */
   unsigned short length;	/* 802.3 frame-length */
   unsigned short zero_dummy;	/* dummy */
 };
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 967bae8..d4cdf4d 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -244,7 +244,7 @@ struct myri10ge_priv {
 	int fw_ver_minor;
 	int fw_ver_tiny;
 	int adopted_rx_filter_bug;
-	u8 mac_addr[6];		/* eeprom mac address */
+	u8 mac_addr[ETH_ALEN];		/* eeprom mac address */
 	unsigned long serial_number;
 	int vendor_specific_offset;
 	int fw_multicast_support;
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index e88bdb1..dcfe58f 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -922,7 +922,7 @@ static void __init get_mac_address(struct net_device *dev)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
 	struct platform_device *pdev;
-	char addr[6];
+	char addr[ETH_ALEN];
 
 	pdev = ether->pdev;
 
@@ -934,7 +934,7 @@ static void __init get_mac_address(struct net_device *dev)
 	addr[5] = 0xa8;
 
 	if (is_valid_ether_addr(addr))
-		memcpy(dev->dev_addr, &addr, 0x06);
+		memcpy(dev->dev_addr, &addr, ETH_ALEN);
 	else
 		dev_err(&pdev->dev, "invalid mac address\n");
 }
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index a5f0b5d..f21ae7b 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -191,7 +191,7 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 	struct device_node *dn = pci_device_to_OF_node(pdev);
 	int len;
 	const u8 *maddr;
-	u8 addr[6];
+	u8 addr[ETH_ALEN];
 
 	if (!dn) {
 		dev_dbg(&pdev->dev,
@@ -201,8 +201,8 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 
 	maddr = of_get_property(dn, "local-mac-address", &len);
 
-	if (maddr && len == 6) {
-		memcpy(mac->mac_addr, maddr, 6);
+	if (maddr && len == ETH_ALEN) {
+		memcpy(mac->mac_addr, maddr, ETH_ALEN);
 		return 0;
 	}
 
@@ -219,14 +219,15 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -ENOENT;
 	}
 
-	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
-		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
+	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		   &addr[0], &addr[1], &addr[2], &addr[3], &addr[4], &addr[5])
+	    != ETH_ALEN) {
 		dev_warn(&pdev->dev,
 			 "can't parse mac address, not configuring\n");
 		return -EINVAL;
 	}
 
-	memcpy(mac->mac_addr, addr, 6);
+	memcpy(mac->mac_addr, addr, ETH_ALEN);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
index e2f4efa..f2749d4 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.h
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.h
@@ -83,7 +83,7 @@ struct pasemi_mac {
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
 
-	u8		mac_addr[6];
+	u8		mac_addr[ETH_ALEN];
 
 	struct net_lro_mgr	lro_mgr;
 	struct net_lro_desc	lro_desc[MAX_LRO_DESCRIPTORS];
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 9fbb1cd..8375cbd 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -536,10 +536,10 @@ static void netxen_p2_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
-	u8 null_addr[6];
+	u8 null_addr[ETH_ALEN];
 	int i;
 
-	memset(null_addr, 0, 6);
+	memset(null_addr, 0, ETH_ALEN);
 
 	if (netdev->flags & IFF_PROMISC) {
 
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index 7e8d682..8994337 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -2149,7 +2149,7 @@ struct ql_adapter {
 	struct timer_list timer;
 	atomic_t lb_count;
 	/* Keep local copy of current mac address. */
-	char current_mac_addr[6];
+	char current_mac_addr[ETH_ALEN];
 };
 
 /*
-- 
1.8.1.2.459.gbcd45b4.dirty
