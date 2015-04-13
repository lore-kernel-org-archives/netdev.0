From: sfeldma@gmail.com
Subject: [PATCH net-next v4 12/24] team: cut over to new swdev_port_bridge_setlink
Date: Sun, 12 Apr 2015 23:17:06 -0700
Message-ID: <1428905838-14920-13-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36546 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbbDMGQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:45 -0400
Received: by pabsx10 with SMTP id sx10so91883708pab.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:45 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

swdev_port_bridge_setlink knows how to recurse stacked devices, so make it
the default bridge_setlink op for teams.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6928448..6a3debc 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1977,7 +1977,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
-	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
+	.ndo_bridge_setlink	= swdev_port_bridge_setlink,
 	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
-- 
1.7.10.4
