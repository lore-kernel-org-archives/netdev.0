From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v1 13/18] net: 8021q: use __ethtool_get_ksettings
Date: Mon, 26 Jan 2015 17:36:09 -0800
Message-ID: <1422322574-6188-14-git-send-email-ddecotig@gmail.com>
References: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eyal Perry <eyalpe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422322574-6188-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 net/8021q/vlan_dev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1189564..b301bf6 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -655,12 +655,12 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
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
@@ -768,7 +768,7 @@ static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
 static const struct ethtool_ops vlan_ethtool_ops = {
-	.get_settings	        = vlan_ethtool_get_settings,
+	.get_ksettings	        = vlan_ethtool_get_ksettings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= vlan_ethtool_get_ts_info,
-- 
2.2.0.rc0.207.ga3a616c
