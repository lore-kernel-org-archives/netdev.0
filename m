From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/15]: act_api: use nlmsg_parse
Date: Wed, 23 Jan 2008 17:36:41 +0100 (MET)
Message-ID: <20080123163600.6459.57307.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49722 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbYAWQgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:43 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: act_api: use nlmsg_parse

Convert open-coded nlmsg_parse to use the real function.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f9f9cbaccb1a58ea02318250192effe1e2e1e715
tree 7ea770493ca465a7aac1a7779b2aa4c593de3a97
parent 512b2ab20730e1d24e36fb94eab4a2731e90e315
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:10:31 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:10:31 +0100

 net/sched/act_api.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ae077ed..2fe0345 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -984,11 +984,8 @@ find_dump_kind(struct nlmsghdr *n)
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct nlattr *nla[TCAA_MAX + 1];
 	struct nlattr *kind;
-	int min_len = NLMSG_LENGTH(sizeof(struct tcamsg));
-	int attrlen = n->nlmsg_len - NLMSG_ALIGN(min_len);
-	struct nlattr *attr = (void *) n + NLMSG_ALIGN(min_len);
 
-	if (nla_parse(nla, TCAA_MAX, attr, attrlen, NULL) < 0)
+	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX, NULL) < 0)
 		return NULL;
 	tb1 = nla[TCA_ACT_TAB];
 	if (tb1 == NULL)
