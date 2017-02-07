From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: drop __packed from almost all SCTP structures
Date: Tue,  7 Feb 2017 11:37:56 -0200
Message-ID: <bb920bcd9cec538d7fe7abc548b56606f3c836a5.1486474498.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36793 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753307AbdBGNiN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:38:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__packed is considered harmful as it potentially generates code that
doesn't perform well and its usage should be avoided as much as
possible.

This patch drops __packed from all SCTP structures except one, which is
sctp_signed_cookie. In there it's required, as per changelog on
commit 9834a2bb4970 ("[SCTP]: Fix sctp_cookie alignment in the packet.").

After this patch, no alignment changes neither in x86 or x86_64 and
no exceptions were noticed during testing on both archs.

Code size for SCTP module also didn't change with this patch.

Cc: David Miller <davem@davemloft.net>
Cc: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/linux/sctp.h       | 80 +++++++++++++++++++++++-----------------------
 include/net/sctp/structs.h |  2 +-
 2 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index a9e790685af34defe4470d7d1307bb3d22edf6f4..2408c6877ca024ae70624b6b15ca8cccc6f0fda5 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -62,7 +62,7 @@ typedef struct sctphdr {
 	__be16 dest;
 	__be32 vtag;
 	__le32 checksum;
-} __packed sctp_sctphdr_t;
+} sctp_sctphdr_t;
 
 static inline struct sctphdr *sctp_hdr(const struct sk_buff *skb)
 {
@@ -74,7 +74,7 @@ typedef struct sctp_chunkhdr {
 	__u8 type;
 	__u8 flags;
 	__be16 length;
-} __packed sctp_chunkhdr_t;
+} sctp_chunkhdr_t;
 
 
 /* Section 3.2.  Chunk Type Values.
@@ -165,7 +165,7 @@ enum { SCTP_CHUNK_FLAG_T = 0x01 };
 typedef struct sctp_paramhdr {
 	__be16 type;
 	__be16 length;
-} __packed sctp_paramhdr_t;
+} sctp_paramhdr_t;
 
 typedef enum {
 
@@ -233,12 +233,12 @@ typedef struct sctp_datahdr {
 	__be16 ssn;
 	__be32 ppid;
 	__u8  payload[0];
-} __packed sctp_datahdr_t;
+} sctp_datahdr_t;
 
 typedef struct sctp_data_chunk {
         sctp_chunkhdr_t chunk_hdr;
         sctp_datahdr_t  data_hdr;
-} __packed sctp_data_chunk_t;
+} sctp_data_chunk_t;
 
 /* DATA Chuck Specific Flags */
 enum {
@@ -264,78 +264,78 @@ typedef struct sctp_inithdr {
 	__be16 num_inbound_streams;
 	__be32 initial_tsn;
 	__u8  params[0];
-} __packed sctp_inithdr_t;
+} sctp_inithdr_t;
 
 typedef struct sctp_init_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_inithdr_t init_hdr;
-} __packed sctp_init_chunk_t;
+} sctp_init_chunk_t;
 
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
 typedef struct sctp_ipv4addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in_addr  addr;
-} __packed sctp_ipv4addr_param_t;
+} sctp_ipv4addr_param_t;
 
 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in6_addr addr;
-} __packed sctp_ipv6addr_param_t;
+} sctp_ipv6addr_param_t;
 
 /* Section 3.3.2.1 Cookie Preservative (9) */
 typedef struct sctp_cookie_preserve_param {
 	sctp_paramhdr_t param_hdr;
 	__be32          lifespan_increment;
-} __packed sctp_cookie_preserve_param_t;
+} sctp_cookie_preserve_param_t;
 
 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
 	sctp_paramhdr_t param_hdr;
 	uint8_t hostname[0];
-} __packed sctp_hostname_param_t;
+} sctp_hostname_param_t;
 
 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
 	sctp_paramhdr_t param_hdr;
 	__be16 types[0];
