From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] rds: tcp: canonical connection order for all paths with index > 0
Date: Fri, 31 Mar 2017 15:56:31 -0700
Message-ID: <dd4baab053150f26c6fff124c4f4c9b417a9eb80.1490814967.git.sowmini.varadhan@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, santosh.shilimkar@oracle.com,
        sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26590 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751889AbdDASSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:18:42 -0400
In-Reply-To: <cover.1490814967.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1490814967.git.sowmini.varadhan@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rds_connect_worker() has a bug in the check that enforces the
canonical connection order described in the comments of
rds_tcp_state_change(). The intention is to make sure that all
the multipath connections are always initiated by the smaller IP
address via rds_start_mprds. To achieve this, rds_connection_worker
should check that cp_index > 0.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/threads.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/threads.c b/net/rds/threads.c
index e36e333..3e447d0 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -156,7 +156,7 @@ void rds_connect_worker(struct work_struct *work)
 	struct rds_connection *conn = cp->cp_conn;
 	int ret;
 
-	if (cp->cp_index > 1 && cp->cp_conn->c_laddr > cp->cp_conn->c_faddr)
+	if (cp->cp_index > 0 && cp->cp_conn->c_laddr > cp->cp_conn->c_faddr)
 		return;
 	clear_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
 	ret = rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
-- 
1.7.1
