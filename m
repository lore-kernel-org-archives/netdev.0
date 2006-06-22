From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 18/32] [TIPC] Connected send now checks socket state when retrying congested send.
Date: Thu, 22 Jun 2006 15:59:31 +0200
Message-ID: <11509847861814-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:50106 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030654AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 361dc34..9c834fc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -565,15 +565,15 @@ static int send_packet(struct kiocb *ioc
 		return -ERESTARTSYS;
         }
 
-        if (unlikely(sock->state != SS_CONNECTED)) {
-                if (sock->state == SS_DISCONNECTING)
-                        res = -EPIPE;   
-                else
-                        res = -ENOTCONN;
-                goto exit;
-        }
-
         do {
+		if (unlikely(sock->state != SS_CONNECTED)) {
+			if (sock->state == SS_DISCONNECTING)
+				res = -EPIPE;   
+			else
+				res = -ENOTCONN;
+			goto exit;
+		}
+
                 res = tipc_send(tsock->p->ref, m->msg_iovlen, m->msg_iov);
                 if (likely(res != -ELINKCONG)) {
 exit:
-- 
1.4.0

