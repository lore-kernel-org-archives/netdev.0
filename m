From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] team: implement carrier change
Date: Sat, 29 Dec 2012 23:31:01 -0200
Message-ID: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732Ab2L3BbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 20:31:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The user space teamd daemon may need to control the
master's carrier state depending on the selected mode.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/team/team.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f711039..14cb843 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1708,6 +1708,15 @@ static netdev_features_t team_fix_features(struct net_device *dev,
 	return features;
 }
 
+static int team_change_carrier(struct net_device *dev, bool new_carrier)
+{
+	if (new_carrier)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+	return 0;
+}
+
 static const struct net_device_ops team_netdev_ops = {
 	.ndo_init		= team_init,
 	.ndo_uninit		= team_uninit,
@@ -1730,6 +1739,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_add_slave		= team_add_slave,
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
+	.ndo_change_carrier     = team_change_carrier,
 };
 
 /***********************
-- 
1.8.0.1
