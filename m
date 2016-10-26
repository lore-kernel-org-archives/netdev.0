From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net_sched actions: use nla_parse_nested()
Date: Wed, 26 Oct 2016 14:44:33 +0200
Message-ID: <1477485873-32598-1-git-send-email-johannes@sipsolutions.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52046 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942418AbcJZMoj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 08:44:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Use nla_parse_nested instead of open-coding the call to
nla_parse() with the attribute data/len.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/sched/act_api.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index c9102172ce3b..ef89ec1d51fb 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1025,8 +1025,7 @@ static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
 
 	if (tb[1] == NULL)
 		return NULL;
-	if (nla_parse(tb2, TCA_ACT_MAX, nla_data(tb[1]),
-		      nla_len(tb[1]), NULL) < 0)
+	if (nla_parse_nested(tb2, TCA_ACT_MAX, tb[1], NULL) < 0)
 		return NULL;
 	kind = tb2[TCA_ACT_KIND];
 
-- 
2.8.1
