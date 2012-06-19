From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 03/19] team: add mode priv to port
Date: Tue, 19 Jun 2012 17:54:05 +0200
Message-ID: <1340121261-2966-4-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754580Ab2FSPy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:29 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    3 ++-
 include/linux/if_team.h |    2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 343f4ff..dea2d8a 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -793,7 +793,8 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		return -EBUSY;
 	}
 
-	port = kzalloc(sizeof(struct team_port), GFP_KERNEL);
+	port = kzalloc(sizeof(struct team_port) + team->mode->port_priv_size,
+		       GFP_KERNEL);
 	if (!port)
 		return -ENOMEM;
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index d45fcd5..54af95f 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -61,6 +61,7 @@ struct team_port {
 	} orig;
 
 	struct rcu_head rcu;
+	long mode_priv[0];
 };
 
 struct team_mode_ops {
@@ -108,6 +109,7 @@ struct team_mode {
 	const char *kind;
 	struct module *owner;
 	size_t priv_size;
+	size_t port_priv_size;
 	const struct team_mode_ops *ops;
 };
 
-- 
1.7.10.2
