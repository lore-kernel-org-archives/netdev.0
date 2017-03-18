From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: define dst_pending_confirm as a bit in sctp_transport
Date: Sat, 18 Mar 2017 19:27:23 +0800
Message-ID: <b4390881b14adce583817529e5d58599acb5a8ee.1489836443.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, ja@ssi.bg
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35552 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdCRLeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 07:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As tp->dst_pending_confirm's value can only be set 0 or 1, this
patch is to change to define it as a bit instead of __u32.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 07a0b12..4f64519 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -753,6 +753,8 @@ struct sctp_transport {
 		/* Is the Path MTU update pending on this tranport */
 		pmtu_pending:1,
 
+		dst_pending_confirm:1,	/* need to confirm neighbour */
+
 		/* Has this transport moved the ctsn since we last sacked */
 		sack_generation:1;
 	u32 dst_cookie;
@@ -806,8 +808,6 @@ struct sctp_transport {
 
 	__u32 burst_limited;	/* Holds old cwnd when max.burst is applied */
 
-	__u32 dst_pending_confirm;	/* need to confirm neighbour */
-
 	/* Destination */
 	struct dst_entry *dst;
 	/* Source address. */
-- 
2.1.0
