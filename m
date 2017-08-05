From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 14/14] sctp: remove the typedef sctp_subtype_t
Date: Sat,  5 Aug 2017 20:00:04 +0800
Message-ID: <c9fe50fa7958d7aa0736426b913769f119efbd9f.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
 <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
 <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
 <a26ddefe25442293b3e1020ce56f859125a93412.1501934087.git.lucien.xin@gmail.com>
 <1bd9e98627fc627a28f90ad587e941845b91b108.1501934087.git.lucien.xin@gmail.com>
 <6f17de8a0a6d21445de859c4073b235e9c5d2163.1501934087.git.lucien.xin@gmail.com>
 <d2af679ab5fa9b939e37f7b8ac51097c70280f2d.1501934087.git.lucien.xin@gmail.com>
 <d526b6acfb360ee28fbf70f198b6cce67a9f1c35.1501934087.git.lucien.xin@gmail.com>
 <e28909498a887e760a615c6ff5ab04153621bfab.1501934087.git.lucien.xin@gmail.com>
 <b02005a06e5caefc27759eac596575ed220231d5.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38755 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdHEMCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:02:06 -0400
In-Reply-To: <b02005a06e5caefc27759eac596575ed220231d5.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_subtype_t, and
replace with union sctp_subtype in the places where it's
using this typedef.

Note that it doesn't fix many indents although it should,
as sctp_disposition_t's removal would mess them up again.
So better to fix them when removing sctp_disposition_t in
later patch.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  18 ++--
 include/net/sctp/sm.h        |  13 +--
 net/sctp/associola.c         |   2 +-
 net/sctp/debug.c             |   8 +-
 net/sctp/endpointola.c       |   2 +-
 net/sctp/primitive.c         |   2 +-
 net/sctp/probe.c             |   2 +-
 net/sctp/sm_sideeffect.c     |  16 ++--
 net/sctp/sm_statefuns.c      | 191 ++++++++++++++++++++++---------------------
 net/sctp/sm_statetable.c     |   9 +-
 10 files changed, 134 insertions(+), 129 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 3181e0f..deaafa9 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -124,20 +124,20 @@ enum sctp_event_primitive {
 /* We define here a utility type for manipulating subtypes.
  * The subtype constructors all work like this:
  *
- * 	sctp_subtype_t foo = SCTP_ST_CHUNK(SCTP_CID_INIT);
+ *   union sctp_subtype foo = SCTP_ST_CHUNK(SCTP_CID_INIT);
  */
 
-typedef union {
+union sctp_subtype {
 	enum sctp_cid chunk;
 	enum sctp_event_timeout timeout;
 	enum sctp_event_other other;
 	enum sctp_event_primitive primitive;
-} sctp_subtype_t;
+};
 
 #define SCTP_SUBTYPE_CONSTRUCTOR(_name, _type, _elt) \
-static inline sctp_subtype_t	\
+static inline union sctp_subtype	\
 SCTP_ST_## _name (_type _arg)		\
-{ sctp_subtype_t _retval; _retval._elt = _arg; return _retval; }
+{ union sctp_subtype _retval; _retval._elt = _arg; return _retval; }
 
 SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		enum sctp_cid,		chunk)
 SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	enum sctp_event_timeout, timeout)
@@ -220,10 +220,10 @@ enum sctp_sock_state {
 };
 
 /* These functions map various type to printable names.  */
-const char *sctp_cname(const sctp_subtype_t);	/* chunk types */
-const char *sctp_oname(const sctp_subtype_t);	/* other events */
-const char *sctp_tname(const sctp_subtype_t);	/* timeouts */
-const char *sctp_pname(const sctp_subtype_t);	/* primitives */
+const char *sctp_cname(const union sctp_subtype id);	/* chunk types */
+const char *sctp_oname(const union sctp_subtype id);	/* other events */
+const char *sctp_tname(const union sctp_subtype id);	/* timeouts */
+const char *sctp_pname(const union sctp_subtype id);	/* primitives */
 
 /* This is a table of printable names of sctp_state_t's.  */
 extern const char *const sctp_state_tbl[];
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 96f54cf..1e7651c 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -73,7 +73,7 @@ typedef struct {
 typedef sctp_disposition_t (sctp_state_fn_t) (struct net *,
 					      const struct sctp_endpoint *,
 					      const struct sctp_association *,
-					      const sctp_subtype_t type,
+					      const union sctp_subtype type,
 					      void *arg,
 					      sctp_cmd_seq_t *);
 typedef void (sctp_timer_event_t) (unsigned long);
@@ -175,10 +175,11 @@ sctp_state_fn_t sctp_sf_autoclose_timer_expire;
 
 /* Prototypes for utility support functions.  */
 __u8 sctp_get_chunk_type(struct sctp_chunk *chunk);
-const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
-						  enum sctp_event event_type,
-						  enum sctp_state state,
-						  sctp_subtype_t event_subtype);
+const sctp_sm_table_entry_t *sctp_sm_lookup_event(
+					struct net *net,
+					enum sctp_event event_type,
+					enum sctp_state state,
+					union sctp_subtype event_subtype);
 int sctp_chunk_iif(const struct sctp_chunk *);
 struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *,
 					     struct sctp_chunk *,
