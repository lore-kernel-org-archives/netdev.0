From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 05/19] team: allow read/write-only options
Date: Tue, 19 Jun 2012 17:54:07 +0200
Message-ID: <1340121261-2966-6-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:33 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dea2d8a..f50b8ca 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -346,6 +346,8 @@ static int team_option_get(struct team *team,
 			   struct team_option_inst *opt_inst,
 			   struct team_gsetter_ctx *ctx)
 {
+	if (!opt_inst->option->getter)
+		return -EOPNOTSUPP;
 	return opt_inst->option->getter(team, ctx);
 }
 
@@ -355,6 +357,8 @@ static int team_option_set(struct team *team,
 {
 	int err;
 
+	if (!opt_inst->option->setter)
+		return -EOPNOTSUPP;
 	err = opt_inst->option->setter(team, ctx);
 	if (err)
 		return err;
-- 
1.7.10.2
