From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] rocker: free netdevice during netdevice removal
Date: Sun,  2 Aug 2015 19:29:16 +0200
Message-ID: <1438536556-13154-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com,
	Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37150 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbbHBR3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 13:29:19 -0400
Received: by wibud3 with SMTP id ud3so86879611wib.0
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 10:29:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a port's netdevice in 'rocker_remove_ports', we should
also free the allocated 'net_device' structure. Do that by calling
'free_netdev' after unregistering it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Fixes: 4b8ac9660af ("rocker: introduce rocker switch driver")
---
 drivers/net/ethernet/rocker/rocker.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7b4c347..1d0f140 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4923,6 +4923,7 @@ static void rocker_remove_ports(const struct rocker *rocker)
 		rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
 				   ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
+		free_netdev(rocker_port->dev);
 	}
 	kfree(rocker->ports);
 }
-- 
1.9.3
