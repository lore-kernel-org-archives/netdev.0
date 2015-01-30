From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 7/7] team: handle NETIF_F_HW_SWITCH_OFFLOAD flag and add ndo_bridge_setlink/dellink handlers
Date: Thu, 29 Jan 2015 22:40:17 -0800
Message-ID: <1422600017-42393-8-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56750 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbbA3Gka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:30 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so48725500pad.7
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Currently ndo_bridge_setlink and ndo_bridge_dellink handlers point
to the default switchdev handlers

This follows my bonding driver changes.

I have only compile tested this patch. However similar
bonding code has been tested.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/team/team.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4b2bfc5..0e62274 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -28,6 +28,7 @@
 #include <net/genetlink.h>
 #include <net/netlink.h>
 #include <net/sch_generic.h>
+#include <net/switchdev.h>
 #include <generated/utsrelease.h>
 #include <linux/if_team.h>
 
@@ -1925,7 +1926,7 @@ static netdev_features_t team_fix_features(struct net_device *dev,
 	struct team *team = netdev_priv(dev);
 	netdev_features_t mask;
 
-	mask = features;
+	mask = features | NETIF_F_HW_SWITCH_OFFLOAD;
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
@@ -1975,6 +1976,8 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
+	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
+	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
 };
 
 /***********************
-- 
1.7.10.4
