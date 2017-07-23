From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/11] sctp: remove the typedef sctp_sackhdr_t
Date: Sun, 23 Jul 2017 09:34:32 +0800
Message-ID: <734295f5625300a5328c19e255dfbbf7d393e48f.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
 <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
 <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
 <94b6f03745317ab5c57639f2155a5e1503b4dfb3.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33695 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:42 -0400
In-Reply-To: <94b6f03745317ab5c57639f2155a5e1503b4dfb3.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sackhdr_t, and replace
with struct sctp_sackhdr in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       | 6 +++---
 include/net/sctp/command.h | 4 ++--
 net/sctp/sm_statefuns.c    | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 8df6ac5..a2e4312 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -373,17 +373,17 @@ union sctp_sack_variable {
 	__be32 dup;
 };
 
-typedef struct sctp_sackhdr {
+struct sctp_sackhdr {
 	__be32 cum_tsn_ack;
 	__be32 a_rwnd;
 	__be16 num_gap_ack_blocks;
 	__be16 num_dup_tsns;
 	union sctp_sack_variable variable[0];
-} sctp_sackhdr_t;
+};
 
 typedef struct sctp_sack_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_sackhdr_t sack_hdr;
+	struct sctp_sackhdr sack_hdr;
 } sctp_sack_chunk_t;
 
 
diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index d4679e7..1d5f6ff 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -135,7 +135,7 @@ typedef union {
 	struct sctp_init_chunk *init;
 	struct sctp_ulpevent *ulpevent;
 	struct sctp_packet *packet;
-	sctp_sackhdr_t *sackh;
+	struct sctp_sackhdr *sackh;
 	struct sctp_datamsg *msg;
 } sctp_arg_t;
 
@@ -176,7 +176,7 @@ SCTP_ARG_CONSTRUCTOR(BA,	struct sctp_bind_addr *, bp)
 SCTP_ARG_CONSTRUCTOR(PEER_INIT,	struct sctp_init_chunk *, init)
 SCTP_ARG_CONSTRUCTOR(ULPEVENT,  struct sctp_ulpevent *, ulpevent)
 SCTP_ARG_CONSTRUCTOR(PACKET,	struct sctp_packet *, packet)
-SCTP_ARG_CONSTRUCTOR(SACKH,	sctp_sackhdr_t *, sackh)
+SCTP_ARG_CONSTRUCTOR(SACKH,	struct sctp_sackhdr *, sackh)
 SCTP_ARG_CONSTRUCTOR(DATAMSG,	struct sctp_datamsg *, msg)
 
 static inline sctp_arg_t SCTP_FORCE(void)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7f85239..c09dfe6 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3187,7 +3187,7 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_sackhdr_t *sackh;
+	struct sctp_sackhdr *sackh;
 	__u32 ctsn;
 
 	if (!sctp_vtag_verify(chunk, asoc))
-- 
2.1.0
