From: Chunbo Luo <chunbo.luo@windriver.com>
Subject: [PATCH 1/2] sctp: fix heartbeat count of association failure
Date: Wed, 19 Aug 2009 15:01:07 +0800
Message-ID: <1250665268-29770-1-git-send-email-chunbo.luo@windriver.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	chunbo.luo@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36894 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbZHSHBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 03:01:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4960 Section 8.1 defined that the association should enter CLOSE
state when the value of association error counter exceeds the limit 
indicated in the protocol parameter 'Association.Max.Retrans'. This
means that the association should enter CLOSE state after max_retrans+1 
heartbeats are not acknowledged.

Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
---
 net/sctp/sm_statefuns.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7288192..90e4f06 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5190,7 +5190,7 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(const struct sctp_endpoint *ep,
 
 	SCTP_INC_STATS(SCTP_MIB_T3_RTX_EXPIREDS);
 
-	if (asoc->overall_error_count >= asoc->max_retrans) {
+	if (asoc->overall_error_count > asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
 		/* CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
@@ -5404,7 +5404,7 @@ sctp_disposition_t sctp_sf_t2_timer_expire(const struct sctp_endpoint *ep,
 
 	((struct sctp_association *)asoc)->shutdown_retries++;
 
-	if (asoc->overall_error_count >= asoc->max_retrans) {
+	if (asoc->overall_error_count > asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
 		/* Note:  CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
@@ -5487,7 +5487,7 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
 	 * RFC2960 [5] section 8.1 and 8.2.
 	 * association error counter is incremented in SCTP_CMD_STRIKE.
 	 */
-	if (asoc->overall_error_count >= asoc->max_retrans) {
+	if (asoc->overall_error_count > asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_T4_RTO));
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
-- 
1.6.4

