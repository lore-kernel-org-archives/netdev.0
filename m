From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 10/19] team: fix error path in team_nl_fill_options_get()
Date: Tue, 19 Jun 2012 17:54:12 +0200
Message-ID: <1340121261-2966-11-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688Ab2FSPyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:40 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

genlmsg_cancel() needs to be called in case nest fails

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 7988ba0..82ded18 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1583,7 +1583,7 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 		goto nla_put_failure;
 	option_list = nla_nest_start(skb, TEAM_ATTR_LIST_OPTION);
 	if (!option_list)
-		return -EMSGSIZE;
+		goto nla_put_failure;
 
 	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
 		struct nlattr *option_item;
-- 
1.7.10.2
