From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/5] ethernet: Convert ETHER_ADDR_LEN uses to ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:03 -0800
Message-ID: <3457a90f6af6da7fd0bd5138e0dcb7a1197425d3.1321472143.git.joe@perches.com>
References: <cover.1321472142.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of #defines, use the normal #define from if_ether.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/8390/8390.h           |    2 --
 drivers/net/ethernet/8390/apne.c           |    2 +-
 drivers/net/ethernet/8390/ax88796.c        |    5 ++---
 drivers/net/ethernet/8390/es3210.c         |    2 +-
 drivers/net/ethernet/8390/hp-plus.c        |    2 +-
 drivers/net/ethernet/8390/hp.c             |    2 +-
 drivers/net/ethernet/8390/hydra.c          |    2 +-
 drivers/net/ethernet/8390/lne390.c         |    4 ++--
 drivers/net/ethernet/8390/ne-h8300.c       |    2 +-
 drivers/net/ethernet/8390/ne.c             |    4 ++--
 drivers/net/ethernet/8390/ne2.c            |    2 +-
 drivers/net/ethernet/8390/ne3210.c         |    2 +-
 drivers/net/ethernet/8390/stnic.c          |    2 +-
 drivers/net/ethernet/8390/zorro8390.c      |    2 +-
 drivers/net/ethernet/amd/nmclan_cs.c       |   12 +++++-------
 drivers/net/ethernet/broadcom/sb1250-mac.c |    3 +--
 16 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/8390/8390.h b/drivers/net/ethernet/8390/8390.h
index 58a12e4..ef325ff 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -14,8 +14,6 @@
 
 #define TX_PAGES 12	/* Two Tx slots */
 
-#define ETHER_ADDR_LEN 6
-
 /* The 8390 specific per-packet-header format. */
 struct e8390_pkt_hdr {
   unsigned char status; /* status */
diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
index 5477373..3ad5d2f 100644
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -318,7 +318,7 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
     i = request_irq(dev->irq, apne_interrupt, IRQF_SHARED, DRV_NAME, dev);
     if (i) return i;
 
-    for(i = 0; i < ETHER_ADDR_LEN; i++)
+    for (i = 0; i < ETH_ALEN; i++)
 	dev->dev_addr[i] = SA_prom[i];
 
     printk(" %pM\n", dev->dev_addr);
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index e9f8432..2a3b8c2 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -735,15 +735,14 @@ static int ax_init_dev(struct net_device *dev)
 	if (ax->plat->flags & AXFLG_MAC_FROMDEV) {
 		ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
 			ei_local->mem + E8390_CMD); /* 0x61 */
-		for (i = 0; i < ETHER_ADDR_LEN; i++)
+		for (i = 0; i < ETH_ALEN; i++)
 			dev->dev_addr[i] =
 				ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
 	}
 
 	if ((ax->plat->flags & AXFLG_MAC_FROMPLATFORM) &&
 	    ax->plat->mac_addr)
-		memcpy(dev->dev_addr, ax->plat->mac_addr,
-		       ETHER_ADDR_LEN);
+		memcpy(dev->dev_addr, ax->plat->mac_addr, ETH_ALEN);
 
 	ax_reset_8390(dev);
 
diff --git a/drivers/net/ethernet/8390/es3210.c b/drivers/net/ethernet/8390/es3210.c
index 7a09575..6428f9e 100644
--- a/drivers/net/ethernet/8390/es3210.c
+++ b/drivers/net/ethernet/8390/es3210.c
@@ -195,7 +195,7 @@ static int __init es_probe1(struct net_device *dev, int ioaddr)
 		goto out;
 	}
 
-	for (i = 0; i < ETHER_ADDR_LEN ; i++)
+	for (i = 0; i < ETH_ALEN ; i++)
 		dev->dev_addr[i] = inb(ioaddr + ES_SA_PROM + i);
 
 /*	Check the Racal vendor ID as well. */
