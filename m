From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 3/6] netlink: Use FIELD_SIZEOF() in netlink_proto_init().
Date: Thu, 10 Jan 2013 02:19:48 +0900
Message-ID: <50EDA6B4.2060003@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60720 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:19:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/netlink/af_netlink.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c0353d5..74827e3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2185,7 +2185,6 @@ static struct pernet_operations __net_initdata netlink_net_ops = {
 
 static int __init netlink_proto_init(void)
 {
-	struct sk_buff *dummy_skb;
 	int i;
 	unsigned long limit;
 	unsigned int order;
@@ -2194,7 +2193,7 @@ static int __init netlink_proto_init(void)
 	if (err != 0)
 		goto out;
 
-	BUILD_BUG_ON(sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb));
+	BUILD_BUG_ON(sizeof(struct netlink_skb_parms) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
 	if (!nl_table)
-- 
1.7.9.5
