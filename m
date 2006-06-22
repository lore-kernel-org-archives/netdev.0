From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 17/32] [TIPC] Can now return destination name of form {0,x,y} via ancillary data.
Date: Thu, 22 Jun 2006 15:59:30 +0200
Message-ID: <11509847861968-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:48314 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030646AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 98550b9..361dc34 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -731,6 +731,7 @@ static int anc_data_recv(struct msghdr *
 	u32 anc_data[3];
 	u32 err;
 	u32 dest_type;
+	int has_name;
 	int res;
 
 	if (likely(m->msg_controllen == 0))
@@ -755,24 +756,27 @@ static int anc_data_recv(struct msghdr *
 	dest_type = msg ? msg_type(msg) : TIPC_DIRECT_MSG;
 	switch (dest_type) {
 	case TIPC_NAMED_MSG:
+		has_name = 1;
 		anc_data[0] = msg_nametype(msg);
 		anc_data[1] = msg_namelower(msg);
 		anc_data[2] = msg_namelower(msg);
 		break;
 	case TIPC_MCAST_MSG:
+		has_name = 1;
 		anc_data[0] = msg_nametype(msg);
 		anc_data[1] = msg_namelower(msg);
 		anc_data[2] = msg_nameupper(msg);
 		break;
 	case TIPC_CONN_MSG:
+		has_name = (tport->conn_type != 0);
 		anc_data[0] = tport->conn_type;
 		anc_data[1] = tport->conn_instance;
 		anc_data[2] = tport->conn_instance;
 		break;
 	default:
-		anc_data[0] = 0;
+		has_name = 0;
 	}
-	if (anc_data[0] &&
+	if (has_name &&
 	    (res = put_cmsg(m, SOL_SOCKET, TIPC_DESTNAME, 12, anc_data)))
 		return res;
 
-- 
1.4.0

