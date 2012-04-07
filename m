From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/16] batman-adv: make bridge loop avoidance switchable
Date: Sat,  7 Apr 2012 20:49:51 +0200
Message-ID: <1333824598-27771-10-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:61043 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638Ab2DGSt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:29 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |    9 +++++++++
 net/batman-adv/bat_sysfs.c                     |    2 ++
 2 files changed, 11 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index b218e0f..c81fe89 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -14,6 +14,15 @@ Description:
                 mesh will be sent using multiple interfaces at the
                 same time (if available).
 
+What:           /sys/class/net/<mesh_iface>/mesh/bridge_loop_avoidance
+Date:           November 2011
+Contact:        Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+Description:
+                Indicates whether the bridge loop avoidance feature
+                is enabled. This feature detects and avoids loops
+                between the mesh and devices bridged with the soft
+                interface <mesh_iface>.
+
 What:           /sys/class/net/<mesh_iface>/mesh/fragmentation
 Date:           October 2010
 Contact:        Andreas Langer <an.langer@gmx.de>
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index d12757f..824bfe7 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -386,6 +386,7 @@ static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 
 BAT_ATTR_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
 BAT_ATTR_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
@@ -404,6 +405,7 @@ BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
 static struct bat_attribute *mesh_attrs[] = {
 	&bat_attr_aggregated_ogms,
 	&bat_attr_bonding,
+	&bat_attr_bridge_loop_avoidance,
 	&bat_attr_fragmentation,
 	&bat_attr_ap_isolation,
 	&bat_attr_vis_mode,
-- 
1.7.9.4
