From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 3/6 linux-2.6.9-rc1/2.4.28-pre2] prism54
	remove module params
Date: Sun, 5 Sep 2004 12:12:28 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200409051212.28081.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_MauOBTDXmybLGKK"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_MauOBTDXmybLGKK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-09-05 Margit Schubert-While <margitsw@t-online.de>
2004-08-18 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

* Remove unneeded module params.

Margit















--Boundary-00=_MauOBTDXmybLGKK
Content-Type: text/x-diff; charset="us-ascii"; name="03_remove_modparms.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="03_remove_modparms.patch"

diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:44:54.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:45:27.000000000 +0200
@@ -36,38 +36,6 @@
 
 #include <net/iw_handler.h>	/* New driver API */
 
-static int init_mode = CARD_DEFAULT_IW_MODE;
-static int init_channel = CARD_DEFAULT_CHANNEL;
-static int init_wep = CARD_DEFAULT_WEP;
-static int init_filter = CARD_DEFAULT_FILTER;
-static int init_authen = CARD_DEFAULT_AUTHEN;
-static int init_dot1x = CARD_DEFAULT_DOT1X;
-static int init_conformance = CARD_DEFAULT_CONFORMANCE;
-static int init_mlme = CARD_DEFAULT_MLME_MODE;
-
-module_param(init_mode, int, 0);
-MODULE_PARM_DESC(init_mode,
-		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: Master / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not supported yet)\n6: Monitor");
-
-module_param(init_channel, int, 0);
-MODULE_PARM_DESC(init_channel,
-		 "Check `iwpriv ethx channel` for available channels");
-
-module_param(init_wep, int, 0);
-module_param(init_filter, int, 0);
-
-module_param(init_authen, int, 0);
-MODULE_PARM_DESC(init_authen,
-		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x0001: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AUTH_BOTH");
-
-module_param(init_dot1x, int, 0);
-MODULE_PARM_DESC(init_dot1x,
-		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DOT1X_KEYTXENABLED");
-
-module_param(init_mlme, int, 0);
-MODULE_PARM_DESC(init_mlme,
-		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: DOT11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTENDED");
-
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
@@ -141,36 +109,34 @@
 void
 prism54_mib_init(islpci_private *priv)
 {
-	u32 t;
+	u32 channel, authen, wep, filter, dot1x, mlme, conformance, power, mode;
 	struct obj_buffer psm_buffer = {
 		.size = PSM_BUFFER_SIZE,
 		.addr = priv->device_psm_buffer
 	};
 
-	mgt_set(priv, DOT11_OID_CHANNEL, &init_channel);
-	mgt_set(priv, DOT11_OID_AUTHENABLE, &init_authen);
-	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &init_wep);
-
+	channel = CARD_DEFAULT_CHANNEL;
+	authen = CARD_DEFAULT_AUTHEN;
+	wep = CARD_DEFAULT_WEP;
+	filter = CARD_DEFAULT_FILTER; /* (0) Do not filter un-encrypted data */
+	dot1x = CARD_DEFAULT_DOT1X; 
+	mlme = CARD_DEFAULT_MLME_MODE;
+	conformance = CARD_DEFAULT_CONFORMANCE;
+	power = 127;
+	mode = CARD_DEFAULT_IW_MODE;
+
+	mgt_set(priv, DOT11_OID_CHANNEL, &channel);
+	mgt_set(priv, DOT11_OID_AUTHENABLE, &authen);
+	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &wep);
 	mgt_set(priv, DOT11_OID_PSMBUFFER, &psm_buffer);
-	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &init_filter);
-	mgt_set(priv, DOT11_OID_DOT1XENABLE, &init_dot1x);
-	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &init_mlme);
-	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &init_conformance);
-
-	t = 127;
-	mgt_set(priv, OID_INL_OUTPUTPOWER, &t);
-
-	/* Important: we are setting a default wireless mode and we are 
-	 * forcing a valid one, so prism54_mib_mode_helper should just set
-	 * mib values depending on what the wireless mode given is. No need
-	 * for it save old values */
-	if (init_mode > IW_MODE_MONITOR || init_mode < IW_MODE_AUTO) {
-		printk(KERN_DEBUG "%s(): You passed a non-valid init_mode. "
-		       "Using default mode\n", __FUNCTION__);
-		init_mode = CARD_DEFAULT_IW_MODE;
-	}
+	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &filter);
+	mgt_set(priv, DOT11_OID_DOT1XENABLE, &dot1x);
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlme);
+	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &conformance);
+	mgt_set(priv, OID_INL_OUTPUTPOWER, &power);
+
 	/* This sets all of the mode-dependent values */
-	prism54_mib_mode_helper(priv, init_mode);
+	prism54_mib_mode_helper(priv, mode);
 }
 
 /* this will be executed outside of atomic context thanks to

--Boundary-00=_MauOBTDXmybLGKK
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_MauOBTDXmybLGKK--
