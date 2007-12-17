From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 5/9] SCTP: ADD-IP updates the states where ASCONFs can be sent
Date: Mon, 17 Dec 2007 16:32:45 -0500
Message-ID: <1197927169-5106-6-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15317 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760558AbXLQVcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:54 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   C4)  Both ASCONF and ASCONF-ACK Chunks MUST NOT be sent in any SCTP
        state except ESTABLISHED, SHUTDOWN-PENDING, SHUTDOWN-RECEIVED,
        and SHUTDOWN-SENT.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statetable.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index a93a4bc..e6016e4 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -457,11 +457,11 @@ static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][
 	/* SCTP_STATE_ESTABLISHED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_asconf), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ASCONF */
@@ -478,11 +478,11 @@ static const sctp_sm_table_entry_t chunk_event_table[SCTP_NUM_BASE_CHUNK_TYPES][
 	/* SCTP_STATE_ESTABLISHED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_asconf_ack), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf_ack), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf_ack), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf_ack), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ASCONF_ACK */
@@ -691,11 +691,11 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 	/* SCTP_STATE_ESTABLISHED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_prm_asconf), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_asconf), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_asconf), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_asconf), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 } /* TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT */
-- 
1.5.3.5

