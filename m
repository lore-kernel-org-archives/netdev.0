From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] udp_diag: Fix the !ipv6 case
Date: Sat, 10 Dec 2011 13:35:07 +0400
Message-ID: <4EE327CB.4040505@parallels.com>
References: <4EE23561.5020804@parallels.com>	 <4EE23626.6000104@parallels.com> <1323467297.4016.10.camel@edumazet-laptop> <4EE32167.2080202@parallels.com> <4EE32777.2030003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11038 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541Ab1LJJfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 04:35:15 -0500
In-Reply-To: <4EE32777.2030003@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap the udp6 lookup into the proper ifdef-s.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 6506344..df7f960 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -41,6 +41,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 				req->id.idiag_src[0], req->id.idiag_sport,
 				req->id.idiag_dst[0], req->id.idiag_dport,
 				req->id.idiag_if, tbl);
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	else if (req->sdiag_family == AF_INET6)
 		sk = __udp6_lib_lookup(&init_net,
 				(struct in6_addr *)req->id.idiag_src,
@@ -48,6 +49,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 				(struct in6_addr *)req->id.idiag_dst,
 				req->id.idiag_dport,
 				req->id.idiag_if, tbl);
+#endif
 	else
 		goto out_nosk;
 
