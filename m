From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] team: use kfree_rcu instead of synchronize_rcu in team_port_dev
Date: Mon, 10 Jun 2013 17:42:24 +0200
Message-ID: <1370878945-9718-3-git-send-email-jiri@resnulli.us>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:51327 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab3FJPnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:43:00 -0400
Received: by mail-ea0-f170.google.com with SMTP id h10so5684645eaj.1
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:42:59 -0700 (PDT)
In-Reply-To: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 3 +--
 include/linux/if_team.h | 1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f00446e..4982aed 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1192,8 +1192,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 
 	team_port_set_orig_dev_addr(port);
 	dev_set_mtu(port_dev, port->orig.mtu);
-	synchronize_rcu();
-	kfree(port);
+	kfree_rcu(port, rcu);
 	netdev_info(dev, "Port device %s removed\n", portname);
 	__team_compute_features(team);
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 16fae64..556b791 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -69,6 +69,7 @@ struct team_port {
 	s32 priority; /* lower number ~ higher priority */
 	u16 queue_id;
 	struct list_head qom_list; /* node in queue override mapping list */
+	struct rcu_head	rcu;
 	long mode_priv[0];
 };
 
-- 
1.8.1.4
