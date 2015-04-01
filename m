From: sfeldma@gmail.com
Subject: [PATCH net-next v2 20/26] rocker: cut over to new swdev_port_bridge_getlink
Date: Wed,  1 Apr 2015 03:07:56 -0700
Message-ID: <1427882882-2533-21-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35762 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbDAKGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:50 -0400
Received: by pddn5 with SMTP id n5so50338764pdd.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:50 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 018b04a..2b62f02 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4135,18 +4135,6 @@ skip:
 	return idx;
 }
 
-static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				      struct net_device *dev,
-				      u32 filter_mask)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	u16 mode = BRIDGE_MODE_UNDEF;
-	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
-
-	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-				       rocker_port->brport_flags, mask);
-}
-
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4173,6 +4161,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= swdev_port_bridge_setlink,
+	.ndo_bridge_getlink		= swdev_port_bridge_getlink,
 	.ndo_bridge_dellink		= swdev_port_bridge_dellink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
-- 
1.7.10.4
