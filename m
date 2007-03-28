From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Rexmit hint must be cleared instead of setting it
Date: Wed, 28 Mar 2007 16:31:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703281629360.27182@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1561356540-1175088710=:27182"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33703 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbXC1Nby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 09:31:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1561356540-1175088710=:27182
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Stupid error from my side. Even though now that I noticed this,
I hoped it would have been an optimization but no, the counter
hint is then incorrect. Thus clearing is necessary for now (I
still suspect though that this path is never executed).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7a59ffe..c855791 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1763,7 +1763,7 @@ static void tcp_verify_retransmit_hint(s
 	    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
 	    before(TCP_SKB_CB(skb)->seq,
 	    TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-		tp->retransmit_skb_hint = skb;
+		tp->retransmit_skb_hint = NULL;
 }
 
 /* Forward walk starting from until a not timedout skb is encountered, timeout
-- 
1.4.2

---696243703-1561356540-1175088710=:27182--