diff --git a/drivers/net/ethernet/8390/hp-plus.c b/drivers/net/ethernet/8390/hp-plus.c
index eeac843..d42938b 100644
--- a/drivers/net/ethernet/8390/hp-plus.c
+++ b/drivers/net/ethernet/8390/hp-plus.c
@@ -202,7 +202,7 @@ static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 	/* Retrieve and checksum the station address. */
 	outw(MAC_Page, ioaddr + HP_PAGING);
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
+	for(i = 0; i < ETH_ALEN; i++) {
 		unsigned char inval = inb(ioaddr + 8 + i);
 		dev->dev_addr[i] = inval;
 		checksum += inval;
diff --git a/drivers/net/ethernet/8390/hp.c b/drivers/net/ethernet/8390/hp.c
index 18564d4..113f1e0 100644
--- a/drivers/net/ethernet/8390/hp.c
+++ b/drivers/net/ethernet/8390/hp.c
@@ -156,7 +156,7 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 
 	printk("%s: %s (ID %02x) at %#3x,", dev->name, name, board_id, ioaddr);
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
+	for(i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
 
 	printk(" %pM", dev->dev_addr);
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 3dac937..5370c88 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -129,7 +129,7 @@ static int __devinit hydra_init(struct zorro_dev *z)
     if (!dev)
 	return -ENOMEM;
 
-    for(j = 0; j < ETHER_ADDR_LEN; j++)
+    for (j = 0; j < ETH_ALEN; j++)
 	dev->dev_addr[j] = *((u8 *)(board + HYDRA_ADDRPROM + 2*j));
 
     /* We must set the 8390 for word mode. */
diff --git a/drivers/net/ethernet/8390/lne390.c b/drivers/net/ethernet/8390/lne390.c
index f9888d2..69490ae 100644
--- a/drivers/net/ethernet/8390/lne390.c
+++ b/drivers/net/ethernet/8390/lne390.c
@@ -191,14 +191,14 @@ static int __init lne390_probe1(struct net_device *dev, int ioaddr)
 		|| inb(ioaddr + LNE390_SA_PROM + 1) != LNE390_ADDR1
 		|| inb(ioaddr + LNE390_SA_PROM + 2) != LNE390_ADDR2 ) {
 		printk("lne390.c: card not found");
-		for(i = 0; i < ETHER_ADDR_LEN; i++)
+		for (i = 0; i < ETH_ALEN; i++)
 			printk(" %02x", inb(ioaddr + LNE390_SA_PROM + i));
 		printk(" (invalid prefix).\n");
 		return -ENODEV;
 	}
 #endif
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + LNE390_SA_PROM + i);
 	printk("lne390.c: LNE390%X in EISA slot %d, address %pM.\n",
 	       0xa+revision, ioaddr/0x1000, dev->dev_addr);
diff --git a/drivers/net/ethernet/8390/ne-h8300.c b/drivers/net/ethernet/8390/ne-h8300.c
index cd36a6a..9b9c77d 100644
--- a/drivers/net/ethernet/8390/ne-h8300.c
+++ b/drivers/net/ethernet/8390/ne-h8300.c
@@ -312,7 +312,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 
 	dev->base_addr = ioaddr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
 	printk(" %pM\n", dev->dev_addr);
 
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index 1063093..f92ea2a 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -503,12 +503,12 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 #ifdef CONFIG_PLAT_MAPPI
 	outb_p(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
 		ioaddr + E8390_CMD); /* 0x61 */
