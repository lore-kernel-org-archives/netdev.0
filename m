From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] ip_vti: remove the useless err_count check in vti_xmit
Date: Sat, 28 Oct 2017 19:46:21 +0800
Message-ID: <b28eef283ea7622e74a930cc708489fa9c1139c7.1509191181.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Saurabh <saurabh.mohan@vyatta.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:50328 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdJ1Lq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:46:29 -0400
Received: by mail-pf0-f193.google.com with SMTP id b6so6884488pfh.7
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 04:46:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ipip and gre, ip_vti never uses err_count in vti4_err,
so no need to check err_count in vti_xmit, it's value always 0.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_vti.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 58465c0..949f432 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -198,15 +198,6 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tunnel->err_count > 0) {
-		if (time_before(jiffies,
-				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
-			tunnel->err_count--;
-			dst_link_failure(skb);
-		} else
-			tunnel->err_count = 0;
-	}
-
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-- 
2.1.0
