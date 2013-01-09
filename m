From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 6/6] unix: Use FIELD_SIZEOF() in af_unix_init().
Date: Thu, 10 Jan 2013 02:20:07 +0900
Message-ID: <50EDA6C7.30205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60730 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:20:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/unix/af_unix.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..0c61236 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2426,9 +2426,8 @@ static struct pernet_operations unix_net_ops = {
 static int __init af_unix_init(void)
 {
 	int rc = -1;
-	struct sk_buff *dummy_skb;
 
-	BUILD_BUG_ON(sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb));
+	BUILD_BUG_ON(sizeof(struct unix_skb_parms) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	rc = proto_register(&unix_proto, 1);
 	if (rc != 0) {
-- 
1.7.9.5