-	for (i = 0 ; i < ETHER_ADDR_LEN ; i++) {
+	for (i = 0; i < ETH_ALEN; i++) {
 		dev->dev_addr[i] = SA_prom[i]
 			= inb_p(ioaddr + EN1_PHYS_SHIFT(i));
 	}
 #else
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
+	for (i = 0; i < ETH_ALEN; i++) {
 		dev->dev_addr[i] = SA_prom[i];
 	}
 #endif
diff --git a/drivers/net/ethernet/8390/ne2.c b/drivers/net/ethernet/8390/ne2.c
index 70cdc69..922b320 100644
--- a/drivers/net/ethernet/8390/ne2.c
+++ b/drivers/net/ethernet/8390/ne2.c
@@ -460,7 +460,7 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 
 	dev->base_addr = base_addr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
 
 	printk(" %pM\n", dev->dev_addr);
diff --git a/drivers/net/ethernet/8390/ne3210.c b/drivers/net/ethernet/8390/ne3210.c
index 243ed2a..2a3e805 100644
--- a/drivers/net/ethernet/8390/ne3210.c
+++ b/drivers/net/ethernet/8390/ne3210.c
@@ -125,7 +125,7 @@ static int __init ne3210_eisa_probe (struct device *device)
 #endif
 
 	port_index = inb(ioaddr + NE3210_CFG2) >> 6;
-	for(i = 0; i < ETHER_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + NE3210_SA_PROM + i);
 	printk("ne3210.c: NE3210 in EISA slot %d, media: %s, addr: %pM.\n",
 		edev->slot, ifmap[port_index], dev->dev_addr);
diff --git a/drivers/net/ethernet/8390/stnic.c b/drivers/net/ethernet/8390/stnic.c
index d85f0a8..3b90375 100644
--- a/drivers/net/ethernet/8390/stnic.c
+++ b/drivers/net/ethernet/8390/stnic.c
@@ -114,7 +114,7 @@ static int __init stnic_probe(void)
 #ifdef CONFIG_SH_STANDARD_BIOS
   sh_bios_get_node_addr (stnic_eadr);
 #endif
-  for (i = 0; i < ETHER_ADDR_LEN; i++)
+  for (i = 0; i < ETH_ALEN; i++)
     dev->dev_addr[i] = stnic_eadr[i];
 
   /* Set the base address to point to the NIC, not the "real" base! */
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 3aa9fe9..bcd2732 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -365,7 +365,7 @@ static int __devinit zorro8390_init(struct net_device *dev,
 	if (i)
 		return i;
 
-	for (i = 0; i < ETHER_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
 
 	pr_debug("Found ethernet address: %pM\n", dev->dev_addr);
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 3accd5d..25f4862 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -160,8 +160,6 @@ Include Files
 Defines
 ---------------------------------------------------------------------------- */
 
-#define ETHER_ADDR_LEN			ETH_ALEN
-					/* 6 bytes in an Ethernet Address */
 #define MACE_LADRF_LEN			8
 					/* 8 bytes in Logical Address Filter */
 
@@ -600,7 +598,7 @@ static int mace_init(mace_private *lp, unsigned int ioaddr, char *enet_addr)
   	}
   }
   /* Set PADR register */
-  for (i = 0; i < ETHER_ADDR_LEN; i++)
+  for (i = 0; i < ETH_ALEN; i++)
     mace_write(lp, ioaddr, MACE_PADR, enet_addr[i]);
 
   /* MAC Configuration Control Register should be written last */
@@ -639,11 +637,11 @@ static int nmclan_config(struct pcmcia_device *link)
 
   /* Read the ethernet address from the CIS. */
   len = pcmcia_get_tuple(link, 0x80, &buf);
-  if (!buf || len < ETHER_ADDR_LEN) {
+  if (!buf || len < ETH_ALEN) {
 	  kfree(buf);
 	  goto failed;
   }
-  memcpy(dev->dev_addr, buf, ETHER_ADDR_LEN);
+  memcpy(dev->dev_addr, buf, ETH_ALEN);
   kfree(buf);
 
   /* Verify configuration by reading the MACE ID. */
@@ -1420,7 +1418,7 @@ Output
 static void set_multicast_list(struct net_device *dev)
 {
   mace_private *lp = netdev_priv(dev);
-  int adr[ETHER_ADDR_LEN] = {0}; /* Ethernet address */
+  int adr[ETH_ALEN] = {0}; /* Ethernet address */
   struct netdev_hw_addr *ha;
 
 #ifdef PCMCIA_DEBUG
@@ -1442,7 +1440,7 @@ static void set_multicast_list(struct net_device *dev)
     /* Calculate multicast logical address filter */
     memset(lp->multicast_ladrf, 0, MACE_LADRF_LEN);
     netdev_for_each_mc_addr(ha, dev) {
-      memcpy(adr, ha->addr, ETHER_ADDR_LEN);
+      memcpy(adr, ha->addr, ETH_ALEN);
       BuildLAF(lp->multicast_ladrf, adr);
     }
   }
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 0a1d7f2..aa58f9e 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -163,7 +163,6 @@ enum sbmac_state {
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
 
-#define ETHER_ADDR_LEN		6
 #define ENET_PACKET_SIZE	1518
 /*#define ENET_PACKET_SIZE	9216 */
 
@@ -266,7 +265,7 @@ struct sbmac_softc {
 	int			sbm_pause;	/* current pause setting */
 	int			sbm_link;	/* current link state */
 
-	unsigned char		sbm_hwaddr[ETHER_ADDR_LEN];
+	unsigned char		sbm_hwaddr[ETH_ALEN];
 
 	struct sbmacdma		sbm_txdma;	/* only channel 0 for now */
 	struct sbmacdma		sbm_rxdma;
-- 
1.7.6.405.gc1be0
