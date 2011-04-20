From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 4/9] sctp: remove completely unsed EMPTY state
Date: Wed, 20 Apr 2011 15:28:26 +0800
Message-ID: <4DAE8B1A.2070303@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56752 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752148Ab1DTH2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:28:23 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

SCTP does not SCTP_STATE_EMPTY and we can never be in
that state.  Remove useless code.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/constants.h |   17 ++++-----
 net/sctp/debug.c             |    1 -
 net/sctp/outqueue.c          |    1 -
 net/sctp/sm_statetable.c     |   76 ------------------------------------------
 4 files changed, 8 insertions(+), 87 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index deac13d..942b864 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -187,15 +187,14 @@ typedef enum {
 /* SCTP state defines for internal state machine */
 typedef enum {
 
-	SCTP_STATE_EMPTY		= 0,
-	SCTP_STATE_CLOSED		= 1,
-	SCTP_STATE_COOKIE_WAIT		= 2,
-	SCTP_STATE_COOKIE_ECHOED	= 3,
-	SCTP_STATE_ESTABLISHED		= 4,
-	SCTP_STATE_SHUTDOWN_PENDING	= 5,
-	SCTP_STATE_SHUTDOWN_SENT	= 6,
-	SCTP_STATE_SHUTDOWN_RECEIVED	= 7,
-	SCTP_STATE_SHUTDOWN_ACK_SENT	= 8,
+	SCTP_STATE_CLOSED		= 0,
+	SCTP_STATE_COOKIE_WAIT		= 1,
+	SCTP_STATE_COOKIE_ECHOED	= 2,
+	SCTP_STATE_ESTABLISHED		= 3,
+	SCTP_STATE_SHUTDOWN_PENDING	= 4,
+	SCTP_STATE_SHUTDOWN_SENT	= 5,
+	SCTP_STATE_SHUTDOWN_RECEIVED	= 6,
+	SCTP_STATE_SHUTDOWN_ACK_SENT	= 7,
 
 } sctp_state_t;
 
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index bf24fa6..ec997cf 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -98,7 +98,6 @@ const char *sctp_cname(const sctp_subtype_t cid)
 
 /* These are printable forms of the states.  */
 const char *const sctp_state_tbl[SCTP_STATE_NUM_STATES] = {
-	"STATE_EMPTY",
 	"STATE_CLOSED",
 	"STATE_COOKIE_WAIT",
 	"STATE_COOKIE_ECHOED",
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7812772..3e9d8d2 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -320,7 +320,6 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 		 * chunk.
 		 */
 		switch (q->asoc->state) {
-		case SCTP_STATE_EMPTY:
 		case SCTP_STATE_CLOSED:
 		case SCTP_STATE_SHUTDOWN_PENDING:
 		case SCTP_STATE_SHUTDOWN_SENT:
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 546d438..881196b 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -107,8 +107,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 #define TYPE_SCTP_FUNC(func) {.fn = func, .name = #func}
 
 #define TYPE_SCTP_DATA { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -128,8 +126,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_DATA */
 
 #define TYPE_SCTP_INIT { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_5_1B_init), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -149,8 +145,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_INIT */
 
 #define TYPE_SCTP_INIT_ACK { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_5_2_3_initack), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -170,8 +164,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_INIT_ACK */
 
 #define TYPE_SCTP_SACK { \
-	/*  SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -191,8 +183,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_SACK */
 
 #define TYPE_SCTP_HEARTBEAT { \
-	/*  SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -213,8 +203,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_HEARTBEAT */
 
 #define TYPE_SCTP_HEARTBEAT_ACK { \
-	/*  SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -234,8 +222,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_HEARTBEAT_ACK */
 
 #define TYPE_SCTP_ABORT { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_pdiscard), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -255,8 +241,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_ABORT */
 
 #define TYPE_SCTP_SHUTDOWN { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -276,8 +260,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_SHUTDOWN */
 
 #define TYPE_SCTP_SHUTDOWN_ACK { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -297,8 +279,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_SHUTDOWN_ACK */
 
 #define TYPE_SCTP_ERROR { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -318,8 +298,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_ERROR */
 
 #define TYPE_SCTP_COOKIE_ECHO { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_5_1D_ce), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -339,8 +317,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_COOKIE_ECHO */
 
 #define TYPE_SCTP_COOKIE_ACK { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -360,8 +336,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_COOKIE_ACK */
 
 #define TYPE_SCTP_ECN_ECNE { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -381,8 +355,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_ECN_ECNE */
 
 #define TYPE_SCTP_ECN_CWR { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -402,8 +374,6 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 } /* TYPE_SCTP_ECN_CWR */
 
 #define TYPE_SCTP_SHUTDOWN_COMPLETE { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -446,8 +416,6 @@ static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][
 }; /* state_fn_t chunk_event_table[][] */
 
 #define TYPE_SCTP_ASCONF { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -467,8 +435,6 @@ static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][
 } /* TYPE_SCTP_ASCONF */
 
 #define TYPE_SCTP_ASCONF_ACK { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -496,8 +462,6 @@ static const sctp_sm_table_entry_t addip_chunk_event_table[SCTP_NUM_ADDIP_CHUNK_
 }; /*state_fn_t addip_chunk_event_table[][] */
 
 #define TYPE_SCTP_FWD_TSN { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -524,8 +488,6 @@ static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUN
 }; /*state_fn_t prsctp_chunk_event_table[][] */
 
 #define TYPE_SCTP_AUTH { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -553,8 +515,6 @@ static const sctp_sm_table_entry_t auth_chunk_event_table[SCTP_NUM_AUTH_CHUNK_TY
 
 static const sctp_sm_table_entry_t
 chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
