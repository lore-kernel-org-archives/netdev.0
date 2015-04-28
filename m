From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/3] bridge/mdb: remove wrong use of NLM_F_MULTI
Date: Tue, 28 Apr 2015 18:33:48 +0200
Message-ID: <1430238831-29966-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyaginuug.ch@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35194 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030297AbbD1QeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 12:34:08 -0400
In-Reply-To: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NLM_F_MULTI must be used only when a NLMSG_DONE message is sent. In fact,
it is sent only at the end of a dump.

Libraries like libnl will wait forever for NLMSG_DONE.

Fixes: 37a393bc4932 ("bridge: notify mdb changes via netlink")
CC: Cong Wang <amwang@redhat.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: bridge@lists.linux-foundation.org
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/bridge/br_mdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 409608960899..e29ad70b3000 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -170,7 +170,7 @@ static int nlmsg_populate_mdb_fill(struct sk_buff *skb,
 	struct br_port_msg *bpm;
 	struct nlattr *nest, *nest2;
 
-	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*bpm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*bpm), 0);
 	if (!nlh)
 		return -EMSGSIZE;
 
-- 
2.2.2
