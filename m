From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: mv88e6xxx: map destination addresses for 6185
Date: Sat, 26 Mar 2016 21:59:42 -0400
Message-ID: <1459043983-12088-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 88E6185 switch also has a MapDA bit in its Port Control 2 register.
When this bit is cleared, all frames are sent out to the CPU port.

Set this bit to rely on address databases (ATU) hits and direct frames
out of the correct ports, and thus allow hardware bridging.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 366fda1..35d0ace 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2413,7 +2413,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	reg = 0;
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
 	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds))
+	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds) ||
+	    mv88e6xxx_6185_family(ds))
 		reg = PORT_CONTROL_2_MAP_DA;
 
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-- 
2.7.4
