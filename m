From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] teamd: don't print warn message on -ESRCH during event send
Date: Thu, 23 Aug 2012 15:26:51 +0200
Message-ID: <1345728413-10298-2-git-send-email-jiri@resnulli.us>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, brouer@redhat.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39327 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933870Ab2HWN1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:27:17 -0400
Received: by wibhr14 with SMTP id hr14so945258wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 06:27:16 -0700 (PDT)
In-Reply-To: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When no one is listening on NL socket, -ESRCH is returned and warning
message is printed. This message is confusing people and in fact has no
meaning. So do not print it in this case.

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 17ce11b..4010bcd 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2487,7 +2487,7 @@ static void __team_options_change_check(struct team *team)
 			list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
 	}
 	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
-	if (err)
+	if (err && err != -ESRCH)
 		netdev_warn(team->dev, "Failed to send options change via netlink (err %d)\n",
 			    err);
 }
@@ -2518,9 +2518,9 @@ static void __team_port_change_check(struct team_port *port, bool linkup)
 
 send_event:
 	err = team_nl_send_event_port_list_get(port->team);
-	if (err)
-		netdev_warn(port->team->dev, "Failed to send port change of device %s via netlink\n",
-			    port->dev->name);
+	if (err && err != -ESRCH)
+		netdev_warn(port->team->dev, "Failed to send port change of device %s via netlink (err %d)\n",
+			    port->dev->name, err);
 
 }
 
-- 
1.7.11.4
