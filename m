From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: do not use -ENOENT
Date: Thu, 17 Jan 2013 11:25:00 +0100
Message-ID: <1358418300-2346-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36142 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759493Ab3AQKZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 05:25:07 -0500
Received: by mail-wg0-f48.google.com with SMTP id 16so636299wgi.27
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 02:25:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this error code means "No such file or directory", change this
value in team driver to ones which make more sense.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c                   | 4 ++--
 drivers/net/team/team_mode_activebackup.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 70d5d6b..3d7cf6e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1128,7 +1128,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	if (!port || !team_port_find(team, port)) {
 		netdev_err(dev, "Device %s does not act as a port of this team\n",
 			   portname);
-		return -ENOENT;
+		return -ENODEV;
 	}
 
 	__team_option_inst_mark_removed_port(team, port);
@@ -2320,7 +2320,7 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 			list_add(&opt_inst->tmp_list, &opt_inst_list);
 		}
 		if (!opt_found) {
-			err = -ENOENT;
+			err = -EINVAL;
 			goto team_put;
 		}
 	}
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 6262b4d..2792e13 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -81,7 +81,7 @@ static int ab_active_port_set(struct team *team, struct team_gsetter_ctx *ctx)
 			return 0;
 		}
 	}
-	return -ENOENT;
+	return -ENODEV;
 }
 
 static const struct team_option ab_options[] = {
-- 
1.8.1
