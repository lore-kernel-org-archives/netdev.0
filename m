From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/9] RDS: TCP: Remove dead logic around c_passive in rds-tcp
Date: Thu, 30 Jun 2016 16:11:11 -0700
Message-ID: <1a87ab5bbd78c6d7199382deca9c351eb67d0c5e.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44444 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcF3XMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:22 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC7vA007272
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:07 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The c_passive bit is only intended for the IB transport and will
never be encountered in rds-tcp, so remove the dead logic that
predicates on this bit.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index b139630..c56fff2 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -329,11 +329,8 @@ static void rds_tcp_destroy_conns(void)
 	INIT_LIST_HEAD(&rds_tcp_conn_list);
 	spin_unlock_irq(&rds_tcp_conn_lock);
 
-	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node) {
-		if (tc->conn->c_passive)
-			rds_conn_destroy(tc->conn->c_passive);
+	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node)
 		rds_conn_destroy(tc->conn);
-	}
 }
 
 static void rds_tcp_exit(void);
@@ -512,8 +509,6 @@ static void rds_tcp_kill_sock(struct net *net)
 		sk = tc->t_sock->sk;
 		sk->sk_prot->disconnect(sk, 0);
 		tcp_done(sk);
-		if (tc->conn->c_passive)
-			rds_conn_destroy(tc->conn->c_passive);
 		rds_conn_destroy(tc->conn);
 	}
 }
-- 
1.7.1
