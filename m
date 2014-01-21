From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 3/4] ipv4: use SNMP macro assuming softirq context in ip_forward().
Date: Tue, 21 Jan 2014 13:48:50 +0200
Message-ID: <3c324aaf986e6d5a0678cac6d292dd0b96bd9766.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:59563 "EHLO
	fallback2.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbaAULyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 06:54:19 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback2.mail.ru (mPOP.Fallback_MX) with ESMTP id 479D0FBEDD0A
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 15:49:13 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=42200 helo=tuxracer.localdomain)
	by smtp11.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W5ZpB-0006Kt-1v
	for netdev@vger.kernel.org; Tue, 21 Jan 2014 15:48:57 +0400
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_forward() runs entirely in softirq context, we could use
version of SNMP macro which updates stats counters assuming that.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv4/ip_forward.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index e9f1217..fd7eeec 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -93,7 +93,7 @@ int ip_forward(struct sk_buff *skb)
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
 	if (unlikely(skb->len > mtu && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
-		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
 		goto drop;
-- 
1.8.3.4
