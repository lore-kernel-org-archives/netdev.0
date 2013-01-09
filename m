From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 2/6] ipv6: Use FIELD_SIZEOF() in inet6_init().
Date: Thu, 10 Jan 2013 02:19:43 +0900
Message-ID: <50EDA6AF.7020509@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60717 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/af_inet6.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b043c60..6b793bf 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -811,11 +811,10 @@ static struct pernet_operations inet6_net_ops = {
 
 static int __init inet6_init(void)
 {
-	struct sk_buff *dummy_skb;
 	struct list_head *r;
 	int err = 0;
 
-	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));
+	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	/* Register the socket-side information for inet6_create.  */
 	for (r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
-- 
1.7.9.5
