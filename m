From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 09/15] RDS/IB: Disable flow control in sysctl and explain why
Date: Fri, 17 Jul 2009 16:13:30 -0700
Message-ID: <1247872416-17834-10-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30173 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758061AbZGQXox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:53 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNiRK2030308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:44:28 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Backwards compatibility with rds 3.0 causes protocol-
based flow control to be disabled as a side-effect.

I don't want to pull out FC support from the IB transport
but I do want to document and keep the sysctl consistent
if possible.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_sysctl.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index d87830d..84b5ffc 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -53,7 +53,17 @@ unsigned long rds_ib_sysctl_max_unsig_bytes = (16 << 20);
 static unsigned long rds_ib_sysctl_max_unsig_bytes_min = 1;
 static unsigned long rds_ib_sysctl_max_unsig_bytes_max = ~0UL;
 
-unsigned int rds_ib_sysctl_flow_control = 1;
+/*
+ * This sysctl does nothing.
+ *
+ * Backwards compatibility with RDS 3.0 wire protocol
+ * disables initial FC credit exchange.
+ * If it's ever possible to drop 3.0 support,
+ * setting this to 1 and moving init/refill of send/recv
+ * rings from ib_cm_connect_complete() back into ib_setup_qp()
+ * will cause credits to be added before protocol negotiation.
+ */
+unsigned int rds_ib_sysctl_flow_control = 0;
 
 ctl_table rds_ib_sysctl_table[] = {
 	{
-- 
1.6.0.4

