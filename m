From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: fix mid-wq adjustment helper
Date: Sat, 18 Apr 2009 18:48:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904181828200.3691@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1204050140-1240068815=:3691"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47753 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZDRPst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 11:48:49 -0400
Content-ID: <Pine.LNX.4.64.0904181845330.3691@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1204050140-1240068815=:3691
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0904181845331.3691@wrl-59.cs.helsinki.fi>


Just noticed while doing some new work that the recent
mid-wq adjustment logic will misbehave when FACK is not
in use (happens either due sysctl'ed off or auto-detected
reordering) because I forgot the relevant TCPCB tagbit.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2ce3cdd..5e4977c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -761,7 +761,7 @@ static void tcp_adjust_pcount(struct sock *sk, struct sk_buff *skb, int decr)
 
 	if (tp->lost_skb_hint &&
 	    before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(tp->lost_skb_hint)->seq) &&
-	    (tcp_is_fack(tp) || TCP_SKB_CB(skb)->sacked))
+	    (tcp_is_fack(tp) || (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)))
 		tp->lost_cnt_hint -= decr;
 
 	tcp_verify_left_out(tp);
-- 
tg: (adf84a1..) fix/adjust (depends on: rbtree/killfackets)
---696208474-1204050140-1240068815=:3691--
