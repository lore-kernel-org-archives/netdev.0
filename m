From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net] RDS: TCP: rds_tcp_accept_one() should transition socket
 from RESETTING to UP
Date: Fri, 17 Jun 2016 16:12:12 -0400
Message-ID: <20160617201212.GC29044@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, davem@davemloft.net,
	santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21675 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933478AbcFQUMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 16:12:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The state of the rds_connection after rds_tcp_reset_callbacks() would
be RDS_CONN_RESETTING and this is the value that should be passed
by rds_tcp_accept_one()  to rds_connect_path_complete() to transition
the socket to RDS_CONN_UP.

Fixes: b5c21c0947c1 ("RDS: TCP: fix race windows in send-path quiescence
by rds_tcp_accept_one()")
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_listen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 686b1d0..245542c 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -138,7 +138,7 @@ int rds_tcp_accept_one(struct socket *sock)
 			rds_tcp_reset_callbacks(new_sock, conn);
 			conn->c_outgoing = 0;
 			/* rds_connect_path_complete() marks RDS_CONN_UP */
-			rds_connect_path_complete(conn, RDS_CONN_DISCONNECTING);
+			rds_connect_path_complete(conn, RDS_CONN_RESETTING);
 		}
 	} else {
 		rds_tcp_set_callbacks(new_sock, conn);
-- 
1.7.1
