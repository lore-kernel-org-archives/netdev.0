From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 03/15] net: dsa: Report known silicon revisions for Marvell 88E6131
Date: Sun, 26 Oct 2014 09:52:33 -0700
Message-ID: <1414342365-27191-4-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:45313 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaJZQw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 12:52:57 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XiR3p-002qaX-KB
	for netdev@vger.kernel.org; Sun, 26 Oct 2014 16:52:57 +0000
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report known silicon revisions when probing Marvell 88E6131 switches.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- No change

 drivers/net/dsa/mv88e6131.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 244c735..1230f52 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -21,6 +21,7 @@
 #define ID_6085		0x04a0
 #define ID_6095		0x0950
 #define ID_6131		0x1060
+#define ID_6131_B2	0x1066
 
 static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 {
@@ -32,12 +33,15 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
-		ret &= 0xfff0;
-		if (ret == ID_6085)
+		int ret_masked = ret & 0xfff0;
+
+		if (ret_masked == ID_6085)
 			return "Marvell 88E6085";
-		if (ret == ID_6095)
+		if (ret_masked == ID_6095)
 			return "Marvell 88E6095/88E6095F";
-		if (ret == ID_6131)
+		if (ret == ID_6131_B2)
+			return "Marvell 88E6131 (B2)";
+		if (ret_masked == ID_6131)
 			return "Marvell 88E6131";
 	}
 
-- 
1.9.1
