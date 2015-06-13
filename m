From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: gaurd against NULL rocker_port when removing ports
Date: Fri, 12 Jun 2015 21:09:44 -0700
Message-ID: <1434168584-61990-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38263 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbFMEHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:07:51 -0400
Received: by igblz2 with SMTP id lz2so21690237igb.1
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:07:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The ports array is filled in as ports are probed, but if probing doesn't
finish, we need to stop only those ports that where probed successfully.
Check the ports array for NULL to skip un-probed ports when stopping.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 819289e..c6a6e3c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4802,6 +4802,8 @@ static void rocker_remove_ports(const struct rocker *rocker)
 
 	for (i = 0; i < rocker->port_count; i++) {
 		rocker_port = rocker->ports[i];
+		if (!rocker_port)
+			continue;
 		rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
 				   ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
-- 
1.7.10.4
