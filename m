From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 07 Dec 2012 06:58:54 -0800
Message-ID: <1354892334.29937.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49808 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756229Ab2LGO6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 09:58:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given that the struct will always have limit at the start of
a cacheline, why not make  struct ___cacheline_aligned_on_smp
and make limit the first member?

It could make other structs that use struct dql a bit more
predictable or efficient to pack.

(netdev_queue is size reduced from 256 to 192 on x86-32)

---

 include/linux/dynamic_queue_limits.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
index 5621547..2d20b22 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -38,6 +38,8 @@
 #ifdef __KERNEL__
 
 struct dql {
+	unsigned int	limit; /* Must be first field - Current limit */
+
 	/* Fields accessed in enqueue path (dql_queued) */
 	unsigned int	num_queued;		/* Total ever queued */
 	unsigned int	adj_limit;		/* limit + num_completed */
@@ -45,7 +47,6 @@ struct dql {
 
 	/* Fields accessed only by completion path (dql_completed) */
 
-	unsigned int	limit ____cacheline_aligned_in_smp; /* Current limit */
 	unsigned int	num_completed;		/* Total ever completed */
 
 	unsigned int	prev_ovlimit;		/* Previous over limit */
@@ -59,7 +60,7 @@ struct dql {
 	unsigned int	max_limit;		/* Max limit */
 	unsigned int	min_limit;		/* Minimum limit */
 	unsigned int	slack_hold_time;	/* Time to measure slack */
-};
+} ____cacheline_aligned_in_smp;
 
 /* Set some static maximums */
 #define DQL_MAX_OBJECT (UINT_MAX / 16)
