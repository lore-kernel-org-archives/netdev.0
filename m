From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: mv88e6xxx: fix setup of port control 1
Date: Mon, 20 Apr 2015 17:19:23 -0400
Message-ID: <1429564763-10098-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mv88e6xxx_setup_port_common was writing to PORT_DEFAULT_VLAN (port
offset 0x07) instead of PORT_CONTROL_1 (port offset 0x05).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9f0c2b9..48712bd 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1251,8 +1251,7 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
-				   0x0000);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1, 0x0000);
 	if (ret)
 		goto abort;
 
-- 
2.3.5