-	/* SCTP_STATE_EMPTY */
-	TYPE_SCTP_FUNC(sctp_sf_ootb),
 	/* SCTP_STATE_CLOSED */
 	TYPE_SCTP_FUNC(sctp_sf_ootb),
 	/* SCTP_STATE_COOKIE_WAIT */
@@ -575,8 +535,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 
 
 #define TYPE_SCTP_PRIMITIVE_ASSOCIATE  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_prm_asoc), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -596,8 +554,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 } /* TYPE_SCTP_PRIMITIVE_ASSOCIATE */
 
 #define TYPE_SCTP_PRIMITIVE_SHUTDOWN  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -617,8 +573,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 } /* TYPE_SCTP_PRIMITIVE_SHUTDOWN */
 
 #define TYPE_SCTP_PRIMITIVE_ABORT  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -638,8 +592,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 } /* TYPE_SCTP_PRIMITIVE_ABORT */
 
 #define TYPE_SCTP_PRIMITIVE_SEND  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -659,8 +611,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 } /* TYPE_SCTP_PRIMITIVE_SEND */
 
 #define TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -680,8 +630,6 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 } /* TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT */
 
 #define TYPE_SCTP_PRIMITIVE_ASCONF { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -713,8 +661,6 @@ static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPE
 };
 
 #define TYPE_SCTP_OTHER_NO_PENDING_TSN  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -734,8 +680,6 @@ static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPE
 }
 
 #define TYPE_SCTP_OTHER_ICMP_PROTO_UNREACH  { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -760,8 +704,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 };
 
 #define TYPE_SCTP_EVENT_TIMEOUT_NONE { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -781,8 +723,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T1_COOKIE { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -802,8 +742,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T1_INIT { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -823,8 +761,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T2_SHUTDOWN { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -844,8 +780,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T3_RTX { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -865,8 +799,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T4_RTO { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -886,8 +818,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -907,8 +837,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_HEARTBEAT { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -928,8 +856,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_SACK { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
@@ -949,8 +875,6 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE { \
-	/* SCTP_STATE_EMPTY */ \
-	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-- 
1.6.5.2


