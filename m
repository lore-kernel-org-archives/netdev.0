From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead of
	hardcoded schedule_timeout()s
Date: Tue, 26 Oct 2004 14:33:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098815604.3663.35.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Use msleep() instead of hardcoded schedule_timeout()s
  (Nishanth Aravamudan via kernel-janitors list).

--- a/drivers/net/wireless/airport.c.1-msleep	2004-10-25 14:44:04.559958488 -0400
+++ b/drivers/net/wireless/airport.c	2004-10-25 14:44:51.372841848 -0400
@@ -28,7 +28,6 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/delay.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
@@ -147,7 +146,7 @@
 	macio_release_resource(mdev, 0);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 0);
-	ssleep(1);
+	msleep(1000);
 
 	macio_set_drvdata(mdev, NULL);
 	free_netdev(dev);
@@ -173,12 +172,12 @@
 	disable_irq(dev->irq);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(card->mdev), 0, 0);
-	ssleep(1);
+	msleep(1000);
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(card->mdev), 0, 1);
-	ssleep(1);
+	msleep(1000);
 
 	enable_irq(dev->irq);
-	ssleep(1);
+	msleep(1000);
 #endif
 
 	return 0;
@@ -237,7 +236,7 @@
 		
 	/* Power up card */
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 1);
-	ssleep(1);
+	msleep(1000);
 
 	/* Reset it before we get the interrupt */
 	hermes_init(hw);
--- a/drivers/net/wireless/orinoco_cs.c.1-msleep	2004-10-25 14:44:04.558958640 -0400
+++ b/drivers/net/wireless/orinoco_cs.c	2004-10-25 14:44:51.374841544 -0400
@@ -136,6 +136,7 @@
 	if (err)
 		return err;
 
+	msleep(100);
 	clear_bit(0, &card->hard_reset_in_progress);
 
 	return 0;
--- a/drivers/net/wireless/orinoco_plx.c.1-msleep	2004-10-25 14:44:04.559958488 -0400
+++ b/drivers/net/wireless/orinoco_plx.c	2004-10-25 14:44:51.376841240 -0400
@@ -352,8 +352,7 @@
 static void __exit orinoco_plx_exit(void)
 {
 	pci_unregister_driver(&orinoco_plx_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	msleep(1000);
 }
 
 module_init(orinoco_plx_init);
--- a/drivers/net/wireless/orinoco_tmd.c.1-msleep	2004-10-25 14:44:04.557958792 -0400
+++ b/drivers/net/wireless/orinoco_tmd.c	2004-10-25 14:44:51.377841088 -0400
@@ -218,8 +218,7 @@
 static void __exit orinoco_tmd_exit(void)
 {
 	pci_unregister_driver(&orinoco_tmd_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	msleep(1000);
 }
 
 module_init(orinoco_tmd_init);
