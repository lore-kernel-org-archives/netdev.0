From: Kenneth Williams <ken@williamsclan.us>
Subject: [PATCH] team: Remove dead code
Date: Sun, 11 Jan 2015 16:43:54 -0800
Message-ID: <20150112004351.GA8744@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa07-07.prod.phx3.secureserver.net ([173.201.192.236]:35632
	"EHLO p3plsmtpa07-07.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbbALAvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 19:51:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The deleted lines are called from a function which is called:
1) Only through __team_options_register via team_options_register and
2) Only during initialization / mode initialization when there are no
ports attached.
Therefore the ports list is guarenteed to be empty and this code will
never be executed.

Signed-off-by: Kenneth Williams <ken@williamsclan.us>
---
 drivers/net/team/team.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 93e2242..43bcfff 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -176,7 +176,6 @@ static int __team_option_inst_add(struct team *team, struct team_option *option,
 static int __team_option_inst_add_option(struct team *team,
 					 struct team_option *option)
 {
-	struct team_port *port;
 	int err;
 
 	if (!option->per_port) {
@@ -184,12 +183,6 @@ static int __team_option_inst_add_option(struct team *team,
 		if (err)
 			goto inst_del_option;
 	}
-
-	list_for_each_entry(port, &team->port_list, list) {
-		err = __team_option_inst_add(team, option, port);
-		if (err)
-			goto inst_del_option;
-	}
 	return 0;
 
 inst_del_option:
-- 
1.7.9.5
