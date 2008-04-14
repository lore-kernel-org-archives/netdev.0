From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/7 net-2.6.26] [TIPC]: Add error check to detect non-blocking form of connect()
Date: Mon, 14 Apr 2008 17:16:32 -0400
Message-ID: <1208207794-2229-6-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55787 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762645AbYDNVS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:26 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch causes TIPC to return an error indication if the non-
blocking form of connect() is requested (which TIPC does not yet
support).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4c83aba..348e4ff 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1260,6 +1260,11 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
    if (sock->state == SS_READY)
 	   return -EOPNOTSUPP;
 
+   /* For now, TIPC does not support the non-blocking form of connect() */
+
+   if (flags & O_NONBLOCK)
+	   return -EWOULDBLOCK;
+
    /* Issue Posix-compliant error code if socket is in the wrong state */
 
    if (sock->state == SS_LISTENING)
-- 
1.5.3.2

