From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Correct reordering detection change (no FRTO case)
Date: Fri, 23 Feb 2007 18:09:10 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702231802140.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1078486214-1172246950=:19465"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57182 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933114AbXBWQJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 11:09:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1078486214-1172246950=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

The reordering detection must work also when FRTO has not been
used at all which was the original intention of mine, just the
expression of the idea was flawed.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
Applies on the top of tcp-2.6 branch as you would probably have
guessed.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bb3f234..f6ba07f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1240,7 +1240,7 @@ tcp_sacktag_write_queue(struct sock *sk,
 	tp->left_out = tp->sacked_out + tp->lost_out;
 
 	if ((reord < tp->fackets_out) && icsk->icsk_ca_state != TCP_CA_Loss &&
-	    (tp->frto_highmark && after(tp->snd_una, tp->frto_highmark)))
+	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
 		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
 
 #if FASTRETRANS_DEBUG > 0
-- 
1.4.2

---696243703-1078486214-1172246950=:19465--
