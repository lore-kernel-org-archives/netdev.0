From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 2/9] RDS/IW+IB: Set recv ring low water mark to 1/2 full.
Date: Mon, 30 Mar 2009 11:44:46 -0700
Message-ID: <1238438693-29540-3-git-send-email-andy.grover@oracle.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Steve Wise <swise@opengridcomputing.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:28031 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758975AbZC3SpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:45:09 -0400
In-Reply-To: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Currently the recv ring low water mark is 1/4 the depth.  Performance
measurements show that this limits iWARP throughput by flow controlling
the rds-stress senders.  Setting it to 1/2 seems to max the T3
performance.  I tried even higher levels but that didn't help and it
started to increase the rds thread cpu utilization.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_ring.c |    2 +-
 net/rds/iw_ring.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_ring.c b/net/rds/ib_ring.c
index 99a6cca..ff97e8e 100644
--- a/net/rds/ib_ring.c
+++ b/net/rds/ib_ring.c
@@ -137,7 +137,7 @@ int rds_ib_ring_empty(struct rds_ib_work_ring *ring)
 
 int rds_ib_ring_low(struct rds_ib_work_ring *ring)
 {
-	return __rds_ib_ring_used(ring) <= (ring->w_nr >> 2);
+	return __rds_ib_ring_used(ring) <= (ring->w_nr >> 1);
 }
 
 /*
diff --git a/net/rds/iw_ring.c b/net/rds/iw_ring.c
index d422d4b..da8e3b6 100644
--- a/net/rds/iw_ring.c
+++ b/net/rds/iw_ring.c
@@ -137,7 +137,7 @@ int rds_iw_ring_empty(struct rds_iw_work_ring *ring)
 
 int rds_iw_ring_low(struct rds_iw_work_ring *ring)
 {
-	return __rds_iw_ring_used(ring) <= (ring->w_nr >> 2);
+	return __rds_iw_ring_used(ring) <= (ring->w_nr >> 1);
 }
 
 
-- 
1.5.6.3

