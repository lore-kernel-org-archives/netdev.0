From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 3/9] RDS: Correct some iw references in rdma_transport.c
Date: Mon, 30 Mar 2009 11:44:47 -0700
Message-ID: <1238438693-29540-4-git-send-email-andy.grover@oracle.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41887 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696AbZC3SpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:45:13 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2UImI3k014029
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 18:48:19 GMT
In-Reply-To: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Had some lingering instances of _iw_ variable names from when
the listen code was centralized into rdma_transport.c

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma_transport.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 7b19024..7d0f901 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -34,7 +34,7 @@
 
 #include "rdma_transport.h"
 
-static struct rdma_cm_id *rds_iw_listen_id;
+static struct rdma_cm_id *rds_rdma_listen_id;
 
 int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 			      struct rdma_cm_event *event)
@@ -161,7 +161,7 @@ static int __init rds_rdma_listen_init(void)
 
 	rdsdebug("cm %p listening on port %u\n", cm_id, RDS_PORT);
 
-	rds_iw_listen_id = cm_id;
+	rds_rdma_listen_id = cm_id;
 	cm_id = NULL;
 out:
 	if (cm_id)
@@ -171,10 +171,10 @@ out:
 
 static void rds_rdma_listen_stop(void)
 {
-	if (rds_iw_listen_id) {
-		rdsdebug("cm %p\n", rds_iw_listen_id);
-		rdma_destroy_id(rds_iw_listen_id);
-		rds_iw_listen_id = NULL;
+	if (rds_rdma_listen_id) {
+		rdsdebug("cm %p\n", rds_rdma_listen_id);
+		rdma_destroy_id(rds_rdma_listen_id);
+		rds_rdma_listen_id = NULL;
 	}
 }
 
-- 
1.5.6.3

