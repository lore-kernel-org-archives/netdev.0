From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 net-next 1/6] bridge: Turn flag change macro into a function.
Date: Fri, 16 May 2014 09:59:15 -0400
Message-ID: <1400248760-20672-2-git-send-email-vyasevic@redhat.com>
References: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932449AbaEPN72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 09:59:28 -0400
In-Reply-To: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the flag change macro into a function to allow
easier updates and to reduce space.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_sysfs_if.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index dd595bd..351af6b 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -41,20 +41,27 @@ static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
 }								\
 static int store_##_name(struct net_bridge_port *p, unsigned long v) \
 {								\
-	unsigned long flags = p->flags;				\
-	if (v)							\
-		flags |= _mask;					\
-	else							\
-		flags &= ~_mask;				\
-	if (flags != p->flags) {				\
-		p->flags = flags;				\
-		br_ifinfo_notify(RTM_NEWLINK, p);		\
-	}							\
-	return 0;						\
+	return store_flag(p, v, _mask);				\
 }								\
 static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
 		   show_##_name, store_##_name)
 
+static int store_flag(struct net_bridge_port *p, unsigned long v,
+		      unsigned long mask)
+{
+	unsigned long flags = p->flags;
+
+	if (v)
+		flags |= mask;
+	else
+		flags &= ~mask;
+
+	if (flags != p->flags) {
+		p->flags = flags;
+		br_ifinfo_notify(RTM_NEWLINK, p);
+	}
+	return 0;
+}
 
 static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
 {
-- 
1.9.0
