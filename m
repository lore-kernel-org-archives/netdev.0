From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] TCP: Fix copy-paste (or code move) error
Date: Sun, 2 Dec 2007 18:45:44 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712021841050.11818@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1999548504-1196613944=:11818"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52932 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbXLBQpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 11:45:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1999548504-1196613944=:11818
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Should get the skb from the same queue. I had it first elsewhere
and missed this change while moving.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7ae72c3..5929022 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1524,7 +1524,7 @@ static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
 		/* Lazy find for the other queue */
 		if (skb[queue] == NULL) {
 			skb[queue] = tcp_write_queue_find(sk, TCP_SKB_CB(prev)->seq,
-						          queue ^ TCP_WQ_SACKED);
+						          queue);
 			if (skb[queue] == NULL)
 				break;
 		}
--
1.5.0.6
---696243703-1999548504-1196613944=:11818--