-} __packed sctp_supported_addrs_param_t;
+} sctp_supported_addrs_param_t;
 
 /* Appendix A. ECN Capable (32768) */
 typedef struct sctp_ecn_capable_param {
 	sctp_paramhdr_t param_hdr;
-} __packed sctp_ecn_capable_param_t;
+} sctp_ecn_capable_param_t;
 
 /* ADDIP Section 3.2.6 Adaptation Layer Indication */
 typedef struct sctp_adaptation_ind_param {
 	struct sctp_paramhdr param_hdr;
 	__be32 adaptation_ind;
-} __packed sctp_adaptation_ind_param_t;
+} sctp_adaptation_ind_param_t;
 
 /* ADDIP Section 4.2.7 Supported Extensions Parameter */
 typedef struct sctp_supported_ext_param {
 	struct sctp_paramhdr param_hdr;
 	__u8 chunks[0];
-} __packed sctp_supported_ext_param_t;
+} sctp_supported_ext_param_t;
 
 /* AUTH Section 3.1 Random */
 typedef struct sctp_random_param {
 	sctp_paramhdr_t param_hdr;
 	__u8 random_val[0];
-} __packed sctp_random_param_t;
+} sctp_random_param_t;
 
 /* AUTH Section 3.2 Chunk List */
 typedef struct sctp_chunks_param {
 	sctp_paramhdr_t param_hdr;
 	__u8 chunks[0];
-} __packed sctp_chunks_param_t;
+} sctp_chunks_param_t;
 
 /* AUTH Section 3.3 HMAC Algorithm */
 typedef struct sctp_hmac_algo_param {
 	sctp_paramhdr_t param_hdr;
 	__be16 hmac_ids[0];
-} __packed sctp_hmac_algo_param_t;
+} sctp_hmac_algo_param_t;
 
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
@@ -347,13 +347,13 @@ typedef sctp_init_chunk_t sctp_initack_chunk_t;
 typedef struct sctp_cookie_param {
 	sctp_paramhdr_t p;
 	__u8 body[0];
-} __packed sctp_cookie_param_t;
+} sctp_cookie_param_t;
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
 	sctp_paramhdr_t param_hdr;
 	sctp_paramhdr_t unrecognized;
-} __packed sctp_unrecognized_param_t;
+} sctp_unrecognized_param_t;
 
 
 
@@ -368,7 +368,7 @@ typedef struct sctp_unrecognized_param {
 typedef struct sctp_gap_ack_block {
 	__be16 start;
 	__be16 end;
-} __packed sctp_gap_ack_block_t;
+} sctp_gap_ack_block_t;
 
 typedef __be32 sctp_dup_tsn_t;
 
@@ -383,12 +383,12 @@ typedef struct sctp_sackhdr {
 	__be16 num_gap_ack_blocks;
 	__be16 num_dup_tsns;
 	sctp_sack_variable_t variable[0];
-} __packed sctp_sackhdr_t;
+} sctp_sackhdr_t;
 
 typedef struct sctp_sack_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_sackhdr_t sack_hdr;
-} __packed sctp_sack_chunk_t;
+} sctp_sack_chunk_t;
 
 
 /* RFC 2960.  Section 3.3.5 Heartbeat Request (HEARTBEAT) (4):
@@ -400,12 +400,12 @@ typedef struct sctp_sack_chunk {
 
 typedef struct sctp_heartbeathdr {
 	sctp_paramhdr_t info;
-} __packed sctp_heartbeathdr_t;
+} sctp_heartbeathdr_t;
 
 typedef struct sctp_heartbeat_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_heartbeathdr_t hb_hdr;
-} __packed sctp_heartbeat_chunk_t;
+} sctp_heartbeat_chunk_t;
 
 
 /* For the abort and shutdown ACK we must carry the init tag in the
@@ -414,7 +414,7 @@ typedef struct sctp_heartbeat_chunk {
  */
 typedef struct sctp_abort_chunk {
         sctp_chunkhdr_t uh;
-} __packed sctp_abort_chunk_t;
+} sctp_abort_chunk_t;
 
 
 /* For the graceful shutdown we must carry the tag (in common header)
@@ -422,12 +422,12 @@ typedef struct sctp_abort_chunk {
  */
 typedef struct sctp_shutdownhdr {
 	__be32 cum_tsn_ack;
-} __packed sctp_shutdownhdr_t;
+} sctp_shutdownhdr_t;
 
 struct sctp_shutdown_chunk_t {
         sctp_chunkhdr_t    chunk_hdr;
         sctp_shutdownhdr_t shutdown_hdr;
-} __packed;
+};
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
 
