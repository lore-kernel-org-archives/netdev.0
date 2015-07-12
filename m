From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: dsa: Fix off-by-one in switch address parsing
Date: Sat, 11 Jul 2015 18:02:11 -0700
Message-ID: <1436662931-8982-3-git-send-email-f.fainelli@gmail.com>
References: <1436662931-8982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	dan.carpenter@oracle.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:33864 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbGLBCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 21:02:20 -0400
Received: by obbkm3 with SMTP id km3so211092376obb.1
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 18:02:19 -0700 (PDT)
In-Reply-To: <1436662931-8982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cd->sw_addr is used as a MDIO bus address, which cannot exceed
PHY_MAX_ADDR (32), our check was off-by-one.

Fixes: 5e95329b701c ("dsa: add device tree bindings to register DSA switches")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 52beeb8829dc..b445d492c115 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -630,7 +630,7 @@ static int dsa_of_probe(struct device *dev)
 			continue;
 
 		cd->sw_addr = be32_to_cpup(sw_addr);
-		if (cd->sw_addr > PHY_MAX_ADDR)
+		if (cd->sw_addr >= PHY_MAX_ADDR)
 			continue;
 
 		if (!of_property_read_u32(child, "eeprom-length", &eeprom_len))
-- 
2.1.4
