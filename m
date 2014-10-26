From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 05/15] net: dsa/mv88e6352: Add support for MV88E6176
Date: Sun, 26 Oct 2014 09:52:35 -0700
Message-ID: <1414342365-27191-6-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MV88E6176 is mostly compatible to MV88E6352 and is documented
in the same functional specification. Add support for it.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- No change

 drivers/net/dsa/Kconfig     | 5 +++--
 drivers/net/dsa/mv88e6352.c | 2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 0987c33..2d1a55e 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -46,12 +46,13 @@ config NET_DSA_MV88E6171
 	  chip.
 
 config NET_DSA_MV88E6352
-	tristate "Marvell 88E6352 ethernet switch chip support"
+	tristate "Marvell 88E6176/88E6352 ethernet switch chip support"
 	select NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
-	  This enables support for the Marvell 88E6352 ethernet switch chip.
+	  This enables support for the Marvell 88E6176 and 88E6352 ethernet
+	  switch chips.
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 43a5826..f17364f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -73,6 +73,8 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
+		if ((ret & 0xfff0) == 0x1760)
+			return "Marvell 88E6176";
 		if (ret == 0x3521)
 			return "Marvell 88E6352 (A0)";
 		if (ret == 0x3522)
-- 
1.9.1
