From: David Ahern <david.ahern@oracle.com>
Subject: [PATCH] net/rds: Fix new sparse warning
Date: Mon,  4 May 2015 11:51:38 -0400
Message-ID: <1430754698-247482-1-git-send-email-david.ahern@oracle.com>
Cc: David Ahern <david.ahern@oracle.com>,
	shamir rabinovitch <shamir.rabinovitch@oracle.com>
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48915 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbEDPvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:51:47 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t44FplcS011234
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 4 May 2015 15:51:47 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

c0adf54a109 introduced new sparse warnings:
  CHECK   /home/dahern/kernels/linux.git/net/rds/ib_cm.c
net/rds/ib_cm.c:191:34: warning: incorrect type in initializer (different base types)
net/rds/ib_cm.c:191:34:    expected unsigned long long [unsigned] [usertype] dp_ack_seq
net/rds/ib_cm.c:191:34:    got restricted __be64 <noident>
net/rds/ib_cm.c:194:51: warning: cast to restricted __be64

The temporary variable for sequence number should have been declared as __be64
rather than u64. Make it so.

Signed-off-by: David Ahern <david.ahern@oracle.com>
Cc: shamir rabinovitch <shamir.rabinovitch@oracle.com>
---
 net/rds/ib_cm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 29144a6..8a09ee7 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -188,7 +188,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 		 * Since dp_ack_seq is 64-bit extended load operations can be
 		 * used so go through get_unaligned to avoid unaligned errors.
 		 */
-		u64 dp_ack_seq = get_unaligned(&dp->dp_ack_seq);
+		__be64 dp_ack_seq = get_unaligned(&dp->dp_ack_seq);
 
 		if (dp_ack_seq)
 			rds_send_drop_acked(conn, be64_to_cpu(dp_ack_seq),
-- 
1.7.1
