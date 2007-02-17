From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/5][SCTP]: Implement SCTP_ADDR_CONFIRMED state for
	ADDR_CHANGE event.
Date: Fri, 16 Feb 2007 19:39:49 -0800
Message-ID: <1171683589.4568.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55001 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964928AbXBQDjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 22:39:52 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1H3eXJs024334
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:40:33 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1H3doRY167554
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:50 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1H3dnhr031121
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:50 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Implement SCTP_ADDR_CONFIRMED state for ADDR_CHANGE event.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/user.h |    1 +
 net/sctp/associola.c    |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index e773160..36a319e 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -263,6 +263,7 @@ enum sctp_spc_state {
 	SCTP_ADDR_REMOVED,
 	SCTP_ADDR_ADDED,
 	SCTP_ADDR_MADE_PRIM,
+	SCTP_ADDR_CONFIRMED,
 };
 
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index fa82b73..294be94 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -714,8 +714,16 @@ void sctp_assoc_control_transport(struct
 	/* Record the transition on the transport.  */
 	switch (command) {
 	case SCTP_TRANSPORT_UP:
+		/* If we are moving from UNCONFIRMED state due
+		 * to heartbeat success, report the SCTP_ADDR_CONFIRMED
+		 * state to the user, otherwise report SCTP_ADDR_AVAILABLE.
+		 */
+		if (SCTP_UNCONFIRMED == transport->state &&
+		    SCTP_HEARTBEAT_SUCCESS == error)
+			spc_state = SCTP_ADDR_CONFIRMED;
+		else
+			spc_state = SCTP_ADDR_AVAILABLE;
 		transport->state = SCTP_ACTIVE;
-		spc_state = SCTP_ADDR_AVAILABLE;
 		break;
 
 	case SCTP_TRANSPORT_DOWN:


