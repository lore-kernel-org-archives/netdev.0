From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] syncookies: Make sure ECN is disabled
Date: Thu, 24 Jul 2008 20:18:06 +0200
Message-ID: <1216923486-4137-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:57223 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754408AbYGXSKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 14:10:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ecn_ok is not initialized when a connection is established by cookies.
The cookie syn-ack never sets ECN, so ecn_ok must be set to 0.

Spotted using ns-3/network simulation cradle simulator and valgrind.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c |    1 +
 net/ipv6/syncookies.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 51bc24d..9d38005 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -299,6 +299,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
+	ireq->ecn_ok		= 0;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6a68eeb..a46badd 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -223,6 +223,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->expires = 0UL;
 	req->retrans = 0;
+	ireq->ecn_ok		= 0;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
-- 
1.5.4.5

