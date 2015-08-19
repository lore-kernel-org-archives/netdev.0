From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: set 802.1Q mode to Fallback
Date: Wed, 19 Aug 2015 18:54:55 -0400
Message-ID: <1440024895-22803-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current Secure port mode requires the port-based VLANs to also be
valid in the 802.1Q VLAN Table Unit. The current hardware bridging
support only configures the port-based VLANs, thus is broken.

A new patchset is required to adapt the hardware bridging code to fully
support the Secure port mode.

In the meantime, change the 802.1Q mode of every ports to Fallback,
which filtering is more permissive, and doesn't add this restriction to
handle port-based and tagged-based VLANs.

Fixes: 8efdda4a1b60 ("net: dsa: mv88e6xxx: use port 802.1Q mode Secure")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index dee71fa..91d7e0a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2091,7 +2091,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
-	reg |= PORT_CONTROL_2_8021Q_SECURE;
+	reg |= PORT_CONTROL_2_8021Q_FALLBACK;
 
 	if (reg) {
 		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
-- 
2.5.0
