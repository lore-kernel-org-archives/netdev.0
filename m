From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/8] net: ipv4: Remove event arg to rt_fill_info
Date: Thu, 25 May 2017 10:42:35 -0700
Message-ID: <1495734160-47659-4-git-send-email-roopa@cumulusnetworks.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net, dsahern@gmail.com, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36711 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969989AbdEYRnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:43:06 -0400
Received: by mail-pf0-f181.google.com with SMTP id m17so173583142pfg.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 10:43:06 -0700 (PDT)
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>

rt_fill_info has 1 caller with the event set to RTM_NEWROUTE. Given that
remove the arg and use RTM_NEWROUTE directly in rt_fill_info.

Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/route.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1dc8fd1..d8fcecc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2536,7 +2536,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq, int event)
+			u32 seq)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
@@ -2545,7 +2545,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	u32 error;
 	u32 metrics[RTAX_MAX];
 
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), 0);
+	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*r), 0);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -2745,8 +2745,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		table_id = rt->rt_table_id;
 
 	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
-			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			   RTM_NEWROUTE);
+			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq);
 	if (err < 0)
 		goto errout_free;
 
-- 
1.9.1
