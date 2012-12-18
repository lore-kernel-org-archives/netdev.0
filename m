From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 10/17] ndisc: Reset skb->transport_header inside
 ndisc_alloc_send_skb().
Date: Tue, 18 Dec 2012 19:55:28 +0900
Message-ID: <50D04BA0.2000305@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56626 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754066Ab2LRKz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:55:29 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2ebb2fb..073e52a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -392,6 +392,8 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	skb->dev = dev;
 
 	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
+	skb_reset_transport_header(skb);
+
 	return skb;
 }
 
@@ -433,7 +435,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	skb->transport_header = skb->tail;
 	skb_put(skb, len);
 
 	hdr = (struct icmp6hdr *)skb_transport_header(skb);
@@ -1457,7 +1458,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
 	msg = (struct red_msg *)icmp6_hdr(buff);
 
-- 
1.7.9.5
