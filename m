From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: Print error value when skb allocation fails
Date: Mon,  1 Jun 2009 14:47:53 -0400
Message-ID: <1243882073-15335-1-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:10122 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbZFASrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 14:47:53 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print-out the error value when sock_alloc_send_skb() fails in
the IPv6 neighbor discovery code - can be useful for debugging.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 net/ipv6/ndisc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e09f12e..1d13d99 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,8 +465,8 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 ND: %s() failed to allocate an skb.\n",
-			   __func__);
+			   "ICMPv6 ND: %s() failed to allocate an skb, err=%d.\n",
+			   __func__, err);
 		return NULL;
 	}
 
@@ -1562,8 +1562,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 Redirect: %s() failed to allocate an skb.\n",
-			   __func__);
+			   "ICMPv6 Redirect: %s() failed to allocate an skb, err=%d.\n",
+			   __func__, err);
 		goto release;
 	}
 
-- 
1.5.4.3

