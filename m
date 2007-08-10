From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24] [TCP]: Update comment about highest_sack validity
Date: Fri, 10 Aug 2007 14:30:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708101428540.20173@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-85519270-1186745446=:20173"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43808 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbXHJLas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 07:30:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-85519270-1186745446=:20173
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


This stale info came from the original idea, which proved to be
unnecessarily complex, sacked_out > 0 is easy to do and that when
it's going to be needed anyway (it _can_ be valid also when
sacked_out == 0 but there's not going to be a guarantee about it
for now).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1f12fa0..f8cf090 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -332,7 +332,8 @@ struct tcp_sock {
 
 	struct tcp_sack_block_wire recv_sack_cache[4];
 
-	u32	highest_sack;	/* Start seq of globally highest revd SACK (valid only in slowpath) */
+	u32	highest_sack;	/* Start seq of globally highest revd SACK
+				 * (validity guaranteed only if sacked_out > 0) */
 
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
-- 
1.5.0.6

---696243703-85519270-1186745446=:20173--
