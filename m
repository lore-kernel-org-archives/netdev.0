From: sfeldma@gmail.com
Subject: [PATCH net-next 09/18] bonding: cut over to new swdev_port_bridge_setlink
Date: Mon, 30 Mar 2015 01:40:27 -0700
Message-ID: <1427704836-8776-10-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34474 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378AbbC3Ijy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:54 -0400
Received: by pdbni2 with SMTP id ni2so168964850pdb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:54 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
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
