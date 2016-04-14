From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net 2/3] net: dsa: mv88e6xxx: enable SA learning on DSA ports
Date: Thu, 14 Apr 2016 14:42:08 -0400
Message-ID: <1460659329-11473-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In multi-chip systems, DSA Tag ports must learn SA addresses in order to
correctly switch frames between interconnected chips.

This fixes cross-chip hardware bridging in a VLAN filtering aware
system, because a bridge group gets implemented as an hardware 802.1Q
VLAN and thus DSA and user ports share the same FDB.

Fixes: 4c7ea3c0791e ("net: dsa: mv88e6xxx: disable SA learning for DSA and CPU ports")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7725e29..46c9b4c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2542,8 +2542,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * the other bits clear.
 	 */
 	reg = 1 << port;
-	/* Disable learning for DSA and CPU ports */
-	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+	/* Disable learning for CPU port */
+	if (dsa_is_cpu_port(ds, port))
 		reg = 0;
 
 	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
-- 
2.8.0
