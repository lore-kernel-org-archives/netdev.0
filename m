From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/7] net: dsa: mv88e6131: enable hardware bridging
Date: Sat, 26 Mar 2016 21:59:43 -0400
Message-ID: <1459043983-12088-8-git-send-email-vivien.didelot@savoirfairelinux.com>
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

By adding support for bridge operations, FDB operations, and optionally
VLAN operations (for 802.1Q and VLAN filtering aware systems), the
switch bridges ports correctly, the CPU is able to populate the hardware
address databases, and thus hardware bridging becomes functional within
the 88E6185 family of switches.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index a92ca65..2407028 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -169,6 +169,17 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.adjust_link		= mv88e6xxx_adjust_link,
+	.port_bridge_join	= mv88e6xxx_port_bridge_join,
+	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
+	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
+	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
+	.port_fdb_prepare       = mv88e6xxx_port_fdb_prepare,
+	.port_fdb_add           = mv88e6xxx_port_fdb_add,
+	.port_fdb_del           = mv88e6xxx_port_fdb_del,
+	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
-- 
2.7.4
