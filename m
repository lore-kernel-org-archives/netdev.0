From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] ipv6: missed namespace context in ipv6_rthdr_rcv
Date: Thu, 10 Jul 2008 16:09:08 +0400
Message-ID: <1215691748-17151-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net,
	"Denis V. Lunev" <den@openvz.org>,
	"Denis V. Lunev" <den@parallels.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1088 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704AbYGJMKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 08:10:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@parallels.com>
---
 net/ipv6/exthdrs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 3cd1c99..dcf94fd 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -445,7 +445,7 @@ looped_back:
 			kfree_skb(skb);
 			return -1;
 		}
-		if (!ipv6_chk_home_addr(&init_net, addr)) {
+		if (!ipv6_chk_home_addr(dev_net(skb->dst->dev), addr)) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
-- 
1.5.3.rc5

