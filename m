From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] starfire: use BUILD_BUG_ON for netdrv_addr_t
Date: Sat, 28 Aug 2010 14:08:45 +0900
Message-ID: <1282972125-9968-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Ion Badulescu <ionut@badula.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45456 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab0H1FPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 01:15:42 -0400
Received: by pzk9 with SMTP id 9so1321884pzk.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 22:15:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detect size mismatch for netdrv_addr_t at build time rather than
checking at module load time.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Ion Badulescu <ionut@badula.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/starfire.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 26c3634..c3bf288 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -2078,11 +2078,7 @@ static int __init starfire_init (void)
 	printk(KERN_INFO DRV_NAME ": polling (NAPI) enabled\n");
 #endif
 
-	/* we can do this test only at run-time... sigh */
-	if (sizeof(dma_addr_t) != sizeof(netdrv_addr_t)) {
-		printk("This driver has dma_addr_t issues, please send email to maintainer\n");
-		return -ENODEV;
-	}
+	BUILD_BUG_ON(sizeof(dma_addr_t) != sizeof(netdrv_addr_t));
 
 	return pci_register_driver(&starfire_driver);
 }
-- 
1.6.0.6

