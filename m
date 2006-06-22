From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 22/32] [TIPC] Simplify code for returning partial success of stream send request.
Date: Thu, 22 Jun 2006 15:59:35 +0200
Message-ID: <11509847872289-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:53690 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030659AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index abecf2d..6d4d2b0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -969,7 +969,7 @@ static int recv_stream(struct kiocb *ioc
 restart:
 	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
 		     (flags & MSG_DONTWAIT))) {
-		res = (sz_copied == 0) ? -EWOULDBLOCK : 0;
+		res = -EWOULDBLOCK;
 		goto exit;
 	}
 
@@ -1060,7 +1060,7 @@ restart:
 
 exit:
 	up(&tsock->sem);
-	return res ? res : sz_copied;
+	return sz_copied ? sz_copied : res;
 }
 
 /**
-- 
1.4.0

