From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/23] tipc: Enable use by containers having their own network namespace
Date: Tue, 27 Dec 2011 12:39:20 -0500
Message-ID: <1325007582-31610-2-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39357 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab1L0Rjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:53 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Permits a Linux container to use TIPC sockets even when it has its own
network namespace defined by removing the check that prohibits such use.
This makes it possible for users who wish to isolate their container
network traffic from normal network traffic to utilize TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 42b8324..e2f7c5d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -185,9 +185,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 
 	/* Validate arguments */
 
-	if (!net_eq(net, &init_net))
-		return -EAFNOSUPPORT;
-
 	if (unlikely(protocol != 0))
 		return -EPROTONOSUPPORT;
 
-- 
1.7.4.4
