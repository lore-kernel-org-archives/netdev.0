From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v4 14/19] net: 8021q: use __ethtool_get_ksettings
Date: Wed,  9 Dec 2015 09:59:24 -0800
Message-ID: <1449683969-7305-15-git-send-email-ddecotig@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449683969-7305-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/8021q/vlan_dev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index fded865..e607fee 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -620,12 +620,12 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	return features;
 }
 
-static int vlan_ethtool_get_settings(struct net_device *dev,
-				     struct ethtool_cmd *cmd)
+static int vlan_ethtool_get_ksettings(struct net_device *dev,
+				      struct ethtool_ksettings *cmd)
 {
 	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 
-	return __ethtool_get_settings(vlan->real_dev, cmd);
+	return __ethtool_get_ksettings(vlan->real_dev, cmd);
 }
 
 static void vlan_ethtool_get_drvinfo(struct net_device *dev,
@@ -740,7 +740,7 @@ static int vlan_dev_get_iflink(const struct net_device *dev)
 }
 
 static const struct ethtool_ops vlan_ethtool_ops = {
-	.get_settings	        = vlan_ethtool_get_settings,
+	.get_ksettings	        = vlan_ethtool_get_ksettings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= vlan_ethtool_get_ts_info,
-- 
2.6.0.rc2.230.g3dd15c0
