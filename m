From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 5/6] rxrpc: Use FIELD_SIZEOF() in af_rxrpc_init().
Date: Thu, 10 Jan 2013 02:20:01 +0900
Message-ID: <50EDA6C1.20108@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60727 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:20:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/rxrpc/af_rxrpc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 05996d0..5b0fd29 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/kernel.h>
 #include <linux/net.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
@@ -792,10 +793,9 @@ static const struct net_proto_family rxrpc_family_ops = {
  */
 static int __init af_rxrpc_init(void)
 {
-	struct sk_buff *dummy_skb;
 	int ret = -1;
 
-	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > sizeof(dummy_skb->cb));
+	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	rxrpc_epoch = htonl(get_seconds());
 
-- 
1.7.9.5
