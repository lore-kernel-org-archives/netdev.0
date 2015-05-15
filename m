From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: synproxy: fix sparse errors
Date: Fri, 15 May 2015 09:07:31 -0700
Message-ID: <1431706051.27831.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36334 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934839AbbEOQHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 12:07:34 -0400
Received: by igbpi8 with SMTP id pi8so226817729igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 09:07:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix verbose sparse errors :

make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/netfilter/ipt_SYNPROXY.o

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Trivial errors, please David merge this directly into your tree.

 net/ipv4/netfilter/ipt_SYNPROXY.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index e9e67793055fce9b20ee836275a3eb4a9437592a..fe8cc183411e052f6e0ba4afefbeaef1e77313cd 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -18,7 +18,7 @@
 #include <net/netfilter/nf_conntrack_synproxy.h>
 
 static struct iphdr *
-synproxy_build_ip(struct sk_buff *skb, u32 saddr, u32 daddr)
+synproxy_build_ip(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 {
 	struct iphdr *iph;
 
@@ -220,7 +220,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	nth->ack_seq	= th->ack_seq;
 	tcp_flag_word(nth) = TCP_FLAG_ACK;
 	nth->doff	= tcp_hdr_size / 4;
-	nth->window	= ntohs(htons(th->window) >> opts->wscale);
+	nth->window	= htons(ntohs(th->window) >> opts->wscale);
 	nth->check	= 0;
 	nth->urg_ptr	= 0;
 
