From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/3] team: fix checks in team_get_first_port_txable_rcu()
Date: Sat,  8 Jun 2013 15:00:55 +0200
Message-ID: <1370696455-12221-4-git-send-email-jiri@resnulli.us>
References: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:62358 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3FHNBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 09:01:07 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so1389905eek.21
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:01:06 -0700 (PDT)
In-Reply-To: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

should be checked if "cur" is txable, not "port".

Introduced by commit 6e88e1357c "team: use function team_port_txable()
for determing enabled and up port"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_team.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 4474557..16fae64 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -249,12 +249,12 @@ team_get_first_port_txable_rcu(struct team *team, struct team_port *port)
 		return port;
 	cur = port;
 	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
-		if (team_port_txable(port))
+		if (team_port_txable(cur))
 			return cur;
 	list_for_each_entry_rcu(cur, &team->port_list, list) {
 		if (cur == port)
 			break;
-		if (team_port_txable(port))
+		if (team_port_txable(cur))
 			return cur;
 	}
 	return NULL;
-- 
1.7.11.7
