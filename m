From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: really allow using GFP_KERNEL on sctp_packet_transmit
Date: Tue, 29 Mar 2016 10:41:03 -0300
Message-ID: <1459258863-21351-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241AbcC2NlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 09:41:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Somehow my patch for commit cea8768f333e ("sctp: allow
sctp_transmit_packet and others to use gfp") missed two important
chunks, which are now added.

Fixes: cea8768f333e ("sctp: allow sctp_transmit_packet and others to use gfp")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/output.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 736c004abfbc2787a3c50fa85168ebdf3b112787..97745351d58c2fb32b9f9b57d61831d7724d83b2 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -401,7 +401,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	sk = chunk->skb->sk;
 
 	/* Allocate the new skb.  */
-	nskb = alloc_skb(packet->size + MAX_HEADER, GFP_ATOMIC);
+	nskb = alloc_skb(packet->size + MAX_HEADER, gfp);
 	if (!nskb)
 		goto nomem;
 
@@ -523,8 +523,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	 */
 	if (auth)
 		sctp_auth_calculate_hmac(asoc, nskb,
-					(struct sctp_auth_chunk *)auth,
-					GFP_ATOMIC);
+					 (struct sctp_auth_chunk *)auth,
+					 gfp);
 
 	/* 2) Calculate the Adler-32 checksum of the whole packet,
 	 *    including the SCTP common header and all the
-- 
2.5.0
