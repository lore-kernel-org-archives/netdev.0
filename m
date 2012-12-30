From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH v2 net-next] team: add ethtool support
Date: Sun, 30 Dec 2012 00:37:33 -0200
Message-ID: <1356835053-25602-1-git-send-email-fbl@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753705Ab2L3Chz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 21:37:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds few ethtool operations to team driver.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
v2 - removed generic statistics from ethtool

 drivers/net/team/team.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ad86660..7665a088 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -28,6 +28,7 @@
 #include <net/genetlink.h>
 #include <net/netlink.h>
 #include <net/sch_generic.h>
+#include <generated/utsrelease.h>
 #include <linux/if_team.h>
 
 #define DRV_NAME "team"
@@ -1731,6 +1732,21 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 };
 
+/***********************
+ * ethtool interface
+ ***********************/
+
+static void team_ethtool_get_drvinfo(struct net_device *dev,
+				     struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, DRV_NAME, 32);
+	strncpy(drvinfo->version, UTS_RELEASE, 32);
+}
+
+static const struct ethtool_ops team_ethtool_ops = {
+	.get_drvinfo		= team_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+};
 
 /***********************
  * rt netlink interface
@@ -1780,6 +1796,7 @@ static void team_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->netdev_ops = &team_netdev_ops;
+	dev->ethtool_ops = &team_ethtool_ops;
 	dev->destructor	= team_destructor;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MULTICAST;
-- 
1.8.0.1
