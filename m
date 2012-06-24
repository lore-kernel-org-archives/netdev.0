From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Fix bug in tcp socket early demux
Date: Sat, 23 Jun 2012 20:38:10 -0700
Message-ID: <1340509090-2819-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33746 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130Ab2FXDdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 23:33:22 -0400
Received: by pbbrp8 with SMTP id rp8so5142165pbb.19
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 20:33:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dest port for the call to __inet_lookup_established() in TCP early demux
code is passed with the wrong endian-ness. This causes the lookup to fail
leading to early demux not being used.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b52934f..1781dc6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1701,7 +1701,7 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 	dev = skb->dev;
 	sk = __inet_lookup_established(net, &tcp_hashinfo,
 				       iph->saddr, th->source,
-				       iph->daddr, th->dest,
+				       iph->daddr, ntohs(th->dest),
 				       dev->ifindex);
 	if (sk) {
 		skb->sk = sk;
-- 
1.7.0.4
