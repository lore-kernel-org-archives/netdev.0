From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/ne3210.c: cleanups
Date: Fri, 24 Jun 2005 22:09:19 +0200
Message-ID: <20050624200919.GK6656@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262169AbVFXUNK@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- make two needlessly global functions static
- kill an ancient version variable

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 30 May 2005
- 2 May 2005
- 19 Apr 2005

 drivers/net/ne3210.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

--- linux-2.6.11-rc3-mm2-full/drivers/net/ne3210.c.old	2005-02-16 16:09:39.000000000 +0100
+++ linux-2.6.11-rc3-mm2-full/drivers/net/ne3210.c	2005-02-21 15:10:02.000000000 +0100
@@ -26,9 +26,6 @@
 	Updated to EISA probing API 5/2003 by Marc Zyngier.
 */
 
-static const char *version =
-	"ne3210.c: Driver revision v0.03, 30/09/98\n";
-
 #include <linux/module.h>
 #include <linux/eisa.h>
 #include <linux/kernel.h>
@@ -197,7 +194,7 @@
 	ei_status.priv = phys_mem;
 
 	if (ei_debug > 0)
-		printk(version);
+		printk("ne3210 loaded.\n");
 
 	ei_status.reset_8390 = &ne3210_reset_8390;
 	ei_status.block_input = &ne3210_block_input;
@@ -359,12 +356,12 @@
 MODULE_DESCRIPTION("NE3210 EISA Ethernet driver");
 MODULE_LICENSE("GPL");
 
-int ne3210_init(void)
+static int ne3210_init(void)
 {
 	return eisa_driver_register (&ne3210_eisa_driver);
 }
 
-void ne3210_cleanup(void)
+static void ne3210_cleanup(void)
 {
 	eisa_driver_unregister (&ne3210_eisa_driver);
 }
