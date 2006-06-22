From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 16/32] [TIPC] Implied connect now saves dest name for retrieval as ancillary data.
Date: Thu, 22 Jun 2006 15:59:29 +0200
Message-ID: <11509847862549-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:47290 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030640AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 758b2d2..98550b9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -470,6 +470,10 @@ static int send_msg(struct kiocb *iocb, 
 		if ((tsock->p->published) ||
 		    ((sock->type == SOCK_STREAM) && (total_len != 0)))
 			return -EOPNOTSUPP;
+		if (dest->addrtype == TIPC_ADDR_NAME) {
+			tsock->p->conn_type = dest->addr.name.name.type;
+			tsock->p->conn_instance = dest->addr.name.name.instance;
+		}
 	}
 
 	if (down_interruptible(&tsock->sem))
@@ -1269,10 +1273,6 @@ static int connect(struct socket *sock, 
 	   msg = buf_msg(buf);
            res = auto_connect(sock, tsock, msg);
            if (!res) {
-		   if (dst->addrtype == TIPC_ADDR_NAME) {
-			   tsock->p->conn_type = dst->addr.name.name.type;
-			   tsock->p->conn_instance = dst->addr.name.name.instance;
-		   }
 		   if (!msg_data_sz(msg))
 			   advance_queue(tsock);
 	   }
-- 
1.4.0

