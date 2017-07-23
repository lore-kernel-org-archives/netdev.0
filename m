From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/11] sctp: remove the typedef sctp_sack_chunk_t
Date: Sun, 23 Jul 2017 09:34:33 +0800
Message-ID: <b38e31f3ac26b5aa2f8a6522b002846a03a70118.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
 <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
 <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
 <94b6f03745317ab5c57639f2155a5e1503b4dfb3.1500773578.git.lucien.xin@gmail.com>
 <734295f5625300a5328c19e255dfbbf7d393e48f.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38453 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755288AbdGWBfs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:48 -0400
In-Reply-To: <734295f5625300a5328c19e255dfbbf7d393e48f.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sack_chunk_t, and
replace with struct sctp_sack_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/chunk.c        | 2 +-
 net/sctp/sm_statefuns.c | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index a2e4312..48f6560 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -381,10 +381,10 @@ struct sctp_sackhdr {
 	union sctp_sack_variable variable[0];
 };
 
-typedef struct sctp_sack_chunk {
+struct sctp_sack_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_sackhdr sack_hdr;
-} sctp_sack_chunk_t;
+};
 
 
 /* RFC 2960.  Section 3.3.5 Heartbeat Request (HEARTBEAT) (4):
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 1323d41..681b181 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -221,7 +221,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	    asoc->outqueue.out_qlen == 0 &&
 	    list_empty(&asoc->outqueue.retransmit) &&
 	    msg_len > max_data)
-		first_len -= SCTP_PAD4(sizeof(sctp_sack_chunk_t));
+		first_len -= SCTP_PAD4(sizeof(struct sctp_sack_chunk));
 
 	/* Encourage Cookie-ECHO bundling. */
 	if (asoc->state < SCTP_STATE_COOKIE_ECHOED)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c09dfe6..08ebe8c 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3194,7 +3194,7 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the SACK chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_sack_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_sack_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -4515,7 +4515,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
  * Handle a protocol violation when the chunk length is invalid.
  * "Invalid" length is identified as smaller than the minimal length a
  * given chunk can be.  For example, a SACK chunk has invalid length
- * if its length is set to be smaller than the size of sctp_sack_chunk_t.
+ * if its length is set to be smaller than the size of struct sctp_sack_chunk.
  *
  * We inform the other end by sending an ABORT with a Protocol Violation
  * error code.
-- 
2.1.0
