From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 09/14] sctp: remove the typedef sctp_state_t
Date: Sat,  5 Aug 2017 19:59:59 +0800
Message-ID: <6f17de8a0a6d21445de859c4073b235e9c5d2163.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
 <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
 <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
 <a26ddefe25442293b3e1020ce56f859125a93412.1501934087.git.lucien.xin@gmail.com>
 <1bd9e98627fc627a28f90ad587e941845b91b108.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36489 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:24 -0400
In-Reply-To: <1bd9e98627fc627a28f90ad587e941845b91b108.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_state_t, and
replace with enum sctp_state in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h   |  4 ++--
 include/net/sctp/constants.h |  4 ++--
 include/net/sctp/sctp.h      |  2 +-
 include/net/sctp/sm.h        | 10 +++++-----
 include/net/sctp/structs.h   |  2 +-
 net/sctp/endpointola.c       |  2 +-
 net/sctp/primitive.c         |  2 +-
 net/sctp/sm_sideeffect.c     | 12 ++++++------
 net/sctp/sm_statetable.c     | 16 +++++++++-------
 9 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 1d5f6ff..be12ec9 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -126,7 +126,7 @@ typedef union {
 	__u8 u8;
 	int error;
 	__be16 err;
-	sctp_state_t state;
+	enum sctp_state state;
 	sctp_event_timeout_t to;
 	struct sctp_chunk *chunk;
 	struct sctp_association *asoc;
@@ -167,7 +167,7 @@ SCTP_ARG_CONSTRUCTOR(U16,	__u16, u16)
 SCTP_ARG_CONSTRUCTOR(U8,	__u8, u8)
 SCTP_ARG_CONSTRUCTOR(ERROR,     int, error)
 SCTP_ARG_CONSTRUCTOR(PERR,      __be16, err)	/* protocol error */
-SCTP_ARG_CONSTRUCTOR(STATE,	sctp_state_t, state)
+SCTP_ARG_CONSTRUCTOR(STATE,	enum sctp_state, state)
 SCTP_ARG_CONSTRUCTOR(TO,	sctp_event_timeout_t, to)
 SCTP_ARG_CONSTRUCTOR(CHUNK,	struct sctp_chunk *, chunk)
 SCTP_ARG_CONSTRUCTOR(ASOC,	struct sctp_association *, asoc)
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 9a69465..db9f40b 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -181,7 +181,7 @@ enum sctp_ierror {
 
 
 /* SCTP state defines for internal state machine */
-typedef enum {
+enum sctp_state {
 
 	SCTP_STATE_CLOSED		= 0,
 	SCTP_STATE_COOKIE_WAIT		= 1,
@@ -192,7 +192,7 @@ typedef enum {
 	SCTP_STATE_SHUTDOWN_RECEIVED	= 6,
 	SCTP_STATE_SHUTDOWN_ACK_SENT	= 7,
 
-} sctp_state_t;
+};
 
 #define SCTP_STATE_MAX			SCTP_STATE_SHUTDOWN_ACK_SENT
 #define SCTP_STATE_NUM_STATES		(SCTP_STATE_MAX + 1)
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 0022bc7..24ff793 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -558,7 +558,7 @@ static inline int __sctp_style(const struct sock *sk, sctp_socket_type_t style)
 /* Is the association in this state? */
 #define sctp_state(asoc, state) __sctp_state((asoc), (SCTP_STATE_##state))
 static inline int __sctp_state(const struct sctp_association *asoc,
-			       sctp_state_t state)
+			       enum sctp_state state)
 {
 	return asoc->state == state;
 }
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 860f378..281e8d1 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -175,10 +175,10 @@ sctp_state_fn_t sctp_sf_autoclose_timer_expire;
 
 /* Prototypes for utility support functions.  */
 __u8 sctp_get_chunk_type(struct sctp_chunk *chunk);
-const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *,
-					    sctp_event_t,
-					    sctp_state_t,
-					    sctp_subtype_t);
+const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
+						  sctp_event_t event_type,
+						  enum sctp_state state,
+						  sctp_subtype_t event_subtype);
 int sctp_chunk_iif(const struct sctp_chunk *);
 struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *,
 					     struct sctp_chunk *,
