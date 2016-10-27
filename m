From: shamir.rabinovitch@oracle.com
Subject: [PATCH RDS v1] rds: debug messages are enabled by default
Date: Thu, 27 Oct 2016 05:46:38 -0400
Message-ID: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: shamir.rabinovitch@oracle.com, santosh.shilimkar@oracle.com,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:48839 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933120AbcJ0PGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:06:21 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u9R9l2qT017762
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 09:47:03 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shamir rabinovitch <shamir.rabinovitch@oracle.com>

rds use Kconfig option called "RDS_DEBUG" to enable rds debug messages.
This option cause the rds Makefile to add -DDEBUG to the rds gcc command
line.

When CONFIG_DYNAMIC_DEBUG is enabled, the "DEBUG" macro is used by
include/linux/dynamic_debug.h to decide if dynamic debug prints should
be sent by default to the kernel log.

rds should not enable this macro for production builds. rds dynamic
debug work as expected follow this fix.

Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
---
 net/rds/Makefile |    2 +-
 net/rds/rds.h    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/Makefile b/net/rds/Makefile
index 0e72bec..56c7d27 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -13,5 +13,5 @@ obj-$(CONFIG_RDS_TCP) += rds_tcp.o
 rds_tcp-y :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
 			tcp_send.o tcp_stats.o
 
-ccflags-$(CONFIG_RDS_DEBUG)	:=	-DDEBUG
+ccflags-$(CONFIG_RDS_DEBUG)	:=	-DRDS_DEBUG
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 25532a4..4121e18 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -33,7 +33,7 @@
 #define KERNEL_HAS_ATOMIC64
 #endif
 
-#ifdef DEBUG
+#ifdef RDS_DEBUG
 #define rdsdebug(fmt, args...) pr_debug("%s(): " fmt, __func__ , ##args)
 #else
 /* sigh, pr_debug() causes unused variable warnings */
-- 
1.7.1
