From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6 1/3] PRO/10+ not configured properly
Date: Thu, 25 Sep 2003 18:44:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309251841290.6381-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* PRO/10+ (10 Mbps-only card) was not configured properly so it didn't 
pass traffic.

-----------------

diff -Naurp net-drivers-2.5/drivers/net/e100/e100_config.c net-drivers-2.5/drivers/net/e100.mod/e100_config.c
--- net-drivers-2.5/drivers/net/e100/e100_config.c	2003-09-24 20:33:44.000000000 -0700
+++ net-drivers-2.5/drivers/net/e100.mod/e100_config.c	2003-09-24 20:34:04.000000000 -0700
@@ -60,7 +60,7 @@ static const u8 def_config[] = {
  * All other init functions will only set values that are
  * different from the 82557 default.
  */
-static void __devinit
+void __devinit
 e100_config_init_82557(struct e100_private *bdp)
 {
 	/* initialize config block */
diff -Naurp net-drivers-2.5/drivers/net/e100/e100_config.h net-drivers-2.5/drivers/net/e100.mod/e100_config.h
--- net-drivers-2.5/drivers/net/e100/e100_config.h	2003-09-24 20:33:44.000000000 -0700
+++ net-drivers-2.5/drivers/net/e100.mod/e100_config.h	2003-09-24 20:34:09.000000000 -0700
@@ -151,6 +151,7 @@
 
 /* function prototypes */
 extern void e100_config_init(struct e100_private *bdp);
+extern void e100_config_init_82557(struct e100_private *bdp);
 extern unsigned char e100_force_config(struct e100_private *bdp);
 extern unsigned char e100_config(struct e100_private *bdp);
 extern void e100_config_fc(struct e100_private *bdp);
diff -Naurp net-drivers-2.5/drivers/net/e100/e100_main.c net-drivers-2.5/drivers/net/e100.mod/e100_main.c
--- net-drivers-2.5/drivers/net/e100/e100_main.c	2003-09-24 20:33:44.000000000 -0700
+++ net-drivers-2.5/drivers/net/e100.mod/e100_main.c	2003-09-24 20:34:20.000000000 -0700
@@ -1404,6 +1404,9 @@ e100_hw_init(struct e100_private *bdp)
 		bdp->flags |= DF_UCODE_LOADED;
 	}
 
+	if ((u8) bdp->rev_id < D101A4_REV_ID)
+		e100_config_init_82557(bdp);
+		
 	if (!e100_config(bdp))
 		goto err;
 
