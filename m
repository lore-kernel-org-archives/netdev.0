From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 13/14] sctp: remove the typedef sctp_event_t
Date: Sat,  5 Aug 2017 20:00:03 +0800
Message-ID: <b02005a06e5caefc27759eac596575ed220231d5.1501934087.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38174 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdHEMB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:57 -0400
In-Reply-To: <e28909498a887e760a615c6ff5ab04153621bfab.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_event_t, and
replace with enum sctp_event in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  6 ++----
 include/net/sctp/sm.h        | 12 +++++-------
 net/sctp/primitive.c         |  2 +-
 net/sctp/sm_sideeffect.c     | 20 +++++++++-----------
 net/sctp/sm_statetable.c     |  2 +-
 5 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index fb931f0..3181e0f 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -71,14 +71,12 @@ enum { SCTP_DEFAULT_INSTREAMS = SCTP_MAX_STREAM };
 					 SCTP_NUM_AUTH_CHUNK_TYPES)
 
 /* These are the different flavours of event.  */
-typedef enum {
-
+enum sctp_event {
 	SCTP_EVENT_T_CHUNK = 1,
 	SCTP_EVENT_T_TIMEOUT,
 	SCTP_EVENT_T_OTHER,
 	SCTP_EVENT_T_PRIMITIVE
-
-} sctp_event_t;
+};
 
 /* As a convenience for the state machine, we append SCTP_EVENT_* and
  * SCTP_ULP_* to the list of possible chunks.
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 281e8d1..96f54cf 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -176,7 +176,7 @@ sctp_state_fn_t sctp_sf_autoclose_timer_expire;
 /* Prototypes for utility support functions.  */
 __u8 sctp_get_chunk_type(struct sctp_chunk *chunk);
 const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
-						  sctp_event_t event_type,
+						  enum sctp_event event_type,
 						  enum sctp_state state,
 						  sctp_subtype_t event_subtype);
 int sctp_chunk_iif(const struct sctp_chunk *);
@@ -312,12 +312,10 @@ struct sctp_chunk *sctp_process_strreset_resp(
 
 /* Prototypes for statetable processing. */
 
-int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
-	       enum sctp_state state,
-               struct sctp_endpoint *,
-               struct sctp_association *asoc,
-               void *event_arg,
-	       gfp_t gfp);
+int sctp_do_sm(struct net *net, enum sctp_event event_type,
+	       sctp_subtype_t subtype, enum sctp_state state,
+	       struct sctp_endpoint *ep, struct sctp_association *asoc,
+	       void *event_arg, gfp_t gfp);
 
 /* 2nd level prototypes */
 void sctp_generate_t3_rtx_event(unsigned long peer);
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index 1fb5b9b..c914166 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -53,7 +53,7 @@
 int sctp_primitive_ ## name(struct net *net, struct sctp_association *asoc, \
 			    void *arg) { \
 	int error = 0; \
-	sctp_event_t event_type; sctp_subtype_t subtype; \
+	enum sctp_event event_type; sctp_subtype_t subtype; \
 	enum sctp_state state; \
 	struct sctp_endpoint *ep; \
 	\
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 11a3448..b545c76 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -51,7 +51,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-static int sctp_cmd_interpreter(sctp_event_t event_type,
+static int sctp_cmd_interpreter(enum sctp_event event_type,
 				sctp_subtype_t subtype,
 				enum sctp_state state,
 				struct sctp_endpoint *ep,
@@ -60,7 +60,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_disposition_t status,
 				sctp_cmd_seq_t *commands,
 				gfp_t gfp);
-static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
+static int sctp_side_effects(enum sctp_event event_type, sctp_subtype_t subtype,
 			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
@@ -602,7 +602,7 @@ static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 /* Worker routine to handle SCTP_CMD_ASSOC_FAILED.  */
 static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 				  struct sctp_association *asoc,
-				  sctp_event_t event_type,
+				  enum sctp_event event_type,
 				  sctp_subtype_t subtype,
 				  struct sctp_chunk *chunk,
 				  unsigned int error)
@@ -1139,12 +1139,10 @@ static void sctp_cmd_send_asconf(struct sctp_association *asoc)
  * If you want to understand all of lksctp, this is a
  * good place to start.
  */
-int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
-	       enum sctp_state state,
-	       struct sctp_endpoint *ep,
-	       struct sctp_association *asoc,
-	       void *event_arg,
-	       gfp_t gfp)
+int sctp_do_sm(struct net *net, enum sctp_event event_type,
+	       sctp_subtype_t subtype, enum sctp_state state,
+	       struct sctp_endpoint *ep, struct sctp_association *asoc,
+	       void *event_arg, gfp_t gfp)
 {
 	sctp_cmd_seq_t commands;
 	const sctp_sm_table_entry_t *state_fn;
@@ -1178,7 +1176,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
 /*****************************************************************
  * This the master state function side effect processing function.
  *****************************************************************/
-static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
+static int sctp_side_effects(enum sctp_event event_type, sctp_subtype_t subtype,
 			     enum sctp_state state,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
@@ -1263,7 +1261,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
  ********************************************************************/
 
 /* This is the side-effect interpreter.  */
-static int sctp_cmd_interpreter(sctp_event_t event_type,
+static int sctp_cmd_interpreter(enum sctp_event event_type,
 				sctp_subtype_t subtype,
 				enum sctp_state state,
 				struct sctp_endpoint *ep,
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index f46c11b..f7cdb70 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -78,7 +78,7 @@ static const sctp_sm_table_entry_t bug = {
 })
 
 const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
-						  sctp_event_t event_type,
+						  enum sctp_event event_type,
 						  enum sctp_state state,
 						  sctp_subtype_t event_subtype)
 {
-- 
2.1.0
