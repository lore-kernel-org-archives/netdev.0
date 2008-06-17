From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 1/6] atm: [iphase] move struct suni_priv to suni.h
Date: Tue, 17 Jun 2008 09:16:01 -0400
Message-ID: <200806171316.m5HDG1Qf005858@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53835 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756415AbYFQNQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:16:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ebdfa622e6dc476634184cc3543fa05d3204ef57
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Sat Jun 14 17:17:07 2008 -0400

    atm: [iphase] move struct suni_priv to suni.h
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 800c09e..1925915 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -65,12 +65,7 @@
 #include "iphase.h"		  
 #include "suni.h"		  
 #define swap(x) (((x & 0xff) << 8) | ((x & 0xff00) >> 8))  
-struct suni_priv {
-        struct k_sonet_stats sonet_stats; /* link diagnostics */
-        unsigned char loop_mode;        /* loopback mode */
-        struct atm_dev *dev;            /* device back-pointer */
-        struct suni_priv *next;         /* next SUNI */
-}; 
+
 #define PRIV(dev) ((struct suni_priv *) dev->phy_data)
 
 static unsigned char ia_phy_get(struct atm_dev *dev, unsigned long addr);
diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index b1d063c..6097f68 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -29,15 +29,6 @@
 #define DPRINTK(format,args...)
 #endif
 
-
-struct suni_priv {
-	struct k_sonet_stats sonet_stats; /* link diagnostics */
-	int loop_mode;			/* loopback mode */
-	struct atm_dev *dev;		/* device back-pointer */
-	struct suni_priv *next;		/* next SUNI */
-};
-
-
 #define PRIV(dev) ((struct suni_priv *) dev->phy_data)
 
 #define PUT(val,reg) dev->ops->phy_put(dev,val,SUNI_##reg)
diff --git a/drivers/atm/suni.h b/drivers/atm/suni.h
index d14c835..efa79bf 100644
--- a/drivers/atm/suni.h
+++ b/drivers/atm/suni.h
@@ -8,7 +8,7 @@
 
 #include <linux/atmdev.h>
 #include <linux/atmioc.h>
-
+#include <linux/sonet.h>
 
 /* SUNI registers */
 
@@ -205,6 +205,13 @@
 
 
 #ifdef __KERNEL__
+struct suni_priv {
+	struct k_sonet_stats sonet_stats;	/* link diagnostics */
+	int loop_mode;				/* loopback mode */
+	struct atm_dev *dev;			/* device back-pointer */
+	struct suni_priv *next;			/* next SUNI */
+};
+
 int suni_init(struct atm_dev *dev);
 #endif
 
