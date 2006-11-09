From: akpm@osdl.org
Subject: [patch 2/9] com20020 build fix
Date: Wed, 08 Nov 2006 19:51:03 -0800
Message-ID: <200611090351.kA93p3Vw003681@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, randy.dunlap@oracle.com,
	toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12463 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965928AbWKIDvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:13 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

com20020.c needs to export functions if either of the ISA or PCI modules
are built as loadable modules.  Or they could always be exported.

WARNING: "com20020_found" [drivers/net/arcnet/com20020-pci.ko] undefined!
WARNING: "com20020_check" [drivers/net/arcnet/com20020-pci.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Toralf Forster <toralf.foerster@gmx.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/arcnet/com20020.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff -puN drivers/net/arcnet/com20020.c~com20020-build-fix drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c~com20020-build-fix
+++ a/drivers/net/arcnet/com20020.c
@@ -337,13 +337,16 @@ static void com20020_set_mc_list(struct 
 	}
 }
 
-#ifdef MODULE
-
+#if defined(CONFIG_ARCNET_COM20020_PCI_MODULE) || \
+    defined(CONFIG_ARCNET_COM20020_ISA_MODULE)
 EXPORT_SYMBOL(com20020_check);
 EXPORT_SYMBOL(com20020_found);
+#endif
 
 MODULE_LICENSE("GPL");
 
+#ifdef MODULE
+
 int init_module(void)
 {
 	BUGLVL(D_NORMAL) printk(VERSION);
_
