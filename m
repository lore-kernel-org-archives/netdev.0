From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 8/9] net: dsa: mv88e6352: set port 802.1Q mode to Secure
Date: Mon,  1 Jun 2015 21:27:49 -0400
Message-ID: <1433208470-25338-9-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64296 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbbFBB2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 21:28:14 -0400
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit changes the 802.1Q mode of each port from Disabled to
Secure. This enables the VLAN support, by checking the VTU entries on
ingress.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 14 +++++++-------
 drivers/net/dsa/mv88e6xxx.h |  5 +++++
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ed49bd8..35243d8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1723,13 +1723,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
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
@@ -1751,6 +1749,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
+	reg |= PORT_CONTROL_2_8021Q_SECURE;
+
 	if (reg) {
 		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
 					   PORT_CONTROL_2, reg);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e26eb0c..02528aa 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -134,6 +134,11 @@
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
2.4.1
