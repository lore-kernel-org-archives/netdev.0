From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: Not need to set fl6.flowi6_flags as zero
Date: Mon, 23 Sep 2013 14:55:59 +0800
Message-ID: <1379919359-3032-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:39613 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab3IWG4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 02:56:07 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so2828216pde.23
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 23:56:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

setting fl6.flowi6_flags as zero after memset is redundant, Remove it.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c979dd9..c6b2e1c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1137,7 +1137,6 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = 0;
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
@@ -1236,7 +1235,6 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = 0;
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
@@ -1258,7 +1256,6 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = 0;
 	fl6.daddr = msg->dest;
 	fl6.saddr = iph->daddr;
 
-- 
1.7.10.4
