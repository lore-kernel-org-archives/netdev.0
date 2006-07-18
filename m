From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/6][SCTP]: Set chunk->data_accepted only if we are going
	to accept it.
Date: Mon, 17 Jul 2006 17:25:32 -0700
Message-ID: <1153182332.4282.46.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:47825 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751264AbWGRA2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:28:05 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0S4KS016068
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:04 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0S41l278718
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0S30o026905
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:03 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Set chunk->data_accepted only if we are going to accept it.

Currently there is a code path in sctp_eat_data() where it is possible
to set this flag even when we are dropping this chunk.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_statefuns.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index e8498dc..ead3f1b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5283,7 +5283,6 @@ static int sctp_eat_data(const struct sc
 	datalen -= sizeof(sctp_data_chunk_t);
 
 	deliver = SCTP_CMD_CHUNK_ULP;
-	chunk->data_accepted = 1;
 
 	/* Think about partial delivery. */
 	if ((datalen >= asoc->rwnd) && (!asoc->ulpq.pd_mode)) {
@@ -5362,6 +5361,8 @@ static int sctp_eat_data(const struct sc
 	if (SCTP_CMD_CHUNK_ULP == deliver)
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
 
+	chunk->data_accepted = 1;
+
 	/* Note: Some chunks may get overcounted (if we drop) or overcounted
 	 * if we renege and the chunk arrives again.
 	 */


