From: kaber@trash.net
Subject: [PATCH 28/37] IPVS: Conditionally include sysctl members of struct netns_ipvs
Date: Tue, 15 Mar 2011 20:44:08 +0100
Message-ID: <1300218257-26953-29-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49442 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758506Ab1COTod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:33 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

There is now no need to include sysctl members of struct netns_ipvs
unless CONFIG_SYSCTL is defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 299aeb5..272f593 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -839,6 +839,17 @@ struct netns_ipvs {
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
 
 	int			num_services;    /* no of virtual services */
+
+	rwlock_t		rs_lock;         /* real services table */
+	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
+	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
+	/* Trash for destinations */
+	struct list_head	dest_trash;
+	/* Service counters */
+	atomic_t		ftpsvc_counter;
+	atomic_t		nullsvc_counter;
+
+#ifdef CONFIG_SYSCTL
 	/* 1/rate drop and drop-entry variables */
 	struct delayed_work	defense_work;   /* Work handler */
 	int			drop_rate;
@@ -848,18 +859,12 @@ struct netns_ipvs {
 	spinlock_t		dropentry_lock;  /* drop entry handling */
 	spinlock_t		droppacket_lock; /* drop packet handling */
 	spinlock_t		securetcp_lock;  /* state and timeout tables */
-	rwlock_t		rs_lock;         /* real services table */
-	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
-	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
-	/* Trash for destinations */
-	struct list_head	dest_trash;
-	/* Service counters */
-	atomic_t		ftpsvc_counter;
-	atomic_t		nullsvc_counter;
 
 	/* sys-ctl struct */
 	struct ctl_table_header	*sysctl_hdr;
 	struct ctl_table	*sysctl_tbl;
+#endif
+
 	/* sysctl variables */
 	int			sysctl_amemthresh;
 	int			sysctl_am_droprate;
-- 
1.7.2.3

