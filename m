From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/14] sctp: remove the typedef sctp_event_primitive_t
Date: Sat,  5 Aug 2017 20:00:00 +0800
Message-ID: <d2af679ab5fa9b939e37f7b8ac51097c70280f2d.1501934087.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38086 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:32 -0400
In-Reply-To: <6f17de8a0a6d21445de859c4073b235e9c5d2163.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_event_primitive_t, and
replace with enum sctp_event_primitive in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index db9f40b..162ee95 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -110,7 +110,7 @@ typedef enum {
 #define SCTP_NUM_OTHER_TYPES		(SCTP_EVENT_OTHER_MAX + 1)
 
 /* These are primitive requests from the ULP.  */
-typedef enum {
+enum sctp_event_primitive {
 	SCTP_PRIMITIVE_ASSOCIATE = 0,
 	SCTP_PRIMITIVE_SHUTDOWN,
 	SCTP_PRIMITIVE_ABORT,
@@ -118,7 +118,7 @@ typedef enum {
 	SCTP_PRIMITIVE_REQUESTHEARTBEAT,
 	SCTP_PRIMITIVE_ASCONF,
 	SCTP_PRIMITIVE_RECONF,
-} sctp_event_primitive_t;
+};
 
 #define SCTP_EVENT_PRIMITIVE_MAX	SCTP_PRIMITIVE_RECONF
 #define SCTP_NUM_PRIMITIVE_TYPES	(SCTP_EVENT_PRIMITIVE_MAX + 1)
@@ -133,7 +133,7 @@ typedef union {
 	enum sctp_cid chunk;
 	sctp_event_timeout_t timeout;
 	sctp_event_other_t other;
-	sctp_event_primitive_t primitive;
+	enum sctp_event_primitive primitive;
 } sctp_subtype_t;
 
 #define SCTP_SUBTYPE_CONSTRUCTOR(_name, _type, _elt) \
@@ -144,7 +144,7 @@ SCTP_ST_## _name (_type _arg)		\
 SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		enum sctp_cid,		chunk)
 SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	sctp_event_timeout_t,	timeout)
 SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		sctp_event_other_t,	other)
-SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
+SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	enum sctp_event_primitive, primitive)
 
 
 #define sctp_chunk_is_data(a) (a->chunk_hdr->type == SCTP_CID_DATA)
-- 
2.1.0
