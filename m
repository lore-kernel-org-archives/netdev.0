From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] RDS: TCP: start multipath acceptor loop at 0
Date: Fri,  4 Nov 2016 10:04:12 -0700
Message-ID: <cb3d1ade3b57826eece20b0efae40d324332244b.1478276221.git.sowmini.varadhan@oracle.com>
References: <cover.1478276221.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
        sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46129 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936456AbcKDREX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:04:23 -0400
In-Reply-To: <cover.1478276221.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1478276221.git.sowmini.varadhan@oracle.com>
References: <cover.1478276221.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The for() loop in rds_tcp_accept_one() assumes that the 0'th
rds_tcp_conn_path is UP and starts multipath accepts at index 1.
But this assumption may not always be true: if the 0'th path
has failed (ERROR or DOWN state) an incoming connection request
should be used to resurrect this path.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/tcp_listen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index e0b23fb..c9c4968 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -103,7 +103,7 @@ struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 	if (!peer_is_smaller)
 		return NULL;
 
-	for (i = 1; i < npaths; i++) {
+	for (i = 0; i < npaths; i++) {
 		struct rds_conn_path *cp = &conn->c_path[i];
 
 		if (rds_conn_path_transition(cp, RDS_CONN_DOWN,
-- 
1.7.1
