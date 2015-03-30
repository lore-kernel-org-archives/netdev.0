From: sfeldma@gmail.com
Subject: [PATCH net-next 15/18] rocker: cut over to new swdev_port_bridge_getlink
Date: Mon, 30 Mar 2015 01:40:33 -0700
Message-ID: <1427704836-8776-16-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36032 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbbC3IkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:40:01 -0400
Received: by padcy3 with SMTP id cy3so160671588pad.3
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:40:00 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9510525..b65c634 100644
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
@@ -4173,7 +4161,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= swdev_port_bridge_setlink,
-	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
+	.ndo_bridge_getlink		= swdev_port_bridge_getlink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
 
-- 
1.7.10.4
