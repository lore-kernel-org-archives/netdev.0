From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 17/17] ndisc: Use return value of __skb_put(),
 instead of icmp6_hdr().
Date: Tue, 18 Dec 2012 19:56:29 +0900
Message-ID: <50D04BDD.3070203@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56648 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754524Ab2LRK4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:56:30 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is safe to use __skb_put() here and it returns buffer for
ICMPv6 header.  Let's use it.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e614388..232daea 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1469,8 +1469,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_put(buff, sizeof(struct red_msg));
-	msg = (struct red_msg *)icmp6_hdr(buff);
+	msg = (struct red_msg *)__skb_put(buff, sizeof(struct red_msg));
 	*msg = (struct red_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_REDIRECT,
-- 
1.7.9.5
