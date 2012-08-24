From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netpoll: provide an IP ident in UDP frames
Date: Fri, 24 Aug 2012 13:47:26 +0200
Message-ID: <1345808846.29722.133.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64507 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab2HXLrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 07:47:39 -0400
Received: by bkwj10 with SMTP id j10so558424bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 04:47:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Let's fill IP header ident field with a meaningful value,
it might help some setups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/netpoll.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 346b1eb..5af9c26 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -388,6 +388,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	struct udphdr *udph;
 	struct iphdr *iph;
 	struct ethhdr *eth;
+	static atomic_t ip_ident;
 
 	udp_len = len + sizeof(*udph);
 	ip_len = udp_len + sizeof(*iph);
@@ -423,7 +424,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	put_unaligned(0x45, (unsigned char *)iph);
 	iph->tos      = 0;
 	put_unaligned(htons(ip_len), &(iph->tot_len));
-	iph->id       = 0;
+	iph->id       = htons(atomic_inc_return(&ip_ident));
 	iph->frag_off = 0;
 	iph->ttl      = 64;
 	iph->protocol = IPPROTO_UDP;
