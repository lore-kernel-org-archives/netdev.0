From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 15/32] [TIPC] Fixed connect() to detect a dest address that is missing or too short.
Date: Thu, 22 Jun 2006 15:59:28 +0200
Message-ID: <11509847862119-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:35990 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030650AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0923213..758b2d2 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1244,7 +1244,7 @@ static int connect(struct socket *sock, 
    if (sock->state != SS_UNCONNECTED)
            return -EISCONN;
 
-   if ((dst->family != AF_TIPC) ||
+   if ((destlen < sizeof(*dst)) || (dst->family != AF_TIPC) ||
        ((dst->addrtype != TIPC_ADDR_NAME) && (dst->addrtype != TIPC_ADDR_ID)))
            return -EINVAL;
 
-- 
1.4.0

