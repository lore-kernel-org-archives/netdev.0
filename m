From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 20/32] [TIPC] Improved performance of error checking during socket creation.
Date: Thu, 22 Jun 2006 15:59:33 +0200
Message-ID: <1150984786199-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:52154 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030656AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8cefacb..a1f2210 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -169,12 +169,6 @@ static int tipc_create(struct socket *so
 	struct sock *sk;
         u32 ref;
 
-	if ((sock->type != SOCK_STREAM) && 
-	    (sock->type != SOCK_SEQPACKET) &&
-	    (sock->type != SOCK_DGRAM) &&
-	    (sock->type != SOCK_RDM))
-		return -EPROTOTYPE;
-
 	if (unlikely(protocol != 0))
 		return -EPROTONOSUPPORT;
 
@@ -199,6 +193,9 @@ static int tipc_create(struct socket *so
 		sock->ops = &msg_ops;
 		sock->state = SS_READY;
 		break;
+	default:
+		tipc_deleteport(ref);
+		return -EPROTOTYPE;
 	}
 
 	sk = sk_alloc(AF_TIPC, GFP_KERNEL, &tipc_proto, 1);
-- 
1.4.0

