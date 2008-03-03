From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/4 net-2.6.26] [IPV4]: skb->dst can't be NULL in ip_options_echo.
Date: Mon,  3 Mar 2008 18:48:40 +0300
Message-ID: <1204559323-19953-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:58048 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755803AbYCCPsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 10:48:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_options_echo is called on the packet input path after the initial
routing. The dst entry on the packet is cleared only in the several
very specific places and immidiately assigned back (may be new).

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/ip_options.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 4d31515..baaedd9 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -107,10 +107,7 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 	sptr = skb_network_header(skb);
 	dptr = dopt->__data;
 
-	if (skb->dst)
-		daddr = ((struct rtable*)skb->dst)->rt_spec_dst;
-	else
-		daddr = ip_hdr(skb)->daddr;
+	daddr = ((struct rtable*)skb->dst)->rt_spec_dst;
 
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
-- 
1.5.3.rc5

