From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netdev_alloc_pcpu_stats: use less common iterator variable
Date: Thu, 23 Apr 2015 12:06:30 +0200
Message-ID: <1429783590-31158-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33146 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbbDWKGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 06:06:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

With the CPU iteration variable called 'i', it's relatively easy
to have variable shadowing which sparse will warn about. Avoid
that by renaming the variable to __cpu which is less likely to
be used in the surrounding context.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/netdevice.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bcbde799ec69..6719041d8851 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2021,10 +2021,10 @@ struct pcpu_sw_netstats {
 ({								\
 	typeof(type) __percpu *pcpu_stats = alloc_percpu(type); \
 	if (pcpu_stats)	{					\
-		int i;						\
-		for_each_possible_cpu(i) {			\
+		int __cpu;					\
+		for_each_possible_cpu(__cpu) {			\
 			typeof(type) *stat;			\
-			stat = per_cpu_ptr(pcpu_stats, i);	\
+			stat = per_cpu_ptr(pcpu_stats, __cpu);	\
 			u64_stats_init(&stat->syncp);		\
 		}						\
 	}							\
-- 
2.1.4
