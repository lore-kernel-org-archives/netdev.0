From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 06/15] RDS/IB: Rename byte_len to data_len to enhance readability
Date: Fri, 17 Jul 2009 16:13:27 -0700
Message-ID: <1247872416-17834-7-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:17655 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758022AbZGQXOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:14:00 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNFZSr022600
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:15:36 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Of course len is in bytes. Calling it data_len hopefully indicates
a little better what the variable is actually for.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_recv.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 28bdcdc..cd7a6cf 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -686,7 +686,7 @@ struct rds_ib_ack_state {
 };
 
 static void rds_ib_process_recv(struct rds_connection *conn,
-				struct rds_ib_recv_work *recv, u32 byte_len,
+				struct rds_ib_recv_work *recv, u32 data_len,
 				struct rds_ib_ack_state *state)
 {
 	struct rds_ib_connection *ic = conn->c_transport_data;
@@ -696,9 +696,9 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 	/* XXX shut down the connection if port 0,0 are seen? */
 
 	rdsdebug("ic %p ibinc %p recv %p byte len %u\n", ic, ibinc, recv,
-		 byte_len);
+		 data_len);
 
-	if (byte_len < sizeof(struct rds_header)) {
+	if (data_len < sizeof(struct rds_header)) {
 		rds_ib_conn_error(conn, "incoming message "
 		       "from %pI4 didn't inclue a "
 		       "header, disconnecting and "
@@ -706,9 +706,9 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 		       &conn->c_faddr);
 		return;
 	}
-	byte_len -= sizeof(struct rds_header);
+	data_len -= sizeof(struct rds_header);
 
-	ihdr = rds_ib_get_header(conn, recv, byte_len);
+	ihdr = rds_ib_get_header(conn, recv, data_len);
 
 	/* Validate the checksum. */
 	if (!rds_message_verify_checksum(ihdr)) {
@@ -728,7 +728,7 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 	if (ihdr->h_credit)
 		rds_ib_send_add_credits(conn, ihdr->h_credit);
 
-	if (ihdr->h_sport == 0 && ihdr->h_dport == 0 && byte_len == 0) {
+	if (ihdr->h_sport == 0 && ihdr->h_dport == 0 && data_len == 0) {
 		/* This is an ACK-only packet. The fact that it gets
 		 * special treatment here is that historically, ACKs
 		 * were rather special beasts.
-- 
1.6.0.4

