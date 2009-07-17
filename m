From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 10/15] RDS/IB: Drop connection when a fatal QP event is received
Date: Fri, 17 Jul 2009 16:13:31 -0700
Message-ID: <1247872416-17834-11-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:40702 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbZGRApD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 20:45:03 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6I0iZrO029442
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 00:44:36 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_cm.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0ad749c..c2d372f 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -203,9 +203,9 @@ static void rds_ib_qp_event_handler(struct ib_event *event, void *data)
 		rdma_notify(ic->i_cm_id, IB_EVENT_COMM_EST);
 		break;
 	default:
-		printk(KERN_WARNING "RDS/ib: unhandled QP event %u "
-		       "on connection to %pI4\n", event->event,
-		       &conn->c_faddr);
+		rds_ib_conn_error(conn, "RDS/IB: Fatal QP Event %u "
+			"- connection %pI4->%pI4, reconnecting\n",
+			event->event, &conn->c_laddr, &conn->c_faddr);
 		break;
 	}
 }
-- 
1.6.0.4

