From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] net: Use PTR_RET rather than if(IS_ERR(.. [1]
Date: Mon, 06 Aug 2012 19:51:16 +0200
Message-ID: <1344275476.14513.104.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "[acme@ghostprotocols.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org]"@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:47781 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab2HFScH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 14:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The semantic patch that makes this change is available
in scripts/coccinelle/api/ptr_ret.cocci.

More information about semantic patching is available at
http://coccinelle.lip6.fr/

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -996,9 +996,7 @@ static int __init cops_module_init(void)
 		printk(KERN_WARNING "%s: You shouldn't autoprobe with insmod\n",
 			cardname);
 	cops_dev = cops_probe(-1);
-	if (IS_ERR(cops_dev))
-		return PTR_ERR(cops_dev);
-        return 0;
+	return PTR_RET(cops_dev);
 }
 
 static void __exit cops_module_exit(void)
diff -u -p a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1243,9 +1243,7 @@ static int __init ltpc_module_init(void)
 		       "ltpc: Autoprobing is not recommended for modules\n");
 
 	dev_ltpc = ltpc_probe();
-	if (IS_ERR(dev_ltpc))
-		return PTR_ERR(dev_ltpc);
-	return 0;
+	return PTR_RET(dev_ltpc);
 }
 module_init(ltpc_module_init);
 #endif
