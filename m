From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] team: add per port priority option
Date: Fri, 27 Jul 2012 18:28:54 +0200
Message-ID: <1343406535-22388-4-git-send-email-jiri@resnulli.us>
References: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60369 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab2G0Q3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:29:07 -0400
Received: by wibhm11 with SMTP id hm11so7639084wib.1
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:29:06 -0700 (PDT)
In-Reply-To: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow userspace to set port priority.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |   25 +++++++++++++++++++++++++
 include/linux/if_team.h |    1 +
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 70752e6..a30b7c1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1092,6 +1092,24 @@ static int team_user_linkup_en_option_set(struct team *team,
 	return 0;
 }
 
+static int team_priority_option_get(struct team *team,
+				    struct team_gsetter_ctx *ctx)
+{
+	struct team_port *port = ctx->info->port;
+
+	ctx->data.s32_val = port->priority;
+	return 0;
+}
+
+static int team_priority_option_set(struct team *team,
+				    struct team_gsetter_ctx *ctx)
+{
+	struct team_port *port = ctx->info->port;
+
+	port->priority = ctx->data.s32_val;
+	return 0;
+}
+
 static const struct team_option team_options[] = {
 	{
 		.name = "mode",
@@ -1120,6 +1138,13 @@ static const struct team_option team_options[] = {
 		.getter = team_user_linkup_en_option_get,
 		.setter = team_user_linkup_en_option_set,
 	},
+	{
+		.name = "priority",
+		.type = TEAM_OPTION_TYPE_S32,
+		.per_port = true,
+		.getter = team_priority_option_get,
+		.setter = team_priority_option_set,
+	},
 };
 
 static struct lock_class_key team_netdev_xmit_lock_key;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index e5571c4..06495b3 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -67,6 +67,7 @@ struct team_port {
 	struct netpoll *np;
 #endif
 
+	s32 priority; /* lower number ~ higher priority */
 	long mode_priv[0];
 };
 
-- 
1.7.10.4
