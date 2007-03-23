From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/6] [SCTP]: Implement SCTP_ADDR_CONFIRMED state for ADDR_CHNAGE event
Date: Fri, 23 Mar 2007 09:52:49 -0400
Message-ID: <11746579722239-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:49613 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422916AbXCWNw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:59 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |    1 +
 net/sctp/associola.c    |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 9a83527..4ed7521 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -265,6 +265,7 @@ enum sctp_spc_state {
 	SCTP_ADDR_REMOVED,
 	SCTP_ADDR_ADDED,
 	SCTP_ADDR_MADE_PRIM,
+	SCTP_ADDR_CONFIRMED,
 };
 
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index fa82b73..294be94 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -714,8 +714,16 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
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
-- 
1.5.0.3.438.gc49b2

