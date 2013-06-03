From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mv643xx_eth: add missing semicolon
Date: Mon, 03 Jun 2013 15:11:24 +0200
Message-ID: <4063428.ukZe9BdPSb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:60327 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab3FCNLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 09:11:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

76723bca28 "net: mv643xx_eth: add DT parsing support" added a
dummy mv643xx_eth_shared_of_probe() fallback function with a
typo.

This adds the missing semicolon so we can build without CONFIG_OF
again, and changes both dummy functions to the more conventional
"static inline" syntax, which can avoid potential problems with
the empty macro.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 23ea7b6..c7f9fb3 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2582,12 +2582,14 @@ static void mv643xx_eth_shared_of_remove(void)
 	}
 }
 #else
-static int mv643xx_eth_shared_of_probe(struct platform_device *pdev)
+static inline int mv643xx_eth_shared_of_probe(struct platform_device *pdev)
 {
-	return 0
+	return 0;
 }
 
-#define mv643xx_eth_shared_of_remove()
+static inline void mv643xx_eth_shared_of_remove(void)
+{
+}
 #endif
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
