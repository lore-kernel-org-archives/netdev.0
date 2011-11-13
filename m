From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 5/8 2.6.32] tipc: use limited socket backlog
Date: Sun, 13 Nov 2011 23:18:49 +0300
Message-ID: <20111113201849.GF1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:39736 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab1KMUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:19:08 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This applied without changes to the original patch.

>From 53eecb1be5ae499d399d2923933937a9ea1a284f Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:45 +0000
Subject: [PATCH] tipc: use limited socket backlog

Make tipc adapt to the limited socket backlog change.

Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/tipc/socket.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1ea64f0..22bfbc3 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1322,8 +1322,10 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		sk_add_backlog(sk, buf);
-		res = TIPC_OK;
+		if (sk_add_backlog_limited(sk, buf))
+			res = TIPC_ERR_OVERLOAD;
+		else
+			res = TIPC_OK;
 	}
 	bh_unlock_sock(sk);
 
-- 
1.7.8.rc0.dirty
