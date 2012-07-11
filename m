From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/3] team: make team_port_enabled() and team_port_txable() static inline
Date: Wed, 11 Jul 2012 17:34:04 +0200
Message-ID: <1342020844-3547-4-git-send-email-jpirko@redhat.com>
References: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758139Ab2GKPeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 11:34:13 -0400
In-Reply-To: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   12 ------------
 include/linux/if_team.h |   11 +++++++++--
 2 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bc7afa5..3620c63 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -671,18 +671,6 @@ static bool team_port_find(const struct team *team,
 	return false;
 }
 
-bool team_port_enabled(struct team_port *port)
-{
-	return port->index != -1;
-}
-EXPORT_SYMBOL(team_port_enabled);
-
-bool team_port_txable(struct team_port *port)
-{
-	return port->linkup && team_port_enabled(port);
-}
-EXPORT_SYMBOL(team_port_txable);
-
 /*
  * Enable/disable port by adding to enabled port hashlist and setting
  * port->index (Might be racy so reader could see incorrect ifindex when
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index dca426c..dfa0c8e 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -63,8 +63,15 @@ struct team_port {
 	long mode_priv[0];
 };
 
-extern bool team_port_enabled(struct team_port *port);
-extern bool team_port_txable(struct team_port *port);
+static inline bool team_port_enabled(struct team_port *port)
+{
+	return port->index != -1;
+}
+
+static inline bool team_port_txable(struct team_port *port)
+{
+	return port->linkup && team_port_enabled(port);
+}
 
 struct team_mode_ops {
 	int (*init)(struct team *team);
-- 
1.7.10.4
