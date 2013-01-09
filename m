From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 1/6] ipv4: Use FIELD_SIZEOF() in inet_init().
Date: Thu, 10 Jan 2013 02:19:37 +0900
Message-ID: <50EDA6A9.9060707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60714 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:19:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/af_inet.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 24b384b..4fdf967 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1705,12 +1705,11 @@ static struct packet_type ip_packet_type __read_mostly = {
 
 static int __init inet_init(void)
 {
-	struct sk_buff *dummy_skb;
 	struct inet_protosw *q;
 	struct list_head *r;
 	int rc = -EINVAL;
 
-	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
+	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
 	if (!sysctl_local_reserved_ports)
-- 
1.7.9.5
