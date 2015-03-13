From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 3/3] team: add support for ndo_switch_port_stp_update when team dev is a bridge port
Date: Thu, 12 Mar 2015 17:29:58 -0700
Message-ID: <1426206598-29410-4-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36753 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959AbbCMAaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 20:30:11 -0400
Received: by pdbnh10 with SMTP id nh10so24245625pdb.3
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:30:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for stp state offload netdev op to support the case
where team dev is a bridge port and team slaves are switch ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/team/team.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a23319f..ccf6efb 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1979,6 +1979,9 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
 	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
+#ifdef CONFIG_NET_SWITCHDEV
+	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
+#endif
 };
 
 /***********************
-- 
1.7.10.4
