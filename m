From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/4] tulip: Use pr_<level> where appropriate
Date: Mon,  9 May 2011 12:45:23 -0700
Message-ID: <76d02bec193a5a7558aa7d6e97282ae2bec67f0b.1304970062.git.joe@perches.com>
References: <cover.1304970062.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304970062.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging styles.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/de2104x.c     |    6 +++---
 drivers/net/tulip/dmfe.c        |    7 +++----
 drivers/net/tulip/tulip_core.c  |    5 +++--
 drivers/net/tulip/uli526x.c     |   23 ++++-------------------
 drivers/net/tulip/winbond-840.c |    2 +-
 5 files changed, 14 insertions(+), 29 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index e925c1e..e2f6923 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -53,7 +53,7 @@
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
-KERN_INFO DRV_NAME " PCI Ethernet driver v" DRV_VERSION " (" DRV_RELDATE ")\n";
+"PCI Ethernet driver v" DRV_VERSION " (" DRV_RELDATE ")";
 
 MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
 MODULE_DESCRIPTION("Intel/Digital 21040/1 series PCI Ethernet driver");
@@ -1978,7 +1978,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 
 #ifndef MODULE
 	if (board_idx == 0)
-		printk("%s", version);
+		pr_info("%s\n", version);
 #endif
 
 	/* allocate a new ethernet device structure, and fill in defaults */
@@ -2200,7 +2200,7 @@ static struct pci_driver de_driver = {
 static int __init de_init (void)
 {
 #ifdef MODULE
-	printk("%s", version);
+	pr_info("%s\n", version);
 #endif
 	return pci_register_driver(&de_driver);
 }
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 96e8541..4685127 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -295,8 +295,7 @@ enum dmfe_CR6_bits {
 /* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
 static const char version[] __devinitconst =
-	KERN_INFO DRV_NAME ": Davicom DM9xxx net driver, version "
-	DRV_VERSION " (" DRV_RELDATE ")\n";
+	"Davicom DM9xxx net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
 static int dmfe_debug;
 static unsigned char dmfe_media_mode = DMFE_AUTO;
@@ -381,7 +380,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	DMFE_DBUG(0, "dmfe_init_one()", 0);
 
 	if (!printed_version++)
-		printk(version);
+		pr_info("%s\n", version);
 
 	/*
 	 *	SPARC on-board DM910x chips should be handled by the main
@@ -2203,7 +2202,7 @@ static int __init dmfe_init_module(void)
 {
 	int rc;
 
-	printk(version);
+	pr_info("%s\n", version);
 	printed_version = 1;
 
 	DMFE_DBUG(0, "init_module() ", debug);
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index ebc8058..82f8764 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1478,7 +1478,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		if (sig == 0x09811317) {
 			tp->flags |= COMET_PM;
 			tp->wolinfo.supported = WAKE_PHY | WAKE_MAGIC;
-			printk(KERN_INFO "tulip_init_one: Enabled WOL support for AN983B\n");
+			pr_info("%s: Enabled WOL support for AN983B\n",
+				__func__);
 		}
 	}
 	tp->pdev = pdev;
@@ -1874,7 +1875,7 @@ save_state:
 		tulip_set_wolopts(pdev, tp->wolinfo.wolopts);
 		rc = pci_enable_wake(pdev, pstate, tp->wolinfo.wolopts);
 		if (rc)
-			printk("tulip: pci_enable_wake failed (%d)\n", rc);
+			pr_err("pci_enable_wake failed (%d)\n", rc);
 	}
 	pci_set_power_state(pdev, pstate);
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 92c00ee..9e63f40 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -209,8 +209,7 @@ enum uli526x_CR6_bits {
 /* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
 static const char version[] __devinitconst =
-	KERN_INFO DRV_NAME ": ULi M5261/M5263 net driver, version "
-	DRV_VERSION " (" DRV_RELDATE ")\n";
+	"ULi M5261/M5263 net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
 static int uli526x_debug;
 static unsigned char uli526x_media_mode = ULI526X_AUTO;
@@ -283,7 +282,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	ULI526X_DBUG(0, "uli526x_init_one()", 0);
 
 	if (!printed_version++)
-		printk(version);
+		pr_info("%s\n", version);
 
 	/* Init network device */
 	dev = alloc_etherdev(sizeof(*db));
@@ -667,15 +666,6 @@ static int uli526x_stop(struct net_device *dev)
 	/* free allocated rx buffer */
 	uli526x_free_rxbuffer(db);
 
-#if 0
-	/* show statistic counter */
-	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
-		db->tx_fifo_underrun, db->tx_excessive_collision,
-		db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
-		db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
-		db->reset_fatal, db->reset_TXtimeout);
-#endif
-
 	return 0;
 }
 
@@ -755,7 +745,6 @@ static void uli526x_free_tx_pkt(struct net_device *dev,
 	txptr = db->tx_remove_ptr;
 	while(db->tx_packet_cnt) {
 		tdes0 = le32_to_cpu(txptr->tdes0);
-		/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
 		if (tdes0 & 0x80000000)
 			break;
 
@@ -765,7 +754,6 @@ static void uli526x_free_tx_pkt(struct net_device *dev,
 
 		/* Transmit statistic counter */
 		if ( tdes0 != 0x7fffffff ) {
-			/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
 			dev->stats.collisions += (tdes0 >> 3) & 0xf;
 			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
 			if (tdes0 & TDES0_ERR_MASK) {
@@ -838,7 +826,6 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 			/* error summary bit check */
 			if (rdes0 & 0x8000) {
 				/* This is a error packet */
-				//printk(DRV_NAME ": rdes0: %lx\n", rdes0);
 				dev->stats.rx_errors++;
 				if (rdes0 & 1)
 					dev->stats.rx_fifo_errors++;
@@ -1046,8 +1033,7 @@ static void uli526x_timer(unsigned long data)
 		if ( time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
 			db->reset_TXtimeout++;
 			db->wait_reset = 1;
-			printk( "%s: Tx timeout - resetting\n",
-			       dev->name);
+			netdev_err(dev, " Tx timeout - resetting\n");
 		}
 	}
 
@@ -1534,7 +1520,6 @@ static u8 uli526x_sense_speed(struct uli526x_board_info * db)
 		else
 			phy_mode = 0x1000;
 
-		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = ULI526X_10MHF; break;
 		case 0x2000: db->op_mode = ULI526X_10MFD; break;
@@ -1823,7 +1808,7 @@ MODULE_PARM_DESC(mode, "ULi M5261/M5263: Bit 0: 10/100Mbps, bit 2: duplex, bit 8
 static int __init uli526x_init_module(void)
 {
 
-	printk(version);
+	pr_info("%s\n", version);
 	printed_version = 1;
 
 	ULI526X_DBUG(0, "init_module() ", debug);
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 64e3f01..862eadf 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -141,7 +141,7 @@ static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
 /* These identify the driver base version and may not be removed. */
 static const char version[] __initconst =
-	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " (2.4 port) "
+	"v" DRV_VERSION " (2.4 port) "
 	DRV_RELDATE "  Donald Becker <becker@scyld.com>\n"
 	"  http://www.scyld.com/network/drivers.html\n";
 
-- 
1.7.5.rc3.dirty
