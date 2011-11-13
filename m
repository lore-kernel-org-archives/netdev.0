From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 7/8 2.6.32] llc: use limited socket backlog
Date: Sun, 13 Nov 2011 23:19:35 +0300
Message-ID: <20111113201935.GH1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:28018 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab1KMUTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:19:54 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This applied without changes to the original patch.

>From 79545b681961d7001c1f4c3eb9ffb87bed4485db Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:43 +0000
Subject: [PATCH] llc: use limited socket backlog

Make llc adapt to the limited socket backlog change.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/llc/llc_conn.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index a8dde9b..c0539ff 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -827,7 +827,8 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		sk_add_backlog(sk, skb);
+		if (sk_add_backlog_limited(sk, skb))
+			goto drop_unlock;
 	}
 out:
 	bh_unlock_sock(sk);
-- 
1.7.8.rc0.dirty
