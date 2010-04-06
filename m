From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] socket: remove duplicate declaration of struct timespec
Date: Tue,  6 Apr 2010 17:39:52 +0200
Message-ID: <1270568392-22030-1-git-send-email-hagen@jauu.net>
Cc: davem@davemloft.net, Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42268 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750976Ab0DFPkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:40:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct timespec ts was alreay defined. Reuse the previously
defined one and reduce the memory footprint on the stack by
16 bytes.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/socket.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 769c386..ae904b5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -619,10 +619,9 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
 				 sizeof(tv), &tv);
 		} else {
-			struct timespec ts;
-			skb_get_timestampns(skb, &ts);
+			skb_get_timestampns(skb, &ts[0]);
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
-				 sizeof(ts), &ts);
+				 sizeof(ts[0]), &ts[0]);
 		}
 	}
 
-- 
1.6.6.196.g1f735.dirty

