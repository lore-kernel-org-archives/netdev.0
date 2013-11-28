From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net/stable] team: fix master carrier set when user linkup is enabled
Date: Thu, 28 Nov 2013 18:01:38 +0100
Message-ID: <1385658098-21653-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jtluka@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:52101 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab3K1RBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:01:41 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so5933558ead.6
        for <netdev@vger.kernel.org>; Thu, 28 Nov 2013 09:01:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When user linkup is enabled and user sets linkup of individual port,
we need to recompute linkup (carrier) of master interface so the change
is reflected. Fix this by calling __team_carrier_check() which does the
needed work.

Please apply to all stable kernels as well. Thanks.

Reported-by: Jan Tluka <jtluka@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 34b0de0..736050d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1366,6 +1366,8 @@ static int team_user_linkup_option_get(struct team *team,
 	return 0;
 }
 
+static void __team_carrier_check(struct team *team);
+
 static int team_user_linkup_option_set(struct team *team,
 				       struct team_gsetter_ctx *ctx)
 {
@@ -1373,6 +1375,7 @@ static int team_user_linkup_option_set(struct team *team,
 
 	port->user.linkup = ctx->data.bool_val;
 	team_refresh_port_linkup(port);
+	__team_carrier_check(port->team);
 	return 0;
 }
 
@@ -1392,6 +1395,7 @@ static int team_user_linkup_en_option_set(struct team *team,
 
 	port->user.linkup_enabled = ctx->data.bool_val;
 	team_refresh_port_linkup(port);
+	__team_carrier_check(port->team);
 	return 0;
 }
 
-- 
1.8.3.1
