From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/3] tipc/node: Fix socket fd check in cmd_node_get_addr()
Date: Thu, 17 Aug 2017 19:09:32 +0200
Message-ID: <20170817170932.24812-4-phil@nwl.cc>
References: <20170817170932.24812-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52057 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdHQRMB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:01 -0400
In-Reply-To: <20170817170932.24812-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket() returns -1 on error, not 0.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tipc/node.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tipc/node.c b/tipc/node.c
index 201fe1a4df3bd..fe085aec9b4ac 100644
--- a/tipc/node.c
+++ b/tipc/node.c
@@ -109,7 +109,8 @@ static int cmd_node_get_addr(struct nlmsghdr *nlh, const struct cmd *cmd,
 	socklen_t sz = sizeof(struct sockaddr_tipc);
 	struct sockaddr_tipc addr;
 
-	if (!(sk = socket(AF_TIPC, SOCK_RDM, 0))) {
+	sk = socket(AF_TIPC, SOCK_RDM, 0);
+	if (sk < 0) {
 		fprintf(stderr, "opening TIPC socket: %s\n", strerror(errno));
 		return -1;
 	}
-- 
2.13.1
