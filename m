From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 1/3] net/rds: Declare SO_RDS_TRANSPORT and RDS_TRANS_* constants in uapi/linux/rds.h
Date: Fri, 29 May 2015 17:28:07 -0400
Message-ID: <d887debce71050cba3e982ff6cbfd797fad651c8.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

User space applications that desire to explicitly select the
underlying transport for a PF_RDS socket may do so by using the
SO_RDS_TRANSPORT socket option at the SOL_RDS level before bind().
The integer argument provided to the socket option would be one
of the RDS_TRANS_* values, e.g., RDS_TRANS_TCP. This commit exports
the constant values need by such applications via <linux/rds.h>

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/uapi/linux/rds.h |   10 ++++++++++
 net/rds/rds.h            |    5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 9195095..0f9265c 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -38,6 +38,8 @@
 
 #define RDS_IB_ABI_VERSION		0x301
 
+#define	SOL_RDS		276
+
 /*
  * setsockopt/getsockopt for SOL_RDS
  */
@@ -48,6 +50,14 @@
 #define RDS_RECVERR			5
 #define RDS_CONG_MONITOR		6
 #define RDS_GET_MR_FOR_DEST		7
+#define SO_RDS_TRANSPORT		8
+
+/* supported values for SO_RDS_TRANSPORT */
+#define	RDS_TRANS_IB	0
+#define	RDS_TRANS_IWARP	1
+#define	RDS_TRANS_TCP	2
+#define RDS_TRANS_COUNT	3
+#define	RDS_TRANS_NONE	(~0)
 
 /*
  * Control message types for SOL_RDS.
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 0d41155..76db508 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -408,11 +408,6 @@ struct rds_notifier {
  *                 should try hard not to block.
  */
 
-#define RDS_TRANS_IB	0
-#define RDS_TRANS_IWARP	1
-#define RDS_TRANS_TCP	2
-#define RDS_TRANS_COUNT	3
-
 struct rds_transport {
 	char			t_name[TRANSNAMSIZ];
 	struct list_head	t_item;
-- 
1.7.1
