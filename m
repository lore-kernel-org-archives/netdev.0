From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6] missing setup for National DP83840 PHY rev b/c
Date: Sun, 7 Mar 2004 00:40:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403070032220.14871-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add National DP83840 PHY rev b/c setup.  Only rev a was being setup.

-------------

--- linux-2.5/drivers/net/e100.c	2004-03-04 09:30:03.000000000 -0800
+++ linux-2.5/drivers/net/e100.c.mod	2004-03-04 09:30:48.000000000 -0800
@@ -158,7 +158,7 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.15"
+#define DRV_VERSION		"3.0.16"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1032,8 +1032,9 @@ static int e100_phy_init(struct nic *nic
 	nic->phy = (u32)id_hi << 16 | (u32)id_lo;
 	DPRINTK(HW, DEBUG, "phy ID = 0x%08X\n", nic->phy);
 
-	/* Handle National tx phy */
-	if(nic->phy == phy_nsc_tx) {
+	/* Handle National tx phys */
+#define NCS_PHY_MODEL_MASK	0xFFF0FFFF
+	if((nic->phy & NCS_PHY_MODEL_MASK) == phy_nsc_tx) {
 		/* Disable congestion control */
 		cong = mdio_read(netdev, nic->mii.phy_id, MII_NSC_CONG);
 		cong |= NSC_CONG_TXREADY;
