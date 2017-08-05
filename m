From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/14] sctp: remove the typedef sctp_event_other_t
Date: Sat,  5 Aug 2017 20:00:01 +0800
Message-ID: <d526b6acfb360ee28fbf70f198b6cce67a9f1c35.1501934087.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36555 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbdHEMBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:40 -0400
In-Reply-To: <d2af679ab5fa9b939e37f7b8ac51097c70280f2d.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_event_other_t, and
replace with enum sctp_event_other in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 162ee95..fd8a80e 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -101,10 +101,10 @@ typedef enum {
 #define SCTP_EVENT_TIMEOUT_MAX		SCTP_EVENT_TIMEOUT_AUTOCLOSE
 #define SCTP_NUM_TIMEOUT_TYPES		(SCTP_EVENT_TIMEOUT_MAX + 1)
 
-typedef enum {
+enum sctp_event_other {
 	SCTP_EVENT_NO_PENDING_TSN = 0,
 	SCTP_EVENT_ICMP_PROTO_UNREACH,
-} sctp_event_other_t;
+};
 
 #define SCTP_EVENT_OTHER_MAX		SCTP_EVENT_ICMP_PROTO_UNREACH
 #define SCTP_NUM_OTHER_TYPES		(SCTP_EVENT_OTHER_MAX + 1)
@@ -132,7 +132,7 @@ enum sctp_event_primitive {
 typedef union {
 	enum sctp_cid chunk;
 	sctp_event_timeout_t timeout;
-	sctp_event_other_t other;
+	enum sctp_event_other other;
 	enum sctp_event_primitive primitive;
 } sctp_subtype_t;
 
@@ -143,7 +143,7 @@ SCTP_ST_## _name (_type _arg)		\
 
 SCTP_SUBTYPE_CONSTRUCTOR(CHUNK,		enum sctp_cid,		chunk)
 SCTP_SUBTYPE_CONSTRUCTOR(TIMEOUT,	sctp_event_timeout_t,	timeout)
-SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		sctp_event_other_t,	other)
+SCTP_SUBTYPE_CONSTRUCTOR(OTHER,		enum sctp_event_other,	other)
 SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	enum sctp_event_primitive, primitive)
 
 
-- 
2.1.0
