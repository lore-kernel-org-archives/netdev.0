From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v4 08/19] net: bonding: use __ethtool_get_ksettings
Date: Wed,  9 Dec 2015 09:59:18 -0800
Message-ID: <1449683969-7305-9-git-send-email-ddecotig@gmail.com>
References: <1449683969-7305-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Ed Swierk <eswierk@skyportsystems.com>,
        Robert Love <robert.w.love@intel.com>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-api@vger.kernel.org, linux-mips@linux-mips.org,
        fcoe-devel@open-fcoe.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1449683969-7305-1-git-send-email-ddecotig@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/bonding/bond_main.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fe0e7a6..ce8c026 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -374,22 +374,20 @@ down:
 static void bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
-	struct ethtool_cmd ecmd;
-	u32 slave_speed;
+	struct ethtool_ksettings ecmd;
 	int res;
 
 	slave->speed = SPEED_UNKNOWN;
 	slave->duplex = DUPLEX_UNKNOWN;
 
-	res = __ethtool_get_settings(slave_dev, &ecmd);
+	res = __ethtool_get_ksettings(slave_dev, &ecmd);
 	if (res < 0)
 		return;
 
-	slave_speed = ethtool_cmd_speed(&ecmd);
-	if (slave_speed == 0 || slave_speed == ((__u32) -1))
+	if (ecmd.parent.speed == 0 || ecmd.parent.speed == ((__u32)-1))
 		return;
 
-	switch (ecmd.duplex) {
+	switch (ecmd.parent.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
@@ -397,8 +395,8 @@ static void bond_update_speed_duplex(struct slave *slave)
 		return;
 	}
 
-	slave->speed = slave_speed;
-	slave->duplex = ecmd.duplex;
+	slave->speed = ecmd.parent.speed;
+	slave->duplex = ecmd.parent.duplex;
 
 	return;
 }
-- 
2.6.0.rc2.230.g3dd15c0
