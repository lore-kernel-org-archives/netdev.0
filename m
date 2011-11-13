From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 3/8 2.6.32] x25: use limited socket backlog
Date: Sun, 13 Nov 2011 23:18:01 +0300
Message-ID: <20111113201801.GD1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:39634 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1KMUST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:18:19 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This applied without changes to the original patch.

>From 2499849ee8f513e795b9f2c19a42d6356e4943a4 Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:46 +0000
Subject: [PATCH] x25: use limited socket backlog

Make x25 adapt to the limited socket backlog change.

Cc: Andrew Hendry <andrew.hendry@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/x25/x25_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 3e1efe5..a9da0dc 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
-			sk_add_backlog(sk, skb);
+			queued = !sk_add_backlog_limited(sk, skb);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);
-- 
1.7.8.rc0.dirty
