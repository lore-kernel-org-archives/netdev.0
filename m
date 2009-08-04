From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/5] cpmac: wait longer after MDIO reset
Date: Tue, 4 Aug 2009 22:52:57 +0200
Message-ID: <200908042252.57848.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:59459 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932579AbZHDUxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:53:02 -0400
Received: by ey-out-2122.google.com with SMTP id 9so46714eyd.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:53:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch slows down the MDIO_ALIVE busy waiting to let
switches and PHY come up after reset. Previous loop was
too quick for IC+175C and ADM6996C/L switches to come up.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index f2fc722..12a521e 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1245,11 +1245,11 @@ int __devinit cpmac_init(void)
 
 	cpmac_mii->reset(cpmac_mii);
 
-	for (i = 0; i < 300000; i++)
+	for (i = 0; i < 300; i++)
 		if ((mask = cpmac_read(cpmac_mii->priv, CPMAC_MDIO_ALIVE)))
 			break;
 		else
-			cpu_relax();
+			msleep(10);
 
 	mask &= 0x7fffffff;
 	if (mask & (mask - 1)) {
