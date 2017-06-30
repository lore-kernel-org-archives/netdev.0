From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 03/11] sctp: remove the typedef sctp_cid_t
Date: Fri, 30 Jun 2017 11:52:14 +0800
Message-ID: <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34154 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3DxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:07 -0400
In-Reply-To: <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cid_t, and replace
with struct sctp_cid in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h         | 4 ++--
 include/net/sctp/auth.h      | 6 ++++--
 include/net/sctp/constants.h | 4 ++--
 include/net/sctp/structs.h   | 2 +-
 net/sctp/auth.c              | 6 +++---
 net/sctp/sm_make_chunk.c     | 4 ++--
 net/sctp/sm_statetable.c     | 4 ++--
 7 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 9ad5b9e..6d7b884 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -82,7 +82,7 @@ struct sctp_chunkhdr {
  * Value field. It takes a value from 0 to 254. The value of 255 is
  * reserved for future use as an extension field.
  */
-typedef enum {
+enum sctp_cid {
 	SCTP_CID_DATA			= 0,
         SCTP_CID_INIT			= 1,
         SCTP_CID_INIT_ACK		= 2,
@@ -109,7 +109,7 @@ typedef enum {
 	SCTP_CID_ASCONF			= 0xC1,
 	SCTP_CID_ASCONF_ACK		= 0x80,
 	SCTP_CID_RECONF			= 0x82,
-} sctp_cid_t; /* enum */
+}; /* enum */
 
 
 /* Section 3.2
diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 9b9fb12..171244b 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -97,8 +97,10 @@ void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
 				     struct sctp_hmac_algo_param *hmacs);
 int sctp_auth_asoc_verify_hmac_id(const struct sctp_association *asoc,
 				    __be16 hmac_id);
-int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc);
-int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc);
+int sctp_auth_send_cid(enum sctp_cid chunk,
+		       const struct sctp_association *asoc);
+int sctp_auth_recv_cid(enum sctp_cid chunk,
+		       const struct sctp_association *asoc);
 void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
 			    struct sk_buff *skb,
 			    struct sctp_auth_chunk *auth, gfp_t gfp);
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index b07a745..02e867b 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -130,7 +130,7 @@ typedef enum {
  */
 
 typedef union {
-	sctp_cid_t chunk;
+	enum sctp_cid chunk;
 	sctp_event_timeout_t timeout;
 	sctp_event_other_t other;
 	sctp_event_primitive_t primitive;
@@ -141,7 +141,7 @@ static inline sctp_subtype_t	\
 SCTP_ST_## _name (_type _arg)		\
 { sctp_subtype_t _retval; _retval._elt = _arg; return _retval; }
 
-SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		sctp_cid_t,		chunk)
+SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		enum sctp_cid,		chunk)
 SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	sctp_event_timeout_t,	timeout)
 SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		sctp_event_other_t,	other)
 SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e26763b..9e9605e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1297,7 +1297,7 @@ int sctp_has_association(struct net *net, const union sctp_addr *laddr,
 
 int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
 		     const struct sctp_association *asoc,
-		     sctp_cid_t, sctp_init_chunk_t *peer_init,
+		     enum sctp_cid cid, sctp_init_chunk_t *peer_init,
 		     struct sctp_chunk *chunk, struct sctp_chunk **err_chunk);
 int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer,
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index f99d485..7171dd3 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -632,7 +632,7 @@ void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
 
 
 /* Check to see if the given chunk is supposed to be authenticated */
-static int __sctp_auth_cid(sctp_cid_t chunk, struct sctp_chunks_param *param)
+static int __sctp_auth_cid(enum sctp_cid chunk, struct sctp_chunks_param *param)
 {
 	unsigned short len;
 	int found = 0;
@@ -668,7 +668,7 @@ static int __sctp_auth_cid(sctp_cid_t chunk, struct sctp_chunks_param *param)
 }
 
 /* Check if peer requested that this chunk is authenticated */
-int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
+int sctp_auth_send_cid(enum sctp_cid chunk, const struct sctp_association *asoc)
 {
 	if (!asoc)
 		return 0;
@@ -680,7 +680,7 @@ int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
 }
 
 /* Check if we requested that peer authenticate this chunk. */
-int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
+int sctp_auth_recv_cid(enum sctp_cid chunk, const struct sctp_association *asoc)
 {
 	if (!asoc)
 		return 0;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 7d4c5a8..78c3f21 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2123,7 +2123,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					union sctp_params param,
-					sctp_cid_t cid,
+					enum sctp_cid cid,
 					struct sctp_chunk *chunk,
 					struct sctp_chunk **err_chunk)
 {
@@ -2240,7 +2240,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 
 /* Verify the INIT packet before we process it.  */
 int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
-		     const struct sctp_association *asoc, sctp_cid_t cid,
+		     const struct sctp_association *asoc, enum sctp_cid cid,
 		     sctp_init_chunk_t *peer_init, struct sctp_chunk *chunk,
 		     struct sctp_chunk **errp)
 {
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 419b18e..3e958c1 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -53,7 +53,7 @@ static const sctp_sm_table_entry_t
 timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES];
 
 static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
-							    sctp_cid_t cid,
+							    enum sctp_cid cid,
 							    sctp_state_t state);
 
 
@@ -968,7 +968,7 @@ static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][S
 };
 
 static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
-							    sctp_cid_t cid,
+							    enum sctp_cid cid,
 							    sctp_state_t state)
 {
 	if (state > SCTP_STATE_MAX)
-- 
2.1.0
