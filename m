From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 5/5][SCTP]: Strike the transport before updating rto.
Date: Fri, 16 Feb 2007 19:40:04 -0800
Message-ID: <1171683604.4568.14.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:50658 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946399AbXBQDkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 22:40:06 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1H3e5HT003001
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:40:05 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1H3e57u270662
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:40:05 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1H3e4dH005074
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:40:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Strike the transport before updating rto.

Once we reach a point where we exceed the max.path.retrans, strike the
transport before updating the rto.  This will force transport switch at
the right time, instead of 1 retransmit too late.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_statefuns.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b3cad8a..70c39ea 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4605,12 +4605,12 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(
 	 * sent as soon as cwnd allows (normally when a SACK arrives).
 	 */
 
-	/* NB: Rules E4 and F1 are implicit in R1.  */
-	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN, SCTP_TRANSPORT(transport));
-
 	/* Do some failure management (Section 8.2). */
 	sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE, SCTP_TRANSPORT(transport));
 
+	/* NB: Rules E4 and F1 are implicit in R1.  */
+	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN, SCTP_TRANSPORT(transport));
+
 	return SCTP_DISPOSITION_CONSUME;
 }
 


