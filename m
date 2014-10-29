From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3 02/15] net: dsa: Report known silicon revisions for Marvell 88E6060
Date: Wed, 29 Oct 2014 10:44:54 -0700
Message-ID: <1414604707-22407-3-git-send-email-linux@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:51717 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452AbaJ2RpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 13:45:19 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XjXJ9-00491b-1f
	for netdev@vger.kernel.org; Wed, 29 Oct 2014 17:45:19 +0000
In-Reply-To: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report known silicon revisions when probing Marvell 88E6060 switches.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3:
- No change
v2:
- No change

 drivers/net/dsa/mv88e6060.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 05b0ca3..c29aebe 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -69,8 +69,11 @@ static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
 
 	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
 	if (ret >= 0) {
-		ret &= 0xfff0;
 		if (ret == 0x0600)
+			return "Marvell 88E6060 (A0)";
+		if (ret == 0x0601 || ret == 0x0602)
+			return "Marvell 88E6060 (B0)";
+		if ((ret & 0xfff0) == 0x0600)
 			return "Marvell 88E6060";
 	}
 
-- 
1.9.1
