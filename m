From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/4] [SCTP]: Fix state table entries for chunks received in
	CLOSED state.
Date: Fri, 05 May 2006 12:14:50 -0700
Message-ID: <1146856490.7861.36.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:52384 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751720AbWEETOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 15:14:50 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k45JEnY1019586
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:49 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k45JEnP0243672
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k45JEn7G002098
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix state table entries for chunks received in CLOSED state.

Discard an unexpected chunk in CLOSED state rather can calling BUG().

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/sm_statetable.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 75ef104..8bcca56 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -366,9 +366,9 @@ #define TYPE_SCTP_ECN_ECNE { \
 	/* SCTP_STATE_EMPTY */ \
 	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
 	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
 	/* SCTP_STATE_ESTABLISHED */ \
@@ -380,7 +380,7 @@ #define TYPE_SCTP_ECN_ECNE { \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
 	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
 } /* TYPE_SCTP_ECN_ECNE */
 
 #define TYPE_SCTP_ECN_CWR { \
@@ -401,7 +401,7 @@ #define TYPE_SCTP_ECN_CWR { \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
 	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
 } /* TYPE_SCTP_ECN_CWR */
 
 #define TYPE_SCTP_SHUTDOWN_COMPLETE { \
@@ -647,7 +647,7 @@ #define TYPE_SCTP_PRIMITIVE_REQUESTHEART
 	/* SCTP_STATE_EMPTY */ \
 	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
 	 .name = "sctp_sf_do_prm_requestheartbeat"},          \


