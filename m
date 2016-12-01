From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net] RDS: TCP: unregister_netdevice_notifier() in error path of rds_tcp_init_net
Date: Thu,  1 Dec 2016 04:44:43 -0800
Message-ID: <1480596283-204869-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27654 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754235AbcLAMoz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 07:44:55 -0500
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If some error is encountered in rds_tcp_init_net, make sure to
unregister_netdevice_notifier(), else we could trigger a panic
later on, when the modprobe from a netns fails.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index fcddacc..20e2923 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -659,6 +659,8 @@ static int rds_tcp_init(void)
 out_pernet:
 	unregister_pernet_subsys(&rds_tcp_net_ops);
 out_slab:
+	if (unregister_netdevice_notifier(&rds_tcp_dev_notifier))
+		pr_warn("could not unregister rds_tcp_dev_notifier\n");
 	kmem_cache_destroy(rds_tcp_conn_slab);
 out:
 	return ret;
-- 
1.7.1
