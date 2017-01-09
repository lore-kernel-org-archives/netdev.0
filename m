From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 7/7] net: ipv4: Remove event arg to rt_fill_info
Date: Mon,  9 Jan 2017 13:32:51 -0800
Message-ID: <1483997571-3964-8-git-send-email-dsa@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34229 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941436AbdAIVdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:33:02 -0500
Received: by mail-pf0-f173.google.com with SMTP id 127so34073750pfg.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:33:02 -0800 (PST)
In-Reply-To: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_fill_info has 1 caller with the event set to RTM_NEWROUTE. Given that
remove the arg and use RTM_NEWROUTE directly in rt_fill_info.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9f44b869b8a6..b34f79ffb11d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2471,8 +2471,7 @@ EXPORT_SYMBOL_GPL(ip_route_output_flow);
 /* called with rcu_read_lock held */
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq, int event, struct rtable *rt,
-			struct fib_result *res)
+			u32 seq, struct rtable *rt, struct fib_result *res)
 {
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
@@ -2480,7 +2479,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	u32 error;
 	u32 metrics[RTAX_MAX];
 
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), 0);
+	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*r), 0);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -2711,8 +2710,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		table_id = rt->rt_table_id;
 
 	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
-			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			   RTM_NEWROUTE, rt, &res);
+			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, rt, &res);
 	if (err < 0)
 		goto errout_free;
 
-- 
2.1.4
