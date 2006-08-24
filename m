From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: minor fixes and cleanups
Date: Thu, 24 Aug 2006 22:43:24 +0200
Message-ID: <200608242243.24936.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:20652
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422649AbWHXUnw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 16:43:52 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev

--

Minor fixes and cleanups to the ssb driver.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/misc/ssb.c
===================================================================
--- wireless-dev.orig/drivers/misc/ssb.c	2006-08-24 22:18:03.000000000 +0200
+++ wireless-dev/drivers/misc/ssb.c	2006-08-24 22:33:44.000000000 +0200
@@ -518,7 +518,8 @@
 {
 	int err;
 
-	if (!ssb || !pci_dev || !device_suspend || !device_resume)
+	if (!ssb || !pci_dev || !mmio ||
+	    !device_suspend || !device_resume)
 		return -EINVAL;
 
 	memset(ssb, 0, sizeof(*ssb));
@@ -551,9 +552,9 @@
 	list_del(&ssb->list);
 	mutex_unlock(&ssb_list_mutex);
 
+	mutex_destroy(&ssb->suspend_mutex);
+	mutex_destroy(&ssb->mutex);
 	kfree(ssb->cores);
-	if (SSB_DEBUG)
-		memset(ssb, 0x5B, sizeof(*ssb));
 }
 EXPORT_SYMBOL_GPL(ssb_exit);
 
@@ -592,8 +593,8 @@
 	return -ENODEV;
 }
 
-int ssb_switch_core_locked(struct ssb *ssb,
-			   struct ssb_core *new_core)
+static int ssb_switch_core_locked(struct ssb *ssb,
+				  struct ssb_core *new_core)
 {
 	int err = 0;
 
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- wireless-dev.orig/include/linux/ssb.h	2006-08-24 22:18:03.000000000 +0200
+++ wireless-dev/include/linux/ssb.h	2006-08-24 22:28:03.000000000 +0200
@@ -170,7 +170,7 @@
 #define SSB_SPROM2_BFLHI		0x1038	/* Boardflags (high 16 bits) */
 #define SSB_SPROM2_MAXP_A		0x103A	/* A-PHY Max Power */
 #define  SSB_SPROM2_MAXP_A_HI		0x00FF	/* Max Power High */
-#define  SSB_SPROM2_MAXP_A_LO		0x1100	/* Max Power Low */
+#define  SSB_SPROM2_MAXP_A_LO		0xFF00	/* Max Power Low */
 #define  SSB_SPROM2_MAXP_A_LO_SHIFT	8
 #define SSB_SPROM2_PA1LOB0		0x103C	/* A-PHY PowerAmplifier Low Settings */
 #define SSB_SPROM2_PA1LOB1		0x103E	/* A-PHY PowerAmplifier Low Settings */


-- 
Greetings Michael.
