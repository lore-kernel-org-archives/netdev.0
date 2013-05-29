From: sean.hefty@intel.com
Subject: [PATCH v5 24/28] rdma/ucm: Name changes to indicate only IP addresses supported
Date: Wed, 29 May 2013 10:09:30 -0700
Message-ID: <1369847374-12176-25-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31900 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759714Ab3E2RKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:10:07 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Several commands into the RDMA CM from user space are
restricted to supporting addresses which fit into a sockaddr_in6
structure: bind address, resolve address, and join multicast.

With the addition of AF_IB, we need to support addresses
which are larger than sockaddr_in6.  This will be done by
adding new commands that exchange address information using
sockaddr_storage.  However, to support existing applications,
we maintain the current commands and structures, but rename
them to indicate that they only support IPv4 and v6 addresses.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/ucma.c   |   60 +++++++++++++++++++-------------------
 include/uapi/rdma/rdma_user_cm.h |   12 ++++----
 2 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 45bb052..82fb1e6 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -512,10 +512,10 @@ static ssize_t ucma_destroy_id(struct ucma_file *file, const char __user *inbuf,
 	return ret;
 }
 
-static ssize_t ucma_bind_addr(struct ucma_file *file, const char __user *inbuf,
+static ssize_t ucma_bind_ip(struct ucma_file *file, const char __user *inbuf,
 			      int in_len, int out_len)
 {
-	struct rdma_ucm_bind_addr cmd;
+	struct rdma_ucm_bind_ip cmd;
 	struct ucma_context *ctx;
 	int ret;
 
@@ -531,11 +531,11 @@ static ssize_t ucma_bind_addr(struct ucma_file *file, const char __user *inbuf,
 	return ret;
 }
 
-static ssize_t ucma_resolve_addr(struct ucma_file *file,
-				 const char __user *inbuf,
-				 int in_len, int out_len)
+static ssize_t ucma_resolve_ip(struct ucma_file *file,
+			       const char __user *inbuf,
+			       int in_len, int out_len)
 {
-	struct rdma_ucm_resolve_addr cmd;
+	struct rdma_ucm_resolve_ip cmd;
 	struct ucma_context *ctx;
 	int ret;
 
@@ -1178,11 +1178,11 @@ static ssize_t ucma_notify(struct ucma_file *file, const char __user *inbuf,
 	return ret;
 }
 
-static ssize_t ucma_join_multicast(struct ucma_file *file,
-				   const char __user *inbuf,
-				   int in_len, int out_len)
+static ssize_t ucma_join_ip_multicast(struct ucma_file *file,
+				      const char __user *inbuf,
+				      int in_len, int out_len)
 {
-	struct rdma_ucm_join_mcast cmd;
+	struct rdma_ucm_join_ip_mcast cmd;
 	struct rdma_ucm_create_id_resp resp;
 	struct ucma_context *ctx;
 	struct ucma_multicast *mc;
@@ -1379,26 +1379,26 @@ file_put:
 static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 				   const char __user *inbuf,
 				   int in_len, int out_len) = {
-	[RDMA_USER_CM_CMD_CREATE_ID]	= ucma_create_id,
-	[RDMA_USER_CM_CMD_DESTROY_ID]	= ucma_destroy_id,
-	[RDMA_USER_CM_CMD_BIND_ADDR]	= ucma_bind_addr,
-	[RDMA_USER_CM_CMD_RESOLVE_ADDR]	= ucma_resolve_addr,
-	[RDMA_USER_CM_CMD_RESOLVE_ROUTE]= ucma_resolve_route,
-	[RDMA_USER_CM_CMD_QUERY_ROUTE]	= ucma_query_route,
-	[RDMA_USER_CM_CMD_CONNECT]	= ucma_connect,
-	[RDMA_USER_CM_CMD_LISTEN]	= ucma_listen,
-	[RDMA_USER_CM_CMD_ACCEPT]	= ucma_accept,
-	[RDMA_USER_CM_CMD_REJECT]	= ucma_reject,
-	[RDMA_USER_CM_CMD_DISCONNECT]	= ucma_disconnect,
-	[RDMA_USER_CM_CMD_INIT_QP_ATTR]	= ucma_init_qp_attr,
-	[RDMA_USER_CM_CMD_GET_EVENT]	= ucma_get_event,
-	[RDMA_USER_CM_CMD_GET_OPTION]	= NULL,
-	[RDMA_USER_CM_CMD_SET_OPTION]	= ucma_set_option,
-	[RDMA_USER_CM_CMD_NOTIFY]	= ucma_notify,
-	[RDMA_USER_CM_CMD_JOIN_MCAST]	= ucma_join_multicast,
-	[RDMA_USER_CM_CMD_LEAVE_MCAST]	= ucma_leave_multicast,
-	[RDMA_USER_CM_CMD_MIGRATE_ID]	= ucma_migrate_id,
-	[RDMA_USER_CM_CMD_QUERY]	= ucma_query
+	[RDMA_USER_CM_CMD_CREATE_ID] 	 = ucma_create_id,
+	[RDMA_USER_CM_CMD_DESTROY_ID]	 = ucma_destroy_id,
+	[RDMA_USER_CM_CMD_BIND_IP]	 = ucma_bind_ip,
+	[RDMA_USER_CM_CMD_RESOLVE_IP]	 = ucma_resolve_ip,
+	[RDMA_USER_CM_CMD_RESOLVE_ROUTE] = ucma_resolve_route,
+	[RDMA_USER_CM_CMD_QUERY_ROUTE]	 = ucma_query_route,
+	[RDMA_USER_CM_CMD_CONNECT]	 = ucma_connect,
+	[RDMA_USER_CM_CMD_LISTEN]	 = ucma_listen,
+	[RDMA_USER_CM_CMD_ACCEPT]	 = ucma_accept,
+	[RDMA_USER_CM_CMD_REJECT]	 = ucma_reject,
+	[RDMA_USER_CM_CMD_DISCONNECT]	 = ucma_disconnect,
+	[RDMA_USER_CM_CMD_INIT_QP_ATTR]	 = ucma_init_qp_attr,
+	[RDMA_USER_CM_CMD_GET_EVENT]	 = ucma_get_event,
+	[RDMA_USER_CM_CMD_GET_OPTION]	 = NULL,
+	[RDMA_USER_CM_CMD_SET_OPTION]	 = ucma_set_option,
+	[RDMA_USER_CM_CMD_NOTIFY]	 = ucma_notify,
+	[RDMA_USER_CM_CMD_JOIN_IP_MCAST] = ucma_join_ip_multicast,
+	[RDMA_USER_CM_CMD_LEAVE_MCAST]	 = ucma_leave_multicast,
+	[RDMA_USER_CM_CMD_MIGRATE_ID]	 = ucma_migrate_id,
+	[RDMA_USER_CM_CMD_QUERY]	 = ucma_query
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index ea79253..79f68f7 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
@@ -45,8 +45,8 @@
 enum {
 	RDMA_USER_CM_CMD_CREATE_ID,
 	RDMA_USER_CM_CMD_DESTROY_ID,
-	RDMA_USER_CM_CMD_BIND_ADDR,
-	RDMA_USER_CM_CMD_RESOLVE_ADDR,
+	RDMA_USER_CM_CMD_BIND_IP,
+	RDMA_USER_CM_CMD_RESOLVE_IP,
 	RDMA_USER_CM_CMD_RESOLVE_ROUTE,
 	RDMA_USER_CM_CMD_QUERY_ROUTE,
 	RDMA_USER_CM_CMD_CONNECT,
@@ -59,7 +59,7 @@ enum {
 	RDMA_USER_CM_CMD_GET_OPTION,
 	RDMA_USER_CM_CMD_SET_OPTION,
 	RDMA_USER_CM_CMD_NOTIFY,
-	RDMA_USER_CM_CMD_JOIN_MCAST,
+	RDMA_USER_CM_CMD_JOIN_IP_MCAST,
 	RDMA_USER_CM_CMD_LEAVE_MCAST,
 	RDMA_USER_CM_CMD_MIGRATE_ID,
 	RDMA_USER_CM_CMD_QUERY
@@ -96,13 +96,13 @@ struct rdma_ucm_destroy_id_resp {
 	__u32 events_reported;
 };
 
-struct rdma_ucm_bind_addr {
+struct rdma_ucm_bind_ip {
 	__u64 response;
 	struct sockaddr_in6 addr;
 	__u32 id;
 };
 
-struct rdma_ucm_resolve_addr {
+struct rdma_ucm_resolve_ip {
 	struct sockaddr_in6 src_addr;
 	struct sockaddr_in6 dst_addr;
 	__u32 id;
@@ -216,7 +216,7 @@ struct rdma_ucm_notify {
 	__u32 event;
 };
 
-struct rdma_ucm_join_mcast {
+struct rdma_ucm_join_ip_mcast {
 	__u64 response;		/* rdma_ucm_create_id_resp */
 	__u64 uid;
 	struct sockaddr_in6 addr;
-- 
1.7.3
