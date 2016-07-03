From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] RDS: fix rds_tcp_init() error path
Date: Sun,  3 Jul 2016 10:54:54 +0200
Message-ID: <1467536094-23722-1-git-send-email-vegard.nossum@oracle.com>
Cc: sowmini.varadhan@oracle.com, rds-devel@oss.oracle.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: santosh.shilimkar@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40140 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbcGCIzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 04:55:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If register_pernet_subsys() fails, we shouldn't try to call
unregister_pernet_subsys().

Fixes: 467fa15356 ("RDS-TCP: Support multiple RDS-TCP listen endpoints, one per netns.")
Cc: stable@vger.kernel.org
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/rds/tcp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 74ee126..c8a7b4c 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -616,7 +616,7 @@ static int rds_tcp_init(void)
 
 	ret = rds_tcp_recv_init();
 	if (ret)
-		goto out_slab;
+		goto out_pernet;
 
 	ret = rds_trans_register(&rds_tcp_transport);
 	if (ret)
@@ -628,8 +628,9 @@ static int rds_tcp_init(void)
 
 out_recv:
 	rds_tcp_recv_exit();
-out_slab:
+out_pernet:
 	unregister_pernet_subsys(&rds_tcp_net_ops);
+out_slab:
 	kmem_cache_destroy(rds_tcp_conn_slab);
 out:
 	return ret;
-- 
1.9.1
