From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/34] netfilter: ipset: Fix static checker warning in ip_set_core.c
Date: Mon, 29 Sep 2014 14:38:54 +0200
Message-ID: <1411994363-8451-6-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34040 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbaI2MiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:24 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Dan Carpenter reported the following static checker warning:

        net/netfilter/ipset/ip_set_core.c:1414 call_ad()
        error: 'nlh->nlmsg_len' from user is not capped properly

The payload size is limited now by the max size of size_t.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 5593e97..4ca4e5c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1397,7 +1397,8 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		struct nlmsghdr *rep, *nlh = nlmsg_hdr(skb);
 		struct sk_buff *skb2;
 		struct nlmsgerr *errmsg;
-		size_t payload = sizeof(*errmsg) + nlmsg_len(nlh);
+		size_t payload = min(SIZE_MAX,
+				     sizeof(*errmsg) + nlmsg_len(nlh));
 		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 		struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 		struct nlattr *cmdattr;
-- 
1.7.10.4
