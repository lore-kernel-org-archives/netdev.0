From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 21/32] [TIPC] recvmsg() now returns TIPC ancillary data using correct level (SOL_TIPC)
Date: Thu, 22 Jun 2006 15:59:34 +0200
Message-ID: <11509847874095-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:53178 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030655AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index a1f2210..abecf2d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -744,10 +744,10 @@ static int anc_data_recv(struct msghdr *
 	if (unlikely(err)) {
 		anc_data[0] = err;
 		anc_data[1] = msg_data_sz(msg);
-		if ((res = put_cmsg(m, SOL_SOCKET, TIPC_ERRINFO, 8, anc_data)))
+		if ((res = put_cmsg(m, SOL_TIPC, TIPC_ERRINFO, 8, anc_data)))
 			return res;
 		if (anc_data[1] &&
-		    (res = put_cmsg(m, SOL_SOCKET, TIPC_RETDATA, anc_data[1], 
+		    (res = put_cmsg(m, SOL_TIPC, TIPC_RETDATA, anc_data[1], 
 				    msg_data(msg))))
 			return res;
 	}
@@ -778,7 +778,7 @@ static int anc_data_recv(struct msghdr *
 		has_name = 0;
 	}
 	if (has_name &&
-	    (res = put_cmsg(m, SOL_SOCKET, TIPC_DESTNAME, 12, anc_data)))
+	    (res = put_cmsg(m, SOL_TIPC, TIPC_DESTNAME, 12, anc_data)))
 		return res;
 
 	return 0;
-- 
1.4.0

