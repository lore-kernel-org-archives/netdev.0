From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 10/10] batman-adv: export used routing
	algorithm via sysfs
Date: Fri, 17 Feb 2012 15:18:30 +0800
Message-ID: <1329463110-856-11-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |    7 +++++++
 net/batman-adv/bat_sysfs.c                     |    9 +++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index b020014..b218e0f 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -65,6 +65,13 @@ Description:
 		Defines the penalty which will be applied to an
 		originator message's tq-field on every hop.
 
+What:		/sys/class/net/<mesh_iface>/mesh/routing_algo
+Date:		Dec 2011
+Contact:	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+		Defines the routing procotol this mesh instance
+		uses to find the optimal paths through the mesh.
+
 What:           /sys/class/net/<mesh_iface>/mesh/vis_mode
 Date:           May 2010
 Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index c25492f..480ae0a 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -272,6 +272,13 @@ static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
 	return count;
 }
 
+static ssize_t show_bat_algo(struct kobject *kobj, struct attribute *attr,
+			    char *buff)
+{
+	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);
+	return sprintf(buff, "%s\n", bat_priv->bat_algo_ops->name);
+}
+
 static void post_gw_deselect(struct net_device *net_dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
@@ -382,6 +389,7 @@ BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
 BAT_ATTR_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
+static BAT_ATTR(routing_algo, S_IRUGO, show_bat_algo, NULL);
 static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, show_gw_mode, store_gw_mode);
 BAT_ATTR_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NULL);
 BAT_ATTR_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NULL);
@@ -399,6 +407,7 @@ static struct bat_attribute *mesh_attrs[] = {
 	&bat_attr_fragmentation,
 	&bat_attr_ap_isolation,
 	&bat_attr_vis_mode,
+	&bat_attr_routing_algo,
 	&bat_attr_gw_mode,
 	&bat_attr_orig_interval,
 	&bat_attr_hop_penalty,
-- 
1.7.9
