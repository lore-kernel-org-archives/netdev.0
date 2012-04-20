From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/3] team: add per-port option for enabling/disabling ports
Date: Fri, 20 Apr 2012 16:42:06 +0200
Message-ID: <1334932926-23996-4-git-send-email-jpirko@redhat.com>
References: <1334932926-23996-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27628 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881Ab2DTOmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 10:42:18 -0400
In-Reply-To: <1334932926-23996-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index fe7ca40..c61ae35 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -904,6 +904,23 @@ static int team_mode_option_set(struct team *team, struct team_gsetter_ctx *ctx)
 	return team_change_mode(team, ctx->data.str_val);
 }
 
+static int team_port_en_option_get(struct team *team,
+				   struct team_gsetter_ctx *ctx)
+{
+	ctx->data.bool_val = team_port_enabled(ctx->port);
+	return 0;
+}
+
+static int team_port_en_option_set(struct team *team,
+				   struct team_gsetter_ctx *ctx)
+{
+	if (ctx->data.bool_val)
+		team_port_enable(team, ctx->port);
+	else
+		team_port_disable(team, ctx->port);
+	return 0;
+}
+
 static int team_user_linkup_option_get(struct team *team,
 				       struct team_gsetter_ctx *ctx)
 {
@@ -946,6 +963,13 @@ static const struct team_option team_options[] = {
 		.setter = team_mode_option_set,
 	},
 	{
+		.name = "enabled",
+		.type = TEAM_OPTION_TYPE_BOOL,
+		.per_port = true,
+		.getter = team_port_en_option_get,
+		.setter = team_port_en_option_set,
+	},
+	{
 		.name = "user_linkup",
 		.type = TEAM_OPTION_TYPE_BOOL,
 		.per_port = true,
-- 
1.7.9.1
