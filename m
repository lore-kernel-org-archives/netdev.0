From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: show pmtu in route list
Date: Fri, 20 Jul 2012 12:02:08 +0300
Message-ID: <1342774928-29301-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59079 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab2GTIzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 04:55:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Override the metrics with rt_pmtu

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Is this patch still useful if routing cache is removed?

 net/ipv4/route.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9f7ffbe..d547f6f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2909,6 +2909,7 @@ static int rt_fill_info(struct net *net,
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
 	u32 error;
+	u32 metrics[RTAX_MAX];
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
@@ -2953,7 +2954,10 @@ static int rt_fill_info(struct net *net,
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
-	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
+	memcpy(metrics, dst_metrics_ptr(&rt->dst), sizeof(metrics));
+	if (rt->rt_pmtu)
+		metrics[RTAX_MTU - 1] = rt->rt_pmtu;
+	if (rtnetlink_put_metrics(skb, metrics) < 0)
 		goto nla_put_failure;
 
 	if (rt->rt_mark &&
-- 
1.7.3.4
