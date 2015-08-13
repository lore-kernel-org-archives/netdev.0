From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/7] net: dsa: mv88e6xxx: use port 802.1Q mode Secure
Date: Thu, 13 Aug 2015 12:52:23 -0400
Message-ID: <1439484743-5126-8-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit changes the 802.1Q mode of each port from Disabled to
Secure. This enables the VLAN support, by checking the VTU entries on
ingress.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 14 +++++++-------
 drivers/net/dsa/mv88e6xxx.h |  5 +++++
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ca867e4..332f2c8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2005,13 +2005,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			goto abort;
 	}
 
-	/* Port Control 2: don't force a good FCS, set the maximum
-	 * frame size to 10240 bytes, don't let the switch add or
-	 * strip 802.1q tags, don't discard tagged or untagged frames
-	 * on this port, do a destination address lookup on all
-	 * received packets as usual, disable ARP mirroring and don't
-	 * send a copy of all transmitted/received frames on this port
-	 * to the CPU.
+	/* Port Control 2: don't force a good FCS, set the maximum frame size to
+	 * 10240 bytes, enable secure 802.1q tags, don't discard tagged or
+	 * untagged frames on this port, do a destination address lookup on all
+	 * received packets as usual, disable ARP mirroring and don't send a
+	 * copy of all transmitted/received frames on this port to the CPU.
 	 */
 	reg = 0;
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
@@ -2033,6 +2031,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
+	reg |= PORT_CONTROL_2_8021Q_SECURE;
+
 	if (reg) {
 		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
 					   PORT_CONTROL_2, reg);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ca3268f..72ca887 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -140,6 +140,11 @@
 #define PORT_CONTROL_2_JUMBO_1522	(0x00 << 12)
 #define PORT_CONTROL_2_JUMBO_2048	(0x01 << 12)
 #define PORT_CONTROL_2_JUMBO_10240	(0x02 << 12)
+#define PORT_CONTROL_2_8021Q_MASK	(0x03 << 10)
+#define PORT_CONTROL_2_8021Q_DISABLED	(0x00 << 10)
+#define PORT_CONTROL_2_8021Q_FALLBACK	(0x01 << 10)
+#define PORT_CONTROL_2_8021Q_CHECK	(0x02 << 10)
+#define PORT_CONTROL_2_8021Q_SECURE	(0x03 << 10)
 #define PORT_CONTROL_2_DISCARD_TAGGED	BIT(9)
 #define PORT_CONTROL_2_DISCARD_UNTAGGED	BIT(8)
 #define PORT_CONTROL_2_MAP_DA		BIT(7)
-- 
2.5.0
