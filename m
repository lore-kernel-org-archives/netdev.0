From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Make invariant check complain about invalid sacked_out
Date: Wed, 5 Dec 2007 21:35:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712052133490.9572@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1284969860-1196883329=:9572"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51334 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbXLETfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 14:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1284969860-1196883329=:9572
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Earlier resolution for NewReno's sacked_out should now keep
it small enough for this to become invariant-like check.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fef1191..f1eee2d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2510,11 +2510,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
-	/* Some technical things:
-	 * 1. Reno does not count dupacks (sacked_out) automatically. */
-	if (!tp->packets_out)
+	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
-
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
 		tp->fackets_out = 0;
 
-- 
1.5.0.6

---696243703-1284969860-1196883329=:9572--