@@ -313,7 +313,7 @@ struct sctp_chunk *sctp_process_strreset_resp(
 /* Prototypes for statetable processing. */
 
 int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
-	       sctp_state_t state,
+	       enum sctp_state state,
                struct sctp_endpoint *,
                struct sctp_association *asoc,
                void *event_arg,
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6fab67e..fbe6e81 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1577,7 +1577,7 @@ struct sctp_association {
 	 *
 	 *		State takes values from SCTP_STATE_*.
 	 */
-	sctp_state_t state;
+	enum sctp_state state;
 
 	/* Overall     : The overall association error count.
 	 * Error Count : [Clear this any time I get something.]
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 3d506b2..4111c00 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -383,7 +383,7 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 	struct sctp_chunk *chunk;
 	struct sctp_inq *inqueue;
 	sctp_subtype_t subtype;
-	sctp_state_t state;
+	enum sctp_state state;
 	int error = 0;
 	int first_time = 1;	/* is this the first time through the loop */
 
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index f0553a0..1fb5b9b 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -54,7 +54,7 @@ int sctp_primitive_ ## name(struct net *net, struct sctp_association *asoc, \
 			    void *arg) { \
 	int error = 0; \
 	sctp_event_t event_type; sctp_subtype_t subtype; \
-	sctp_state_t state; \
+	enum sctp_state state; \
 	struct sctp_endpoint *ep; \
 	\
 	event_type = SCTP_EVENT_T_PRIMITIVE; \
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 5dda8c4..b77a81a 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -53,7 +53,7 @@
 
 static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_subtype_t subtype,
-				sctp_state_t state,
+				enum sctp_state state,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
 				void *event_arg,
@@ -61,7 +61,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_cmd_seq_t *commands,
 				gfp_t gfp);
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
-			     sctp_state_t state,
+			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
 			     void *event_arg,
@@ -843,7 +843,7 @@ static void sctp_cmd_assoc_update(sctp_cmd_seq_t *cmds,
 /* Helper function to change the state of an association. */
 static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
 			       struct sctp_association *asoc,
-			       sctp_state_t state)
+			       enum sctp_state state)
 {
 	struct sock *sk = asoc->base.sk;
 
@@ -1140,7 +1140,7 @@ static void sctp_cmd_send_asconf(struct sctp_association *asoc)
  * good place to start.
  */
 int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
-	       sctp_state_t state,
+	       enum sctp_state state,
 	       struct sctp_endpoint *ep,
 	       struct sctp_association *asoc,
 	       void *event_arg,
@@ -1179,7 +1179,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
  * This the master state function side effect processing function.
  *****************************************************************/
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
-			     sctp_state_t state,
+			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
 			     void *event_arg,
@@ -1265,7 +1265,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 /* This is the side-effect interpreter.  */
 static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_subtype_t subtype,
-				sctp_state_t state,
+				enum sctp_state state,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
 				void *event_arg,
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 3e958c1..f46c11b 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -52,9 +52,10 @@ other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES];
 static const sctp_sm_table_entry_t
 timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES];
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
-							    enum sctp_cid cid,
-							    sctp_state_t state);
+static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(
+						struct net *net,
+						enum sctp_cid cid,
+						enum sctp_state state);
 
 
 static const sctp_sm_table_entry_t bug = {
@@ -78,7 +79,7 @@ static const sctp_sm_table_entry_t bug = {
 
 const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
 						  sctp_event_t event_type,
-						  sctp_state_t state,
+						  enum sctp_state state,
 						  sctp_subtype_t event_subtype)
 {
 	switch (event_type) {
@@ -967,9 +968,10 @@ static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][S
 	TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE,
 };
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
-							    enum sctp_cid cid,
-							    sctp_state_t state)
+static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(
+						struct net *net,
+						enum sctp_cid cid,
+						enum sctp_state state)
 {
 	if (state > SCTP_STATE_MAX)
 		return &bug;
-- 
2.1.0
