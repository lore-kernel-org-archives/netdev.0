From: akpm@osdl.org
Subject: [patch 7/9] com20020 build fix
Date: Fri, 20 Oct 2006 14:43:17 -0700
Message-ID: <200610202143.k9KLhHMs003807@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, randy.dunlap@oracle.com,
	toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52612 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946390AbWJTVnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:49 -0400
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
 1 files changed, 5 insertions(+), 2 deletions(-)

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
