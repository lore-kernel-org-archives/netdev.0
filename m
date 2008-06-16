From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 4/7] atm: [he] only support suni driver on multimode interfaces
Date: Mon, 16 Jun 2008 13:27:33 -0400
Message-ID: <200806161727.m5GHRXLQ003365@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45511 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbYFPR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:27:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fc32b94f2117fcd23f3e36a6d2109ef572caee29
Author: Chas Williams <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jun 14 17:26:51 2008 -0400

    atm: [he] only support suni driver on multimode interfaces
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index ffc4a5a..320320e 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1542,7 +1542,8 @@ he_start(struct atm_dev *dev)
 	/* initialize framer */
 
 #ifdef CONFIG_ATM_HE_USE_SUNI
-	suni_init(he_dev->atm_dev);
+	if (he_isMM(he_dev))
+		suni_init(he_dev->atm_dev);
 	if (he_dev->atm_dev->phy && he_dev->atm_dev->phy->start)
 		he_dev->atm_dev->phy->start(he_dev->atm_dev);
 #endif /* CONFIG_ATM_HE_USE_SUNI */
diff --git a/drivers/atm/he.h b/drivers/atm/he.h
index fe6cd15..a54d64f 100644
--- a/drivers/atm/he.h
+++ b/drivers/atm/he.h
@@ -267,13 +267,7 @@ struct he_dev {
 
 	char prod_id[30];
 	char mac_addr[6];
-	int media;			/*  
-					 *  0x26 = HE155 MM 
-					 *  0x27 = HE622 MM 
-					 *  0x46 = HE155 SM 
-					 *  0x47 = HE622 SM 
-					 */
-
+	int media;			
 
 	unsigned int vcibits, vpibits;
 	unsigned int cells_per_row;
@@ -392,6 +386,7 @@ struct he_vcc
 #define HE_DEV(dev) ((struct he_dev *) (dev)->dev_data)
 
 #define he_is622(dev)	((dev)->media & 0x1)
+#define he_isMM(dev)	((dev)->media & 0x20)
 
 #define HE_REGMAP_SIZE	0x100000
 
@@ -876,8 +871,8 @@ struct he_vcc
 #define M_SN		0x3a	/* integer */
 #define MEDIA		0x3e	/* integer */
 #define  HE155MM	0x26
-#define  HE155SM	0x27
-#define  HE622MM	0x46
+#define  HE622MM	0x27
+#define  HE155SM	0x46
 #define  HE622SM	0x47
 #define MAC_ADDR	0x42	/* char[] */
 
