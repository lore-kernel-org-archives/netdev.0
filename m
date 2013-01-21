From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 11/19] ndisc: Reset skb->trasport_headner inside
 ndisc_alloc_send_skb().
Date: Tue, 22 Jan 2013 01:48:44 +0900
Message-ID: <50FD716C.60106@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50361 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753053Ab3AUQsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09171fd..62b1415 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -388,6 +388,7 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	skb->dev = dev;
 
 	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
+	skb_reset_transport_header(skb);
 
 	return skb;
 }
@@ -438,7 +439,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	skb->transport_header = skb->tail;
 	skb_put(skb, len);
 
 	hdr = (struct icmp6hdr *)skb_transport_header(skb);
@@ -1479,7 +1479,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
 	msg = (struct rd_msg *)icmp6_hdr(buff);
 
-- 
1.7.9.5
