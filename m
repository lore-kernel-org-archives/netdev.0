From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: add mtu lock check in __ip6_rt_update_pmtu
Date: Fri, 28 Oct 2016 18:18:01 +0800
Message-ID: <0726e9078aea71d7f6332b4639985565c5e6491b.1477649881.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33035 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758641AbcJ1KSH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 06:18:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id i85so896768pfa.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 03:18:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, ipv6 didn't do mtu lock check in ip6_update_pmtu.
It leaded to that mtu lock doesn't really work when receiving the pkt
of ICMPV6_PKT_TOOBIG.

This patch is to add mtu lock check in __ip6_rt_update_pmtu just as ipv4
did in __ip_rt_update_pmtu.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/route.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 947ed1d..7403d90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1364,6 +1364,9 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 	if (rt6->rt6i_flags & RTF_LOCAL)
 		return;
 
+	if (dst_metric_locked(dst, RTAX_MTU))
+		return;
+
 	dst_confirm(dst);
 	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
 	if (mtu >= dst_mtu(dst))
-- 
2.1.0
