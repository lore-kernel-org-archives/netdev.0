From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] com20020: linux-2.6.19-rc2-gb4bd8c66 build #77 failed
Date: Fri, 13 Oct 2006 20:50:59 -0700
Message-ID: <20061013205059.b4e44c31.randy.dunlap@oracle.com>
References: <200610132108.53024.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mj@ucw.cz, netdev@vger.kernel.org, akpm <akpm@osdl.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47600 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1752045AbWJNDtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 23:49:51 -0400
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
In-Reply-To: <200610132108.53024.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

com20020.c needs to export functions if either of the ISA or PCI
modules are built as loadable modules.  Or they could always be
exported.

WARNING: "com20020_found" [drivers/net/arcnet/com20020-pci.ko] undefined!
WARNING: "com20020_check" [drivers/net/arcnet/com20020-pci.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/arcnet/com20020.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- linux-2619-rc2-pv.orig/drivers/net/arcnet/com20020.c
+++ linux-2619-rc2-pv/drivers/net/arcnet/com20020.c
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


---
