From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 12/14] sctp: remove the typedef sctp_sm_table_entry_t
Date: Fri, 11 Aug 2017 10:23:56 +0800
Message-ID: <55bc9dd4073fded0138ef8074f092fb7ba148356.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
 <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
 <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
 <712be5d964dee4d7918781d7399ad564f2309259.1502417340.git.lucien.xin@gmail.com>
 <6ff85867e2eb2776e2dbec9a0140911dcaec3e18.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37412 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbdHKCZl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:41 -0400
In-Reply-To: <6ff85867e2eb2776e2dbec9a0140911dcaec3e18.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sm_table_entry_t, and
replace with struct sctp_sm_table_entry in the places where it's
using this typedef.

It is also to fix some indents.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h    |  6 +++---
 net/sctp/sm_sideeffect.c |  2 +-
 net/sctp/sm_statetable.c | 42 +++++++++++++++++++++++++-----------------
 3 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 3ca75a6..7ad2402 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -72,10 +72,10 @@ typedef sctp_disposition_t (sctp_state_fn_t) (struct net *,
 					      void *arg,
 					      struct sctp_cmd_seq *);
 typedef void (sctp_timer_event_t) (unsigned long);
-typedef struct {
+struct sctp_sm_table_entry {
 	sctp_state_fn_t *fn;
 	const char *name;
-} sctp_sm_table_entry_t;
+};
 
 /* A naming convention of "sctp_sf_xxx" applies to all the state functions
  * currently in use.
@@ -170,7 +170,7 @@ sctp_state_fn_t sctp_sf_autoclose_timer_expire;
 
 /* Prototypes for utility support functions.  */
 __u8 sctp_get_chunk_type(struct sctp_chunk *chunk);
-const sctp_sm_table_entry_t *sctp_sm_lookup_event(
+const struct sctp_sm_table_entry *sctp_sm_lookup_event(
 					struct net *net,
 					enum sctp_event event_type,
 					enum sctp_state state,
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6dd5934..2bc1204 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1146,7 +1146,7 @@ int sctp_do_sm(struct net *net, enum sctp_event event_type,
 	       void *event_arg, gfp_t gfp)
 {
 	struct sctp_cmd_seq commands;
-	const sctp_sm_table_entry_t *state_fn;
+	const struct sctp_sm_table_entry *state_fn;
 	sctp_disposition_t status;
 	int error = 0;
 	typedef const char *(printfn_t)(union sctp_subtype);
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index d437f38..79b6bee 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -45,27 +45,27 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-static const sctp_sm_table_entry_t
+static const struct sctp_sm_table_entry
 primitive_event_table[SCTP_NUM_PRIMITIVE_TYPES][SCTP_STATE_NUM_STATES];
-static const sctp_sm_table_entry_t
+static const struct sctp_sm_table_entry
 other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES];
-static const sctp_sm_table_entry_t
+static const struct sctp_sm_table_entry
 timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES];
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(
+static const struct sctp_sm_table_entry *sctp_chunk_event_lookup(
 						struct net *net,
 						enum sctp_cid cid,
 						enum sctp_state state);
 
 
-static const sctp_sm_table_entry_t bug = {
+static const struct sctp_sm_table_entry bug = {
 	.fn = sctp_sf_bug,
 	.name = "sctp_sf_bug"
 };
 
 #define DO_LOOKUP(_max, _type, _table)					\
 ({									\
-	const sctp_sm_table_entry_t *rtn;				\
+	const struct sctp_sm_table_entry *rtn;				\
 									\
 	if ((event_subtype._type > (_max))) {				\
 		pr_warn("table %p possible attack: event %d exceeds max %d\n", \
@@ -77,7 +77,7 @@ static const sctp_sm_table_entry_t bug = {
 	rtn;								\
 })
 
-const sctp_sm_table_entry_t *sctp_sm_lookup_event(
+const struct sctp_sm_table_entry *sctp_sm_lookup_event(
 					struct net *net,
 					enum sctp_event event_type,
 					enum sctp_state state,
@@ -394,7 +394,8 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(
  *
  * For base protocol (RFC 2960).
  */
-static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_DATA,
 	TYPE_SCTP_INIT,
 	TYPE_SCTP_INIT_ACK,
@@ -453,7 +454,8 @@ static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][
 /* The primary index for this table is the chunk type.
  * The secondary index for this table is the state.
  */
-static const sctp_sm_table_entry_t addip_chunk_event_table[SCTP_NUM_ADDIP_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+addip_chunk_event_table[SCTP_NUM_ADDIP_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_ASCONF,
 	TYPE_SCTP_ASCONF_ACK,
 }; /*state_fn_t addip_chunk_event_table[][] */
@@ -480,7 +482,8 @@ static const sctp_sm_table_entry_t addip_chunk_event_table[SCTP_NUM_ADDIP_CHUNK_
 /* The primary index for this table is the chunk type.
  * The secondary index for this table is the state.
  */
-static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_FWD_TSN,
 }; /*state_fn_t prsctp_chunk_event_table[][] */
 
@@ -506,7 +509,8 @@ static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUN
 /* The primary index for this table is the chunk type.
  * The secondary index for this table is the state.
  */
-static const sctp_sm_table_entry_t reconf_chunk_event_table[SCTP_NUM_RECONF_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+reconf_chunk_event_table[SCTP_NUM_RECONF_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_RECONF,
 }; /*state_fn_t reconf_chunk_event_table[][] */
 
@@ -532,11 +536,12 @@ static const sctp_sm_table_entry_t reconf_chunk_event_table[SCTP_NUM_RECONF_CHUN
 /* The primary index for this table is the chunk type.
  * The secondary index for this table is the state.
  */
-static const sctp_sm_table_entry_t auth_chunk_event_table[SCTP_NUM_AUTH_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+auth_chunk_event_table[SCTP_NUM_AUTH_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_AUTH,
 }; /*state_fn_t auth_chunk_event_table[][] */
 
-static const sctp_sm_table_entry_t
+static const struct sctp_sm_table_entry
 chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 	/* SCTP_STATE_CLOSED */
 	TYPE_SCTP_FUNC(sctp_sf_ootb),
@@ -693,7 +698,8 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 /* The primary index for this table is the primitive type.
  * The secondary index for this table is the state.
  */
-static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+primitive_event_table[SCTP_NUM_PRIMITIVE_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_PRIMITIVE_ASSOCIATE,
 	TYPE_SCTP_PRIMITIVE_SHUTDOWN,
 	TYPE_SCTP_PRIMITIVE_ABORT,
@@ -741,7 +747,8 @@ static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPE
 	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 }
 
-static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_OTHER_NO_PENDING_TSN,
 	TYPE_SCTP_OTHER_ICMP_PROTO_UNREACH,
 };
@@ -955,7 +962,8 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
-static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES] = {
+static const struct sctp_sm_table_entry
+timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_EVENT_TIMEOUT_NONE,
 	TYPE_SCTP_EVENT_TIMEOUT_T1_COOKIE,
 	TYPE_SCTP_EVENT_TIMEOUT_T1_INIT,
@@ -969,7 +977,7 @@ static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][S
 	TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE,
 };
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(
+static const struct sctp_sm_table_entry *sctp_chunk_event_lookup(
 						struct net *net,
 						enum sctp_cid cid,
 						enum sctp_state state)
-- 
2.1.0
