From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 2/3] team: add helper to check if device is a team
 master
Date: Tue, 11 Nov 2014 09:21:50 +0100 (CET)
Message-ID: <55ee8e8e93d2dd79cb2a5b1310b9293e8bf99e80.1415692212.git.mkubecek@suse.cz>
References: <cover.1415692212.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415692212.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add flag IFF_TEAM_MASTER to recognize a team master and helper
netif_is_team_master() to check it.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/team/team.c   | 3 ++-
 include/linux/netdevice.h | 7 +++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2368395..e1e2b85 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2043,7 +2043,8 @@ static void team_setup(struct net_device *dev)
 	 * bring us to promisc mode in case a unicast addr is added.
 	 * Let this up to underlay drivers.
 	 */
-	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE |
+			   IFF_TEAM_MASTER;
 
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_GRO;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 888d551..1236feb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1203,6 +1203,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_TEAM_MASTER: device is a team master
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1228,6 +1229,7 @@ enum netdev_priv_flags {
 	IFF_LIVE_ADDR_CHANGE		= 1<<20,
 	IFF_MACVLAN			= 1<<21,
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
+	IFF_TEAM_MASTER			= 1<<23,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -3638,6 +3640,11 @@ static inline bool netif_is_bond_slave(struct net_device *dev)
 	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_BONDING;
 }
 
+static inline bool netif_is_team_master(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_TEAM_MASTER;
+}
+
 static inline bool netif_supports_nofcs(struct net_device *dev)
 {
 	return dev->priv_flags & IFF_SUPP_NOFCS;
-- 
1.8.4.5