@@ -313,7 +314,7 @@ struct sctp_chunk *sctp_process_strreset_resp(
 /* Prototypes for statetable processing. */
 
 int sctp_do_sm(struct net *net, enum sctp_event event_type,
-	       sctp_subtype_t subtype, enum sctp_state state,
+	       union sctp_subtype subtype, enum sctp_state state,
 	       struct sctp_endpoint *ep, struct sctp_association *asoc,
 	       void *event_arg, gfp_t gfp);
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b53efed..dfb9651 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1021,11 +1021,11 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 		container_of(work, struct sctp_association,
 			     base.inqueue.immediate);
 	struct net *net = sock_net(asoc->base.sk);
+	union sctp_subtype subtype;
 	struct sctp_endpoint *ep;
 	struct sctp_chunk *chunk;
 	struct sctp_inq *inqueue;
 	int state;
-	sctp_subtype_t subtype;
 	int error = 0;
 
 	/* The association should be held so we should be safe. */
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 2e47eb2..3f619fd 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -60,7 +60,7 @@ static const char *const sctp_cid_tbl[SCTP_NUM_BASE_CHUNK_TYPES] = {
 };
 
 /* Lookup "chunk type" debug name. */
-const char *sctp_cname(const sctp_subtype_t cid)
+const char *sctp_cname(const union sctp_subtype cid)
 {
 	if (cid.chunk <= SCTP_CID_BASE_MAX)
 		return sctp_cid_tbl[cid.chunk];
@@ -130,7 +130,7 @@ static const char *const sctp_primitive_tbl[SCTP_NUM_PRIMITIVE_TYPES] = {
 };
 
 /* Lookup primitive debug name. */
-const char *sctp_pname(const sctp_subtype_t id)
+const char *sctp_pname(const union sctp_subtype id)
 {
 	if (id.primitive <= SCTP_EVENT_PRIMITIVE_MAX)
 		return sctp_primitive_tbl[id.primitive];
@@ -143,7 +143,7 @@ static const char *const sctp_other_tbl[] = {
 };
 
 /* Lookup "other" debug name. */
-const char *sctp_oname(const sctp_subtype_t id)
+const char *sctp_oname(const union sctp_subtype id)
 {
 	if (id.other <= SCTP_EVENT_OTHER_MAX)
 		return sctp_other_tbl[id.other];
@@ -165,7 +165,7 @@ static const char *const sctp_timer_tbl[] = {
 };
 
 /* Lookup timer debug name. */
-const char *sctp_tname(const sctp_subtype_t id)
+const char *sctp_tname(const union sctp_subtype id)
 {
 	BUILD_BUG_ON(SCTP_EVENT_TIMEOUT_MAX + 1 != ARRAY_SIZE(sctp_timer_tbl));
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 4111c00..ee1e601 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -382,7 +382,7 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 	struct sctp_transport *transport;
 	struct sctp_chunk *chunk;
 	struct sctp_inq *inqueue;
-	sctp_subtype_t subtype;
+	union sctp_subtype subtype;
 	enum sctp_state state;
 	int error = 0;
 	int first_time = 1;	/* is this the first time through the loop */
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index c914166..c0817f7a 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -53,7 +53,7 @@
 int sctp_primitive_ ## name(struct net *net, struct sctp_association *asoc, \
 			    void *arg) { \
 	int error = 0; \
-	enum sctp_event event_type; sctp_subtype_t subtype; \
+	enum sctp_event event_type; union sctp_subtype subtype; \
 	enum sctp_state state; \
 	struct sctp_endpoint *ep; \
 	\
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 6cc2152..43837df 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -130,7 +130,7 @@ static const struct file_operations sctpprobe_fops = {
 static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 					    const struct sctp_endpoint *ep,
 					    const struct sctp_association *asoc,
-					    const sctp_subtype_t type,
+					    const union sctp_subtype type,
 					    void *arg,
 					    sctp_cmd_seq_t *commands)
 {
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index b545c76..4a12d29 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -52,7 +52,7 @@
 #include <net/sctp/sm.h>
 
 static int sctp_cmd_interpreter(enum sctp_event event_type,
-				sctp_subtype_t subtype,
+				union sctp_subtype subtype,
 				enum sctp_state state,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
@@ -60,7 +60,8 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 				sctp_disposition_t status,
 				sctp_cmd_seq_t *commands,
 				gfp_t gfp);
-static int sctp_side_effects(enum sctp_event event_type, sctp_subtype_t subtype,
+static int sctp_side_effects(enum sctp_event event_type,
+			     union sctp_subtype subtype,
 			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
@@ -603,7 +604,7 @@ static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 				  struct sctp_association *asoc,
 				  enum sctp_event event_type,
-				  sctp_subtype_t subtype,
+				  union sctp_subtype subtype,
 				  struct sctp_chunk *chunk,
 				  unsigned int error)
 {
@@ -1140,7 +1141,7 @@ static void sctp_cmd_send_asconf(struct sctp_association *asoc)
  * good place to start.
  */
 int sctp_do_sm(struct net *net, enum sctp_event event_type,
-	       sctp_subtype_t subtype, enum sctp_state state,
+	       union sctp_subtype subtype, enum sctp_state state,
 	       struct sctp_endpoint *ep, struct sctp_association *asoc,
 	       void *event_arg, gfp_t gfp)
 {
@@ -1148,7 +1149,7 @@ int sctp_do_sm(struct net *net, enum sctp_event event_type,
 	const sctp_sm_table_entry_t *state_fn;
 	sctp_disposition_t status;
 	int error = 0;
-	typedef const char *(printfn_t)(sctp_subtype_t);
+	typedef const char *(printfn_t)(union sctp_subtype);
 	static printfn_t *table[] = {
 		NULL, sctp_cname, sctp_tname, sctp_oname, sctp_pname,
 	};
@@ -1176,7 +1177,8 @@ int sctp_do_sm(struct net *net, enum sctp_event event_type,
 /*****************************************************************
  * This the master state function side effect processing function.
  *****************************************************************/
-static int sctp_side_effects(enum sctp_event event_type, sctp_subtype_t subtype,
+static int sctp_side_effects(enum sctp_event event_type,
+			     union sctp_subtype subtype,
 			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
@@ -1262,7 +1264,7 @@ static int sctp_side_effects(enum sctp_event event_type, sctp_subtype_t subtype,
 
 /* This is the side-effect interpreter.  */
 static int sctp_cmd_interpreter(enum sctp_event event_type,
-				sctp_subtype_t subtype,
+				union sctp_subtype subtype,
 				enum sctp_state state,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5381697..ac6aaa0 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -80,19 +80,19 @@ static void sctp_send_stale_cookie_err(struct net *net,
 static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 const struct sctp_endpoint *ep,
 						 const struct sctp_association *asoc,
-						 const sctp_subtype_t type,
+						 const union sctp_subtype type,
 						 void *arg,
 						 sctp_cmd_seq_t *commands);
 static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 					     const struct sctp_endpoint *ep,
 					     const struct sctp_association *asoc,
-					     const sctp_subtype_t type,
+					     const union sctp_subtype type,
 					     void *arg,
 					     sctp_cmd_seq_t *commands);
 static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands);
 static struct sctp_sackhdr *sctp_sm_pull_sack(struct sctp_chunk *chunk);
@@ -116,7 +116,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
@@ -124,7 +124,7 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg, void *ext,
 				     sctp_cmd_seq_t *commands);
 
@@ -132,7 +132,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
@@ -140,7 +140,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
@@ -148,13 +148,13 @@ static enum sctp_ierror sctp_sf_authenticate(
 				struct net *net,
 				const struct sctp_endpoint *ep,
 				const struct sctp_association *asoc,
-				const sctp_subtype_t type,
+				const union sctp_subtype type,
 				struct sctp_chunk *chunk);
 
 static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands);
 
@@ -217,7 +217,7 @@ sctp_chunk_length_valid(struct sctp_chunk *chunk, __u16 required_length)
 sctp_disposition_t sctp_sf_do_4_C(struct net *net,
 				  const struct sctp_endpoint *ep,
 				  const struct sctp_association *asoc,
-				  const sctp_subtype_t type,
+				  const union sctp_subtype type,
 				  void *arg,
 				  sctp_cmd_seq_t *commands)
 {
@@ -303,7 +303,7 @@ sctp_disposition_t sctp_sf_do_4_C(struct net *net,
 sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -497,7 +497,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type,
+				       const union sctp_subtype type,
 				       void *arg,
 				       sctp_cmd_seq_t *commands)
 {
@@ -647,7 +647,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
-				      const sctp_subtype_t type, void *arg,
+				      const union sctp_subtype type, void *arg,
 				      sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
@@ -874,7 +874,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
-				      const sctp_subtype_t type, void *arg,
+				      const union sctp_subtype type, void *arg,
 				      sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
@@ -951,7 +951,7 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
 /* Generate and sendout a heartbeat packet.  */
 static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
 					    const struct sctp_association *asoc,
-					    const sctp_subtype_t type,
+					    const union sctp_subtype type,
 					    void *arg,
 					    sctp_cmd_seq_t *commands)
 {
@@ -977,7 +977,7 @@ static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
 sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -1025,7 +1025,7 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
 sctp_disposition_t sctp_sf_send_reconf(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type, void *arg,
+				       const union sctp_subtype type, void *arg,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_transport *transport = arg;
@@ -1076,7 +1076,7 @@ sctp_disposition_t sctp_sf_send_reconf(struct net *net,
 sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -1151,7 +1151,7 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -1416,7 +1416,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg, sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
@@ -1627,7 +1627,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 sctp_disposition_t sctp_sf_do_5_2_1_siminit(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -1681,7 +1681,7 @@ sctp_disposition_t sctp_sf_do_5_2_1_siminit(struct net *net,
 sctp_disposition_t sctp_sf_do_5_2_2_dupinit(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -1704,7 +1704,7 @@ sctp_disposition_t sctp_sf_do_5_2_2_dupinit(struct net *net,
 sctp_disposition_t sctp_sf_do_5_2_3_initack(struct net *net,
 					    const struct sctp_endpoint *ep,
 					    const struct sctp_association *asoc,
-					    const sctp_subtype_t type,
+					    const union sctp_subtype type,
 					    void *arg, sctp_cmd_seq_t *commands)
 {
 	/* Per the above section, we'll discard the chunk if we have an
@@ -2027,7 +2027,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_d(struct net *net,
 sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2146,7 +2146,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -2188,7 +2188,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
 sctp_disposition_t sctp_sf_shutdown_sent_abort(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2239,7 +2239,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -2266,7 +2266,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_abort(
 sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2330,7 +2330,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
 static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 const struct sctp_endpoint *ep,
 						 const struct sctp_association *asoc,
-						 const sctp_subtype_t type,
+						 const union sctp_subtype type,
 						 void *arg,
 						 sctp_cmd_seq_t *commands)
 {
@@ -2452,7 +2452,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2489,7 +2489,7 @@ sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
 static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2527,7 +2527,7 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -2566,7 +2566,7 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 sctp_disposition_t sctp_sf_cookie_wait_icmp_abort(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -2581,7 +2581,7 @@ sctp_disposition_t sctp_sf_cookie_wait_icmp_abort(struct net *net,
 sctp_disposition_t sctp_sf_cookie_echoed_abort(struct net *net,
 					       const struct sctp_endpoint *ep,
 					       const struct sctp_association *asoc,
-					       const sctp_subtype_t type,
+					       const union sctp_subtype type,
 					       void *arg,
 					       sctp_cmd_seq_t *commands)
 {
@@ -2653,7 +2653,7 @@ static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
 sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -2742,7 +2742,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -2795,7 +2795,7 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -2859,7 +2859,7 @@ sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
 sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
-				      const sctp_subtype_t type,
+				      const union sctp_subtype type,
 				      void *arg,
 				      sctp_cmd_seq_t *commands)
 {
@@ -2915,7 +2915,7 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 				   const struct sctp_endpoint *ep,
 				   const struct sctp_association *asoc,
-				   const sctp_subtype_t type,
+				   const union sctp_subtype type,
 				   void *arg,
 				   sctp_cmd_seq_t *commands)
 {
@@ -2972,7 +2972,7 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -3092,7 +3092,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -3183,7 +3183,7 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -3257,7 +3257,7 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -3307,7 +3307,7 @@ static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 sctp_disposition_t sctp_sf_operr_notify(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -3345,7 +3345,7 @@ sctp_disposition_t sctp_sf_operr_notify(struct net *net,
 sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -3428,7 +3428,7 @@ sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
 sctp_disposition_t sctp_sf_ootb(struct net *net,
 				const struct sctp_endpoint *ep,
 				const struct sctp_association *asoc,
-				const sctp_subtype_t type,
+				const union sctp_subtype type,
 				void *arg,
 				sctp_cmd_seq_t *commands)
 {
@@ -3521,7 +3521,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 					     const struct sctp_endpoint *ep,
 					     const struct sctp_association *asoc,
-					     const sctp_subtype_t type,
+					     const union sctp_subtype type,
 					     void *arg,
 					     sctp_cmd_seq_t *commands)
 {
@@ -3583,7 +3583,7 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
-				      const sctp_subtype_t type,
+				      const union sctp_subtype type,
 				      void *arg,
 				      sctp_cmd_seq_t *commands)
 {
@@ -3608,7 +3608,7 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
 sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type, void *arg,
+				     const union sctp_subtype type, void *arg,
 				     sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk	*chunk = arg;
@@ -3725,7 +3725,8 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 					 const struct sctp_endpoint *ep,
 					 const struct sctp_association *asoc,
-					 const sctp_subtype_t type, void *arg,
+					 const union sctp_subtype type,
+					 void *arg,
 					 sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk	*asconf_ack = arg;
@@ -3843,7 +3844,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type, void *arg,
+				     const union sctp_subtype type, void *arg,
 				     sctp_cmd_seq_t *commands)
 {
 	struct sctp_paramhdr *err_param = NULL;
@@ -3919,7 +3920,7 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type,
+				       const union sctp_subtype type,
 				       void *arg,
 				       sctp_cmd_seq_t *commands)
 {
@@ -3990,7 +3991,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -4082,7 +4083,7 @@ static enum sctp_ierror sctp_sf_authenticate(
 				struct net *net,
 				const struct sctp_endpoint *ep,
 				const struct sctp_association *asoc,
-				const sctp_subtype_t type,
+				const union sctp_subtype type,
 				struct sctp_chunk *chunk)
 {
 	struct sctp_authhdr *auth_hdr;
@@ -4157,7 +4158,7 @@ static enum sctp_ierror sctp_sf_authenticate(
 sctp_disposition_t sctp_sf_eat_auth(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -4254,7 +4255,7 @@ sctp_disposition_t sctp_sf_eat_auth(struct net *net,
 sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4334,7 +4335,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
 					 const struct sctp_endpoint *ep,
 					 const struct sctp_association *asoc,
-					 const sctp_subtype_t type,
+					 const union sctp_subtype type,
 					 void *arg,
 					 sctp_cmd_seq_t *commands)
 {
@@ -4374,7 +4375,7 @@ sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
 sctp_disposition_t sctp_sf_pdiscard(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -4402,7 +4403,7 @@ sctp_disposition_t sctp_sf_pdiscard(struct net *net,
 sctp_disposition_t sctp_sf_violation(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4540,7 +4541,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4560,7 +4561,7 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg, void *ext,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4603,7 +4604,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4623,7 +4624,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
+				     const union sctp_subtype type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
@@ -4698,7 +4699,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type,
+				       const union sctp_subtype type,
 				       void *arg,
 				       sctp_cmd_seq_t *commands)
 {
@@ -4810,7 +4811,7 @@ sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
 sctp_disposition_t sctp_sf_do_prm_send(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type,
+				       const union sctp_subtype type,
 				       void *arg,
 				       sctp_cmd_seq_t *commands)
 {
@@ -4850,7 +4851,7 @@ sctp_disposition_t sctp_sf_do_9_2_prm_shutdown(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -4906,7 +4907,7 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -4943,7 +4944,7 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
 sctp_disposition_t sctp_sf_error_closed(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -4957,7 +4958,7 @@ sctp_disposition_t sctp_sf_error_closed(struct net *net,
 sctp_disposition_t sctp_sf_error_shutdown(struct net *net,
 					  const struct sctp_endpoint *ep,
 					  const struct sctp_association *asoc,
-					  const sctp_subtype_t type,
+					  const union sctp_subtype type,
 					  void *arg,
 					  sctp_cmd_seq_t *commands)
 {
@@ -4984,7 +4985,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_shutdown(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5019,7 +5020,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_shutdown(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg, sctp_cmd_seq_t *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
@@ -5046,7 +5047,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5095,7 +5096,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5121,7 +5122,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5148,7 +5149,7 @@ sctp_disposition_t sctp_sf_shutdown_sent_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5179,7 +5180,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_prm_abort(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5215,7 +5216,7 @@ sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
 					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -5247,7 +5248,7 @@ sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
 sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -5264,7 +5265,7 @@ sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
 sctp_disposition_t sctp_sf_do_prm_reconf(struct net *net,
 					 const struct sctp_endpoint *ep,
 					 const struct sctp_association *asoc,
-					 const sctp_subtype_t type,
+					 const union sctp_subtype type,
 					 void *arg, sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
@@ -5282,7 +5283,7 @@ sctp_disposition_t sctp_sf_ignore_primitive(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5306,7 +5307,7 @@ sctp_disposition_t sctp_sf_do_no_pending_tsn(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5338,7 +5339,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5408,7 +5409,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5481,7 +5482,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
 sctp_disposition_t sctp_sf_ignore_other(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -5509,7 +5510,7 @@ sctp_disposition_t sctp_sf_ignore_other(struct net *net,
 sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
@@ -5597,7 +5598,7 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 sctp_disposition_t sctp_sf_do_6_2_sack(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
-				       const sctp_subtype_t type,
+				       const union sctp_subtype type,
 				       void *arg,
 				       sctp_cmd_seq_t *commands)
 {
@@ -5628,7 +5629,7 @@ sctp_disposition_t sctp_sf_do_6_2_sack(struct net *net,
 sctp_disposition_t sctp_sf_t1_init_timer_expire(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -5692,7 +5693,7 @@ sctp_disposition_t sctp_sf_t1_init_timer_expire(struct net *net,
 sctp_disposition_t sctp_sf_t1_cookie_timer_expire(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -5742,7 +5743,7 @@ sctp_disposition_t sctp_sf_t1_cookie_timer_expire(struct net *net,
 sctp_disposition_t sctp_sf_t2_timer_expire(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -5813,7 +5814,7 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5884,7 +5885,7 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
 sctp_disposition_t sctp_sf_t5_timer_expire(struct net *net,
 					   const struct sctp_endpoint *ep,
 					   const struct sctp_association *asoc,
-					   const sctp_subtype_t type,
+					   const union sctp_subtype type,
 					   void *arg,
 					   sctp_cmd_seq_t *commands)
 {
@@ -5921,7 +5922,7 @@ sctp_disposition_t sctp_sf_autoclose_timer_expire(
 	struct net *net,
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
-	const sctp_subtype_t type,
+	const union sctp_subtype type,
 	void *arg,
 	sctp_cmd_seq_t *commands)
 {
@@ -5963,7 +5964,7 @@ sctp_disposition_t sctp_sf_autoclose_timer_expire(
 sctp_disposition_t sctp_sf_not_impl(struct net *net,
 				    const struct sctp_endpoint *ep,
 				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
+				    const union sctp_subtype type,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
@@ -5981,7 +5982,7 @@ sctp_disposition_t sctp_sf_not_impl(struct net *net,
 sctp_disposition_t sctp_sf_bug(struct net *net,
 			       const struct sctp_endpoint *ep,
 			       const struct sctp_association *asoc,
-			       const sctp_subtype_t type,
+			       const union sctp_subtype type,
 			       void *arg,
 			       sctp_cmd_seq_t *commands)
 {
@@ -6002,7 +6003,7 @@ sctp_disposition_t sctp_sf_bug(struct net *net,
 sctp_disposition_t sctp_sf_timer_ignore(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
-					const sctp_subtype_t type,
+					const union sctp_subtype type,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index f7cdb70..d437f38 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -77,10 +77,11 @@ static const sctp_sm_table_entry_t bug = {
 	rtn;								\
 })
 
-const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
-						  enum sctp_event event_type,
-						  enum sctp_state state,
-						  sctp_subtype_t event_subtype)
+const sctp_sm_table_entry_t *sctp_sm_lookup_event(
+					struct net *net,
+					enum sctp_event event_type,
+					enum sctp_state state,
+					union sctp_subtype event_subtype)
 {
 	switch (event_type) {
 	case SCTP_EVENT_T_CHUNK:
-- 
2.1.0
