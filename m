From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] tipc: validate length of sockaddr in connect() for dgram/rdm
Date: Mon, 23 Mar 2015 15:30:00 -0400
Message-ID: <1427139003-30510-1-git-send-email-sasha.levin@oracle.com>
Cc: erik.hugne@ericsson.com, ying.xue@windriver.com,
	jon.maloy@ericsson.com, davem@davemloft.net,
	Sasha Levin <sasha.levin@oracle.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	netdev@vger.kernel.org (open list:TIPC NETWORK LAYER),
	tipc-discussion@lists.sourceforge.net (open list:TIPC NETWORK LAYER)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
hasn't validated user input length for the sockaddr structure which allows
a user to overwrite kernel memory with arbitrary input.

Fixes: f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/tipc/socket.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 73c2f51..986dc96 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1852,6 +1852,8 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		if (dst->family == AF_UNSPEC) {
 			memset(&tsk->remote, 0, sizeof(struct sockaddr_tipc));
 			tsk->connected = 0;
+		} else if (destlen != sizeof(struct sockaddr_tipc)) {
+			res = -EINVAL;
 		} else {
 			memcpy(&tsk->remote, dest, destlen);
 			tsk->connected = 1;
-- 
1.7.10.4
