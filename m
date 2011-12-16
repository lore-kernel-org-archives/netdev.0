From: igorm@etf.rs
Subject: [PATCH 03/10 net-next] include:linux:inetdevice: Add struct ipv4_devstat and func __in_dev_get_rcu_safely
Date: Fri, 16 Dec 2011 16:25:56 +0100
Message-ID: <1324049163-11207-4-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53859 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755826Ab1LPP0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:16 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Added struct ipv4_devstat for holding per device ipv4 stats.

Added function __in_dev_get_rcu_safely.
Did that so I would have cleaner code in IP_*_STATS and ICMP_*_STATS macros.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/linux/inetdevice.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 5f81466..a4bffa7 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -49,6 +49,13 @@ struct ipv4_devconf {
 	DECLARE_BITMAP(state, IPV4_DEVCONF_MAX);
 };
 
+struct ipv4_devstat {
+	struct proc_dir_entry   *proc_dir_entry;
+	DEFINE_SNMP_STAT(struct ipstats_mib, ip);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmp_mib_dev, icmpdev);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmpmsg_mib_dev, icmpmsgdev);
+};
+
 struct in_device {
 	struct net_device	*dev;
 	atomic_t		refcnt;
@@ -69,6 +76,7 @@ struct in_device {
 
 	struct neigh_parms	*arp_parms;
 	struct ipv4_devconf	cnf;
+	struct ipv4_devstat	stats;
 	struct rcu_head		rcu_head;
 };
 
@@ -209,6 +217,14 @@ static inline struct in_device *__in_dev_get_rcu(const struct net_device *dev)
 	return rcu_dereference(dev->ip_ptr);
 }
 
+static inline struct in_device *__in_dev_get_rcu_safely(const struct net_device *dev)
+{
+	if (likely(dev))
+		return rcu_dereference(dev->ip_ptr);
+	else
+		return NULL;
+}
+
 static inline struct in_device *in_dev_get(const struct net_device *dev)
 {
 	struct in_device *in_dev;
-- 
1.7.5.4
