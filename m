From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 01/17] ndisc: Fix size calculation for headers.
Date: Tue, 18 Dec 2012 19:52:04 +0900
Message-ID: <50D04AD4.8010908@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56595 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754078Ab2LRKwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:52:07 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We used to allocate MAX_HEADER bytes more than needed but
reserved hlen only (not MAX_HEADER + hlen) and the MAX_HEADER
was left behind.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f2a007b..a1d2a45 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -395,8 +395,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 		len += ndisc_opt_addr_space(dev);
 
 	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + hlen + tlen),
+				  hlen + sizeof(struct ipv6hdr) + len + tlen,
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
@@ -1422,8 +1421,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	buff = sock_alloc_send_skb(sk,
-				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + hlen + tlen),
+				   hlen + sizeof(struct ipv6hdr) + len + tlen,
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK(0, err,
-- 
1.7.9.5
