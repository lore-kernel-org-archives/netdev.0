From: David Dillow <dave@thedillows.org>
Subject: [PATCH] Typhoon net driver fixes for 2.5
Date: 27 Jun 2003 00:52:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056689572.8692.44.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1386  -> 1.1387 
#	drivers/net/typhoon.c	1.5     -> 1.8    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/27	dave@thedillows.org	1.1387
# Fix misreporting of card type and spurious "already scheduled" messages.
# --------------------------------------------
#
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	Fri Jun 27 00:38:02 2003
+++ b/drivers/net/typhoon.c	Fri Jun 27 00:38:02 2003
@@ -85,8 +85,8 @@
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.0"
-#define DRV_MODULE_RELDATE	"03/02/14"
+#define DRV_MODULE_VERSION 	"1.5.1"
+#define DRV_MODULE_RELDATE	"03/06/26"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -150,7 +150,7 @@
 #define TYPHOON_CRYPTO_DES		1
 #define TYPHOON_CRYPTO_3DES		2
 #define	TYPHOON_CRYPTO_VARIABLE		4
-#define TYPHOON_FIBER			5
+#define TYPHOON_FIBER			8
 
 enum typhoon_cards {
 	TYPHOON_TX = 0, TYPHOON_TX95, TYPHOON_TX97, TYPHOON_SVR,
@@ -1798,7 +1798,7 @@
 	u32 intr_status;
 
 	intr_status = readl(ioaddr + TYPHOON_REG_INTR_STATUS);
-	if(!intr_status)
+	if(!(intr_status & TYPHOON_INTR_HOST_INT))
 		return IRQ_NONE;
 
 	writel(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
