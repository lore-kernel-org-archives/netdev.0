From: sfeldma@gmail.com
Subject: [PATCH net-next v3 11/26] bonding: cut over to new swdev_port_bridge_setlink
Date: Thu,  2 Apr 2015 01:09:57 -0700
Message-ID: <1427962212-18411-12-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36615 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbbDBIJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:34 -0400
Received: by pdea3 with SMTP id a3so30770466pde.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:33 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

swdev_port_bridge_setlink knows how to recurse stacked devices, so make it
the default bridge_setlink op for bonds.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7b4684c..99ab282 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4036,7 +4036,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
+	.ndo_bridge_setlink	= swdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
-- 
1.7.10.4
