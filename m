From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net next] team: remove team parameter from port_enter callback.
Date: Thu,  6 Dec 2012 15:09:42 +0200
Message-ID: <1354799382-23808-1-git-send-email-ramirose@gmail.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36337 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab2LFNKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 08:10:42 -0500
Received: by mail-wi0-f174.google.com with SMTP id hm9so590291wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 05:10:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an unused parameter (team) from port_enter callback in 
team_mode_ops and fixes accordingly its invocations in 3 modes and in team.c.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/team/team.c                  | 2 +-
 drivers/net/team/team_mode_broadcast.c   | 2 +-
 drivers/net/team/team_mode_loadbalance.c | 2 +-
 drivers/net/team/team_mode_roundrobin.c  | 2 +-
 include/linux/if_team.h                  | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ad86660..4203808 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -887,7 +887,7 @@ static int team_port_enter(struct team *team, struct team_port *port)
 	dev_hold(team->dev);
 	port->dev->priv_flags |= IFF_TEAM_PORT;
 	if (team->ops.port_enter) {
-		err = team->ops.port_enter(team, port);
+		err = team->ops.port_enter(port);
 		if (err) {
 			netdev_err(team->dev, "Device %s failed to enter team mode\n",
 				   port->dev->name);
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index c5db428..c3840bc 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -46,7 +46,7 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
 	return sum_ret;
 }
 
-static int bc_port_enter(struct team *team, struct team_port *port)
+static int bc_port_enter(struct team_port *port)
 {
 	return team_port_set_team_dev_addr(port);
 }
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index cdc31b5..1e84c77 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -614,7 +614,7 @@ static void lb_exit(struct team *team)
 	kfree(lb_priv->ex);
 }
 
-static int lb_port_enter(struct team *team, struct team_port *port)
+static int lb_port_enter(struct team_port *port)
 {
 	struct lb_port_priv *lb_port_priv = get_lb_port_priv(port);
 
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 105135a..abe889e 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -64,7 +64,7 @@ drop:
 	return false;
 }
 
-static int rr_port_enter(struct team *team, struct team_port *port)
+static int rr_port_enter(struct team_port *port)
 {
 	return team_port_set_team_dev_addr(port);
 }
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 0245def..3366453 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -105,7 +105,7 @@ struct team_mode_ops {
 				       struct team_port *port,
 				       struct sk_buff *skb);
 	bool (*transmit)(struct team *team, struct sk_buff *skb);
-	int (*port_enter)(struct team *team, struct team_port *port);
+	int (*port_enter)(struct team_port *port);
 	void (*port_leave)(struct team *team, struct team_port *port);
 	void (*port_change_dev_addr)(struct team *team, struct team_port *port);
 	void (*port_enabled)(struct team *team, struct team_port *port);
-- 
1.7.11.7
