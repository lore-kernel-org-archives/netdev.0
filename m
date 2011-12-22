From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] netlink: wake up netlink listeners sooner (v2)
Date: Thu, 22 Dec 2011 10:52:03 -0800
Message-ID: <20111222185217.507023273@vyatta.com>
References: <20111222185201.592156795@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:49593 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753163Ab1LVSxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 13:53:47 -0500
Content-Disposition: inline; filename=netlink-congest.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes it to yield sooner at halfway instead. Still not a cure-all
for listener overrun if listner is slow, but works much reliably.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - use shift to avoid expensive integer division

--- a/net/netlink/af_netlink.c	2011-12-21 15:15:09.446373421 -0800
+++ b/net/netlink/af_netlink.c	2011-12-21 15:22:35.632062577 -0800
@@ -959,7 +959,7 @@ static int netlink_broadcast_deliver(str
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
-		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf;
+		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
 	}
 	return -1;
 }
