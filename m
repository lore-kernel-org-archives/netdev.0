From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]ipv6:When we droped a package,we should return NET_RX_DROP
 instead of 0
Date: Fri, 29 Aug 2008 15:40:17 +0800
Message-ID: <48B7A7E1.70307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49821 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYH2Hkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:40:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we droped a package,we should return NET_RX_DROP instead of 0

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 net/ipv6/raw.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 01d4767..e53e493 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -377,14 +377,14 @@ static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 	    skb_checksum_complete(skb)) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
-		return 0;
+		return NET_RX_DROP;
 	}
 
 	/* Charge it to the socket. */
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
-		return 0;
+		return NET_RX_DROP;
 	}
 
 	return 0;
@@ -429,7 +429,7 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 		if (skb_checksum_complete(skb)) {
 			atomic_inc(&sk->sk_drops);
 			kfree_skb(skb);
-			return 0;
+			return NET_RX_DROP;
 		}
 	}
 
-- 
1.5.3.8


