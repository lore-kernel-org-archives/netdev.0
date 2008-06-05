From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] iphase: move suni_priv to suni.h
Date: Thu, 05 Jun 2008 18:15:34 +0200
Message-ID: <48481126.1000204@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:1758 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760532AbYFEQQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:16:40 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013608934.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 18:15:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  drivers/atm/iphase.c |    6 ------
  drivers/atm/suni.c   |    8 --------
  drivers/atm/suni.h   |    9 +++++++++
  3 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 92fce28..1b7090a 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -65,12 +65,6 @@
  #include "iphase.h"		
  #include "suni.h"		
  #define swap(x) (((x & 0xff) << 8) | ((x & 0xff00) >> 8))
-struct suni_priv {
-        struct k_sonet_stats sonet_stats; /* link diagnostics */
-        unsigned char loop_mode;        /* loopback mode */
-        struct atm_dev *dev;            /* device back-pointer */
-        struct suni_priv *next;         /* next SUNI */
-};
  #define PRIV(dev) ((struct suni_priv *) dev->phy_data)

  static unsigned char ia_phy_get(struct atm_dev *dev, unsigned long addr);
diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index b1d063c..6de0856 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -30,14 +30,6 @@
  #endif


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
index d14c835..de145ff 100644
--- a/drivers/atm/suni.h
+++ b/drivers/atm/suni.h
@@ -8,6 +8,15 @@

  #include <linux/atmdev.h>
  #include <linux/atmioc.h>
+#include <linux/sonet.h>
+
+
+struct suni_priv {
+	struct k_sonet_stats sonet_stats; /* link diagnostics */
+	int loop_mode;			/* loopback mode */
+	struct atm_dev *dev;		/* device back-pointer */
+	struct suni_priv *next;		/* next SUNI */
+};


  /* SUNI registers */
-- 

