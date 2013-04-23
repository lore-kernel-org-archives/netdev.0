From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next] net: fix address check in rtnl_fdb_del
Date: Tue, 23 Apr 2013 17:05:23 -0400
Message-ID: <1366751123-10143-1-git-send-email-vyasevic@redhat.com>
Cc: dlstevens@us.ibm.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394Ab3DWVFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 17:05:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6681712d67eef14c4ce793561c3231659153a320
	vxlan: generalize forwarding tables

relaxed the address checks in rtnl_fdb_del() to use is_zero_ether_addr().
This allows users to add multicast addresses using the fdb API.  However,
the check in rtnl_fdb_del() still uses a more strict
is_valid_ether_addr() which rejects multicast addresses.  Thus it
is possible to add an fdb that can not be later removed.
Relax the check in rtnl_fdb_del() as well.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 18af08a..2c54cc1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2192,7 +2192,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
-	if (!is_valid_ether_addr(addr)) {
+	if (is_zero_ether_addr(addr)) {
 		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether address\n");
 		return -EINVAL;
 	}
-- 
1.8.1.4
