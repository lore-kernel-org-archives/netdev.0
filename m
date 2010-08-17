From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/14] tipc: Provide correct error code for unsupported connect() operation
Date: Tue, 17 Aug 2010 17:00:05 -0400
Message-ID: <1282078816-11844-4-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57118 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab0HQVAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:23 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modify TIPC to return EOPNOTSUPP if an application attempts to perform
 a non-blocking connect() operation, which is not supported by TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 69d0fd1..b89c7b1 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1380,7 +1380,7 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	/* For now, TIPC does not support the non-blocking form of connect() */
 
 	if (flags & O_NONBLOCK) {
-		res = -EWOULDBLOCK;
+		res = -EOPNOTSUPP;
 		goto exit;
 	}
 
-- 
1.7.2.1

