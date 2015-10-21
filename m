From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 07:29:33 -0700
Message-ID: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:53652 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755200AbbJUO3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:29:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hisilicon network driver does not build for Sparc. Enabling
COMPILE_TEST for it causes Sparc allmodconfig/allyesconfig builds
to fail with

drivers/net/ethernet/hisilicon/hns_mdio.c: In function 'hns_mdio_bus_name':
drivers/net/ethernet/hisilicon/hns_mdio.c:409:3: error:
		implicit declaration of function 'of_translate_address'

Fixes: 876133d3161d ("net: hisilicon: add OF dependency")
Cc: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/hisilicon/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index f250dec488fd..413935085591 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_HISILICON
 	bool "Hisilicon devices"
 	default y
-	depends on OF && (ARM || ARM64 || COMPILE_TEST)
+	depends on OF && (ARM || ARM64 || COMPILE_TEST) && !SPARC
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
-- 
2.1.4
