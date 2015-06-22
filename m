From: sfeldma@gmail.com
Subject: [PATCH net-next 1/2] switchdev: rename vlan vid_start to vid_begin
Date: Mon, 22 Jun 2015 00:27:16 -0700
Message-ID: <1434958037-26057-2-git-send-email-sfeldma@gmail.com>
References: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	vivien.didelot@savoirfairelinux.com, ronen.arad@intel.com,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34157 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389AbbFVHZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 03:25:45 -0400
Received: by pabvl15 with SMTP id vl15so82148470pab.1
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 00:25:45 -0700 (PDT)
In-Reply-To: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Use vid_begin/end to be consistent with BRIDGE_VLAN_INFO_RANGE_BEGIN/END.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    4 ++--
 include/net/switchdev.h              |    2 +-
 net/bridge/br_vlan.c                 |    4 ++--
 net/switchdev/switchdev.c            |   12 ++++++------
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index b72674c..76c3086 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4295,7 +4295,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 	u16 vid;
 	int err;
 
-	for (vid = vlan->vid_start; vid <= vlan->vid_end; vid++) {
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
 		err = rocker_port_vlan_add(rocker_port, trans,
 					   vid, vlan->flags);
 		if (err)
@@ -4378,7 +4378,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 	u16 vid;
 	int err;
 
-	for (vid = vlan->vid_start; vid <= vlan->vid_end; vid++) {
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
 		err = rocker_port_vlan_del(rocker_port, vid, vlan->flags);
 		if (err)
 			return err;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d882902..89da893 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -57,7 +57,7 @@ struct switchdev_obj {
 	union {
 		struct switchdev_obj_vlan {		/* PORT_VLAN */
 			u16 flags;
-			u16 vid_start;
+			u16 vid_begin;
 			u16 vid_end;
 		} vlan;
 		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 17fc358..574feea 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -54,7 +54,7 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			.id = SWITCHDEV_OBJ_PORT_VLAN,
 			.u.vlan = {
 				.flags = flags,
-				.vid_start = vid,
+				.vid_begin = vid,
 				.vid_end = vid,
 			},
 		};
@@ -132,7 +132,7 @@ static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 		struct switchdev_obj vlan_obj = {
 			.id = SWITCHDEV_OBJ_PORT_VLAN,
 			.u.vlan = {
-				.vid_start = vid,
+				.vid_begin = vid,
 				.vid_end = vid,
 			},
 		};
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index afce9cc..70764c5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -511,23 +511,23 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		vinfo = nla_data(attr);
 		vlan->flags = vinfo->flags;
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
-			if (vlan->vid_start)
+			if (vlan->vid_begin)
 				return -EINVAL;
-			vlan->vid_start = vinfo->vid;
+			vlan->vid_begin = vinfo->vid;
 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
-			if (!vlan->vid_start)
+			if (!vlan->vid_begin)
 				return -EINVAL;
 			vlan->vid_end = vinfo->vid;
-			if (vlan->vid_end <= vlan->vid_start)
+			if (vlan->vid_end <= vlan->vid_begin)
 				return -EINVAL;
 			err = f(dev, &obj);
 			if (err)
 				return err;
 			memset(vlan, 0, sizeof(*vlan));
 		} else {
-			if (vlan->vid_start)
+			if (vlan->vid_begin)
 				return -EINVAL;
-			vlan->vid_start = vinfo->vid;
+			vlan->vid_begin = vinfo->vid;
 			vlan->vid_end = vinfo->vid;
 			err = f(dev, &obj);
 			if (err)
-- 
1.7.10.4
