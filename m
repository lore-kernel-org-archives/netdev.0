From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 12/14] sctp: remove the typedef sctp_event_timeout_t
Date: Sat,  5 Aug 2017 20:00:02 +0800
Message-ID: <e28909498a887e760a615c6ff5ab04153621bfab.1501934087.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36493 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbdHEMBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:49 -0400
In-Reply-To: <d526b6acfb360ee28fbf70f198b6cce67a9f1c35.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_event_timeout_t, and
replace with enum sctp_event_timeout in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h   | 4 ++--
 include/net/sctp/constants.h | 8 ++++----
 net/sctp/sm_sideeffect.c     | 6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index be12ec9..376cb78 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -127,7 +127,7 @@ typedef union {
 	int error;
 	__be16 err;
 	enum sctp_state state;
-	sctp_event_timeout_t to;
+	enum sctp_event_timeout to;
 	struct sctp_chunk *chunk;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
@@ -168,7 +168,7 @@ SCTP_ARG_CONSTRUCTOR(U8,	__u8, u8)
 SCTP_ARG_CONSTRUCTOR(ERROR,     int, error)
 SCTP_ARG_CONSTRUCTOR(PERR,      __be16, err)	/* protocol error */
 SCTP_ARG_CONSTRUCTOR(STATE,	enum sctp_state, state)
-SCTP_ARG_CONSTRUCTOR(TO,	sctp_event_timeout_t, to)
+SCTP_ARG_CONSTRUCTOR(TO,	enum sctp_event_timeout, to)
 SCTP_ARG_CONSTRUCTOR(CHUNK,	struct sctp_chunk *, chunk)
 SCTP_ARG_CONSTRUCTOR(ASOC,	struct sctp_association *, asoc)
 SCTP_ARG_CONSTRUCTOR(TRANSPORT,	struct sctp_transport *, transport)
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index fd8a80e..fb931f0 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -84,7 +84,7 @@ typedef enum {
  * SCTP_ULP_* to the list of possible chunks.
  */
 
-typedef enum {
+enum sctp_event_timeout {
 	SCTP_EVENT_TIMEOUT_NONE = 0,
 	SCTP_EVENT_TIMEOUT_T1_COOKIE,
 	SCTP_EVENT_TIMEOUT_T1_INIT,
@@ -96,7 +96,7 @@ typedef enum {
 	SCTP_EVENT_TIMEOUT_RECONF,
 	SCTP_EVENT_TIMEOUT_SACK,
 	SCTP_EVENT_TIMEOUT_AUTOCLOSE,
-} sctp_event_timeout_t;
+};
 
 #define SCTP_EVENT_TIMEOUT_MAX		SCTP_EVENT_TIMEOUT_AUTOCLOSE
 #define SCTP_NUM_TIMEOUT_TYPES		(SCTP_EVENT_TIMEOUT_MAX + 1)
@@ -131,7 +131,7 @@ enum sctp_event_primitive {
 
 typedef union {
 	enum sctp_cid chunk;
-	sctp_event_timeout_t timeout;
+	enum sctp_event_timeout timeout;
 	enum sctp_event_other other;
 	enum sctp_event_primitive primitive;
 } sctp_subtype_t;
@@ -142,7 +142,7 @@ SCTP_ST_## _name (_type _arg)		\
 { sctp_subtype_t _retval; _retval._elt = _arg; return _retval; }
 
 SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		enum sctp_cid,		chunk)
-SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	sctp_event_timeout_t,	timeout)
+SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	enum sctp_event_timeout, timeout)
 SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		enum sctp_event_other,	other)
 SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	enum sctp_event_primitive, primitive)
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index b77a81a..11a3448 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -280,7 +280,7 @@ void sctp_generate_t3_rtx_event(unsigned long peer)
  * for timeouts which use the association as their parameter.
  */
 static void sctp_generate_timeout_event(struct sctp_association *asoc,
-					sctp_event_timeout_t timeout_type)
+					enum sctp_event_timeout timeout_type)
 {
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
@@ -1052,8 +1052,8 @@ static void sctp_cmd_adaptation_ind(sctp_cmd_seq_t *commands,
 
 
 static void sctp_cmd_t1_timer_update(struct sctp_association *asoc,
-				    sctp_event_timeout_t timer,
-				    char *name)
+				     enum sctp_event_timeout timer,
+				     char *name)
 {
 	struct sctp_transport *t;
 
-- 
2.1.0
