From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 6/7] rtnetlink: link ops lookup must occur with rtnl lock held
Date: Thu, 21 Sep 2017 18:59:01 +0200
Message-ID: <20170921165902.10746-7-fw@strlen.de>
References: <20170921165902.10746-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39128 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751738AbdIUQ7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:59:05 -0400
In-Reply-To: <20170921165902.10746-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

all callers meet this requirement, this serves as reminder to not
forget about this in future rtnl pushdown work.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7503021fe308..7af9774aec40 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -274,6 +274,8 @@ static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
 {
 	const struct rtnl_link_ops *ops;
 
+	ASSERT_RTNL();
+
 	list_for_each_entry(ops, &link_ops, list) {
 		if (!strcmp(ops->kind, kind))
 			return ops;
@@ -1618,6 +1620,8 @@ static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla
 	const struct rtnl_link_ops *ops = NULL;
 	struct nlattr *linfo[IFLA_INFO_MAX + 1];
 
+	ASSERT_RTNL();
+
 	if (nla_parse_nested(linfo, IFLA_INFO_MAX, nla,
 			     ifla_info_policy, NULL) < 0)
 		return NULL;
-- 
2.13.5
