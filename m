From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 07/10] net: make BQL sysfs attributes ro_after_init
Date: Fri, 18 Aug 2017 13:46:25 -0700
Message-ID: <20170818204628.17147-8-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:37619 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbdHRUqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:44 -0400
Received: by mail-pg0-f49.google.com with SMTP id y129so71046761pgy.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:44 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix macro to not have ; at end.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 48714c8024f3..a4af5e2ff398 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1144,9 +1144,9 @@ static ssize_t bql_set_hold_time(struct netdev_queue *queue,
 	return len;
 }
 
-static struct netdev_queue_attribute bql_hold_time_attribute =
-	__ATTR(hold_time, S_IRUGO | S_IWUSR, bql_show_hold_time,
-	    bql_set_hold_time);
+static struct netdev_queue_attribute bql_hold_time_attribute __ro_after_init
+	= __ATTR(hold_time, S_IRUGO | S_IWUSR,
+		 bql_show_hold_time, bql_set_hold_time);
 
 static ssize_t bql_show_inflight(struct netdev_queue *queue,
 				 char *buf)
@@ -1156,7 +1156,7 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 	return sprintf(buf, "%u\n", dql->num_queued - dql->num_completed);
 }
 
-static struct netdev_queue_attribute bql_inflight_attribute =
+static struct netdev_queue_attribute bql_inflight_attribute __ro_after_init =
 	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
 
 #define BQL_ATTR(NAME, FIELD)						\
@@ -1172,15 +1172,15 @@ static ssize_t bql_set_ ## NAME(struct netdev_queue *queue,		\
 	return bql_set(buf, len, &queue->dql.FIELD);			\
 }									\
 									\
-static struct netdev_queue_attribute bql_ ## NAME ## _attribute =	\
-	__ATTR(NAME, S_IRUGO | S_IWUSR, bql_show_ ## NAME,		\
-	    bql_set_ ## NAME);
+static struct netdev_queue_attribute bql_ ## NAME ## _attribute __ro_after_init \
+	= __ATTR(NAME, S_IRUGO | S_IWUSR,				\
+		 bql_show_ ## NAME, bql_set_ ## NAME)
 
-BQL_ATTR(limit, limit)
-BQL_ATTR(limit_max, max_limit)
-BQL_ATTR(limit_min, min_limit)
+BQL_ATTR(limit, limit);
+BQL_ATTR(limit_max, max_limit);
+BQL_ATTR(limit_min, min_limit);
 
-static struct attribute *dql_attrs[] = {
+static struct attribute *dql_attrs[] __ro_after_init = {
 	&bql_limit_attribute.attr,
 	&bql_limit_max_attribute.attr,
 	&bql_limit_min_attribute.attr,
-- 
2.11.0