@@ -435,12 +435,12 @@ typedef struct sctp_errhdr {
 	__be16 cause;
 	__be16 length;
 	__u8  variable[0];
-} __packed sctp_errhdr_t;
+} sctp_errhdr_t;
 
 typedef struct sctp_operr_chunk {
         sctp_chunkhdr_t chunk_hdr;
 	sctp_errhdr_t   err_hdr;
-} __packed sctp_operr_chunk_t;
+} sctp_operr_chunk_t;
 
 /* RFC 2960 3.3.10 - Operation Error
  *
@@ -530,7 +530,7 @@ typedef struct sctp_ecnehdr {
 typedef struct sctp_ecne_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_ecnehdr_t ence_hdr;
-} __packed sctp_ecne_chunk_t;
+} sctp_ecne_chunk_t;
 
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
@@ -542,7 +542,7 @@ typedef struct sctp_cwrhdr {
 typedef struct sctp_cwr_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_cwrhdr_t cwr_hdr;
-} __packed sctp_cwr_chunk_t;
+} sctp_cwr_chunk_t;
 
 /* PR-SCTP
  * 3.2 Forward Cumulative TSN Chunk Definition (FORWARD TSN)
@@ -593,17 +593,17 @@ typedef struct sctp_cwr_chunk {
 struct sctp_fwdtsn_skip {
 	__be16 stream;
 	__be16 ssn;
-} __packed;
+};
 
 struct sctp_fwdtsn_hdr {
 	__be32 new_cum_tsn;
 	struct sctp_fwdtsn_skip skip[0];
-} __packed;
+};
 
 struct sctp_fwdtsn_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_fwdtsn_hdr fwdtsn_hdr;
-} __packed;
+};
 
 
 /* ADDIP
@@ -641,17 +641,17 @@ struct sctp_fwdtsn_chunk {
 typedef struct sctp_addip_param {
 	sctp_paramhdr_t	param_hdr;
 	__be32		crr_id;
-} __packed sctp_addip_param_t;
+} sctp_addip_param_t;
 
 typedef struct sctp_addiphdr {
 	__be32	serial;
 	__u8	params[0];
-} __packed sctp_addiphdr_t;
+} sctp_addiphdr_t;
 
 typedef struct sctp_addip_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_addiphdr_t addip_hdr;
-} __packed sctp_addip_chunk_t;
+} sctp_addip_chunk_t;
 
 /* AUTH
  * Section 4.1  Authentication Chunk (AUTH)
@@ -706,12 +706,12 @@ typedef struct sctp_authhdr {
 	__be16 shkey_id;
 	__be16 hmac_id;
 	__u8   hmac[0];
-} __packed sctp_authhdr_t;
+} sctp_authhdr_t;
 
 typedef struct sctp_auth_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_authhdr_t auth_hdr;
-} __packed sctp_auth_chunk_t;
+} sctp_auth_chunk_t;
 
 struct sctp_infox {
 	struct sctp_info *sctpinfo;
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 231fa9ac50bd9e9a4fdb78123671504a1cfaf949..b91ebf711103698c20933bbe5c0d4b8457eab9a0 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -374,7 +374,7 @@ typedef struct sctp_sender_hb_info {
 	union sctp_addr daddr;
 	unsigned long sent_at;
 	__u64 hb_nonce;
-} __packed sctp_sender_hb_info_t;
+} sctp_sender_hb_info_t;
 
 struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp);
 void sctp_stream_free(struct sctp_stream *stream);
-- 
2.9.3
