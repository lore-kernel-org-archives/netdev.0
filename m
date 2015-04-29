From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: dsa: Fix scope of eeprom-length property
Date: Wed, 29 Apr 2015 10:56:15 -0700
Message-ID: <1430330175-21977-1-git-send-email-linux@roeck-us.net>
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eeprom-length is a switch property, not a dsa property, and thus
needs to be attached to the switch node, not to the dsa node.

Reported-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 6793abb4e849 ("net: dsa: Add support for switch EEPROM access")
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 079a224471e7..e6f6cc3a1bcf 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -633,7 +633,7 @@ static int dsa_of_probe(struct device *dev)
 		if (cd->sw_addr > PHY_MAX_ADDR)
 			continue;
 
-		if (!of_property_read_u32(np, "eeprom-length", &eeprom_len))
+		if (!of_property_read_u32(child, "eeprom-length", &eeprom_len))
 			cd->eeprom_len = eeprom_len;
 
 		for_each_available_child_of_node(child, port) {
-- 
2.1.0
