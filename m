From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] [SCTP]: Replace char msg[] with static const char[].
Date: Thu, 20 Mar 2008 13:26:34 +0100
Message-ID: <1206015994-13362-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39160 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751514AbYCTMXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 08:23:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

133886    2004     220  136110   213ae sctp.new/sctp.o
134018    2004     220  136242   21432 sctp.old/sctp.o

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 patch was previously sent on Mar. 14th 08.

 net/sctp/sm_make_chunk.c |    2 +-
 net/sctp/sm_statefuns.c  |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 578630e..c898245 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1782,7 +1782,7 @@ static int sctp_process_inv_paramlength(const struct sctp_association *asoc,
 					const struct sctp_chunk *chunk,
 					struct sctp_chunk **errp)
 {
-	char		error[] = "The following parameter had invalid length:";
+	static const char error[] = "The following parameter had invalid length:";
 	size_t		payload_len = WORD_ROUND(sizeof(error)) +
 						sizeof(sctp_paramhdr_t);
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c0c6bee..6545b5f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4219,7 +4219,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	char err_str[]="The following chunk had invalid length:";
+	static const char err_str[]="The following chunk had invalid length:";
 
 	return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
@@ -4236,7 +4236,7 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 				     const sctp_subtype_t type,
 				     void *arg,
 				     sctp_cmd_seq_t *commands) {
-	char err_str[] = "The following parameter had invalid length:";
+	static const char err_str[] = "The following parameter had invalid length:";
 
 	return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
@@ -4255,7 +4255,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	char err_str[]="The cumulative tsn ack beyond the max tsn currently sent:";
+	static const char err_str[]="The cumulative tsn ack beyond the max tsn currently sent:";
 
 	return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
@@ -4274,7 +4274,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	char err_str[]="The following chunk violates protocol:";
+	static const char err_str[]="The following chunk violates protocol:";
 
 	if (!asoc)
 		return sctp_sf_violation(ep, asoc, type, arg, commands);
-- 
1.5.3.7

