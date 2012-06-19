From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 14/19] team: add port_[enabled/disabled] mode callbacks
Date: Tue, 19 Jun 2012 17:54:16 +0200
Message-ID: <1340121261-2966-15-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab2FSPyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:47 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    4 ++++
 include/linux/if_team.h |    2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index eb18ac9..bc76f94 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -714,6 +714,8 @@ static void team_port_enable(struct team *team,
 	port->index = team->en_port_count++;
 	hlist_add_head_rcu(&port->hlist,
 			   team_port_index_hash(team, port->index));
+	if (team->ops.port_enabled)
+		team->ops.port_enabled(team, port);
 }
 
 static void __reconstruct_port_hlist(struct team *team, int rm_index)
@@ -737,6 +739,8 @@ static void team_port_disable(struct team *team,
 
 	if (!team_port_enabled(port))
 		return;
+	if (team->ops.port_disabled)
+		team->ops.port_disabled(team, port);
 	hlist_del_rcu(&port->hlist);
 	__reconstruct_port_hlist(team, rm_index);
 	team->en_port_count--;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 2f29725..c193886 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -74,6 +74,8 @@ struct team_mode_ops {
 	int (*port_enter)(struct team *team, struct team_port *port);
 	void (*port_leave)(struct team *team, struct team_port *port);
 	void (*port_change_mac)(struct team *team, struct team_port *port);
+	void (*port_enabled)(struct team *team, struct team_port *port);
+	void (*port_disabled)(struct team *team, struct team_port *port);
 };
 
 enum team_option_type {
-- 
1.7.10.2
