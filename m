From: Dan Carpenter <error27@gmail.com>
Subject: [patch] cpmac: use after free
Date: Wed, 3 Mar 2010 11:46:10 +0300
Message-ID: <20100303084610.GH5086@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Jiri Pirko <jpirko@redhat.com>,
	Stefan Weil <weil@mail.berlios.de>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:52600 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188Ab0CCIqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:46:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code dereferenced "cpmac_mii" after calling 
"mdiobus_free(cpmac_mii);"

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Found by a static checker and not tested.  Sorry.  :/

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index b85c81f..9d48942 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1290,8 +1290,8 @@ void __devexit cpmac_exit(void)
 {
 	platform_driver_unregister(&cpmac_driver);
 	mdiobus_unregister(cpmac_mii);
-	mdiobus_free(cpmac_mii);
 	iounmap(cpmac_mii->priv);
+	mdiobus_free(cpmac_mii);
 }
 
 module_init(cpmac_init);
