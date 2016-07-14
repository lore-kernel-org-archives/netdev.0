From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 4/5] Documentation: RDS: updates for SO_RDS_TRANSPORT socket option
Date: Thu, 14 Jul 2016 03:51:04 -0700
Message-ID: <f42978390a79616d749ca39af173ca369cc2c147.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42535 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbcGNKv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:27 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the documentation to describe the changes added by
commit 8ba38460f363 ("net/rds Add getsockopt support for SO_RDS_TRANSPORT")

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 Documentation/networking/rds.txt |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/rds.txt b/Documentation/networking/rds.txt
index 9d219d8..1366e11 100644
--- a/Documentation/networking/rds.txt
+++ b/Documentation/networking/rds.txt
@@ -85,7 +85,8 @@ Socket Interface
 
   bind(fd, &sockaddr_in, ...)
         This binds the socket to a local IP address and port, and a
-        transport.
+        transport, if one has not already been selected via the
+	SO_RDS_TRANSPORT socket option
 
   sendmsg(fd, ...)
         Sends a message to the indicated recipient. The kernel will
@@ -146,6 +147,20 @@ Socket Interface
         operation. In this case, it would use RDS_CANCEL_SENT_TO to
         nuke any pending messages.
 
+  setsockopt(fd, SOL_RDS, SO_RDS_TRANSPORT, (int *)&transport ..)
+  getsockopt(fd, SOL_RDS, SO_RDS_TRANSPORT, (int *)&transport ..)
+	Set or read an integer defining  the underlying
+	encapsulating transport to be used for RDS packets on the
+	socket. When setting the option, integer argument may be
+	one of RDS_TRANS_TCP or RDS_TRANS_IB. When retrieving the
+	value, RDS_TRANS_NONE will be returned on an unbound socket.
+	This socket option may only be set exactly once on the socket,
+	prior to binding it via the bind(2) system call. Attempts to
+	set SO_RDS_TRANSPORT on a socket for which the transport has
+	been previously attached explicitly (by SO_RDS_TRANSPORT) or
+	implicitly (via bind(2)) will return an error of EOPNOTSUPP.
+	An attempt to set SO_RDS_TRANSPPORT to RDS_TRANS_NONE will
+	always return EINVAL.
 
 RDMA for RDS
 ============
-- 
1.7.1
