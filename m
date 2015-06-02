From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 7/9] net: dsa: mv88e6352: lock CPU port from learning addresses
Date: Mon,  1 Jun 2015 21:27:48 -0400
Message-ID: <1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit disables SA learning and refreshing for the CPU port.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 8 +++++---
 drivers/net/dsa/mv88e6xxx.h | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d2beb10..ed49bd8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1761,10 +1761,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
-	 * the other bits clear.
+	 * the other bits clear, except for the CPU port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR,
-				   1 << port);
+	reg = BIT(port);
+	if (dsa_is_cpu_port(ds, port))
+		reg |= PORT_ASSOC_VECTOR_LOCKED_PORT;
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
 	if (ret)
 		goto abort;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 412d14e..e26eb0c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -144,6 +144,7 @@
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
 #define PORT_ASSOC_VECTOR	0x0b
+#define PORT_ASSOC_VECTOR_LOCKED_PORT	BIT(13)
 #define PORT_ATU_CONTROL	0x0c
 #define PORT_PRI_OVERRIDE	0x0d
 #define PORT_ETH_TYPE		0x0f
-- 
2.4.1
