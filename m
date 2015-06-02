From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 6/9] net: dsa: mv88e6352: allow egress of unknown multicast
Date: Mon,  1 Jun 2015 21:27:47 -0400
Message-ID: <1433208470-25338-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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

This patch disables egress of unknown unicast destination addresses.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 drivers/net/dsa/mv88e6xxx.h | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 49ef2f8..d2beb10 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1686,7 +1686,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	    mv88e6xxx_6185_family(ds))
 		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
-		PORT_CONTROL_STATE_FORWARDING;
+		PORT_CONTROL_STATE_FORWARDING |
+		PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UNICAST_DA;
 	if (dsa_is_cpu_port(ds, port)) {
 		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
 			reg |= PORT_CONTROL_DSA_TAG;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index f4ea66a..412d14e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -117,6 +117,11 @@
 #define PORT_CONTROL_STATE_BLOCKING	0x01
 #define PORT_CONTROL_STATE_LEARNING	0x02
 #define PORT_CONTROL_STATE_FORWARDING	0x03
+#define PORT_CONTROL_EGRESS_FLOODS_MASK				(0x03 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_ANY_DA		(0x00 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MULTICAST_DA	(0x01 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UNICAST_DA	(0x02 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_ANY_DA			(0x03 << 2)
 #define PORT_CONTROL_1		0x05
 #define PORT_BASE_VLAN		0x06
 #define PORT_DEFAULT_VLAN	0x07
-- 
2.4.1
