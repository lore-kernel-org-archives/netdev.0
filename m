From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/7] net: dsa: mv88e6xxx: remove all MACs when disabling a port
Date: Fri,  4 Sep 2015 14:34:16 -0400
Message-ID: <1441391656-22574-8-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we're moving a port from Learning or Forwarding state to Disabled
or Blocking or Listening state, remove all non-static MAC addresses
mapped to this port in the entire set of databases, not only one.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 63407a1..30227ca 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1163,7 +1163,7 @@ static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
 		 */
 		if (oldstate >= PORT_CONTROL_STATE_LEARNING &&
 		    state <= PORT_CONTROL_STATE_BLOCKING) {
-			ret = _mv88e6xxx_flush_fid(ds, ps->fid[port]);
+			ret = _mv88e6xxx_atu_remove(ds, 0, port, false);
 			if (ret)
 				goto abort;
 		}
-- 
2.5.1
