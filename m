From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 7/7] rocker: remove nowait from switchdev callbacks.
Date: Mon, 12 Oct 2015 17:45:50 +0200
Message-ID: <1444664750-11260-8-git-send-email-jiri@resnulli.us>
References: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37862 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbJLPqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:46:01 -0400
Received: by wijq8 with SMTP id q8so64058076wij.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 08:46:00 -0700 (PDT)
In-Reply-To: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

No need to avoid sleeping in switchdev callbacks now, as the switchdev
core allows it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index bb956a5..9629c5b5 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3672,7 +3672,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 	    rocker_port->stp_state == BR_STATE_FORWARDING)
 		return 0;
 
-	flags |= ROCKER_OP_FLAG_REMOVE;
+	flags |= ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
 
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 
@@ -4382,8 +4382,7 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, trans,
-					     ROCKER_OP_FLAG_NOWAIT,
+		err = rocker_port_stp_update(rocker_port, trans, 0,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
@@ -4517,7 +4516,7 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 			       const struct switchdev_obj_port_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
-	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
+	int flags = ROCKER_OP_FLAG_REMOVE;
 
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
-- 
1.9.3
