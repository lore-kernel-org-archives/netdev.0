From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP]: Make prior_ssthresh a u32
Date: Wed, 21 May 2008 15:36:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1096597956-1211373368=:16829"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33485 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760351AbYEUMgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 08:36:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1096597956-1211373368=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


If previous window was above representable values of u16,
strange things will happen if undo with the truncated value
is called for. Alternatively, this could be fixed by some
max trickery but that would limit undoing high-speed undos.

Adds 16-bit hole but there isn't anything to fill it with.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d96d9b1..18e62e3 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -355,7 +355,7 @@ struct tcp_sock {
 	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
 
 	u16	advmss;		/* Advertised MSS			*/
-	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
+	u32	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	lost_out;	/* Lost packets			*/
 	u32	sacked_out;	/* SACK'd packets			*/
 	u32	fackets_out;	/* FACK'd packets			*/
-- 
1.5.2.2

---696208474-1096597956-1211373368=:16829--
