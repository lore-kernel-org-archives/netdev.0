From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 13/13] bridge: Add multicast count/interval sysfs entries
Date: Fri, 26 Feb 2010 23:35:18 +0800
Message-ID: <E1Nl2Dm-0006x9-TQ@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52538 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965145Ab0BZPf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast count/interval sysfs entries

This patch allows the user to the IGMP parameters related to the
snooping function of the bridge.  This includes various time
values and retransmission limits.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_sysfs_br.c |  203 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 203 insertions(+)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index d2ee53b..dd321e3 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -415,6 +415,201 @@ static ssize_t store_hash_max(struct device *d, struct device_attribute *attr,
 }
 static DEVICE_ATTR(hash_max, S_IRUGO | S_IWUSR, show_hash_max,
 		   store_hash_max);
+
+static ssize_t show_multicast_last_member_count(struct device *d,
+						struct device_attribute *attr,
+						char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->multicast_last_member_count);
+}
+
+static int set_last_member_count(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_last_member_count = val;
+	return 0;
+}
+
+static ssize_t store_multicast_last_member_count(struct device *d,
+						 struct device_attribute *attr,
+						 const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_last_member_count);
+}
+static DEVICE_ATTR(multicast_last_member_count, S_IRUGO | S_IWUSR,
+		   show_multicast_last_member_count,
+		   store_multicast_last_member_count);
+
+static ssize_t show_multicast_startup_query_count(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->multicast_startup_query_count);
+}
+
+static int set_startup_query_count(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_startup_query_count = val;
+	return 0;
+}
+
+static ssize_t store_multicast_startup_query_count(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_startup_query_count);
+}
+static DEVICE_ATTR(multicast_startup_query_count, S_IRUGO | S_IWUSR,
+		   show_multicast_startup_query_count,
+		   store_multicast_startup_query_count);
+
+static ssize_t show_multicast_last_member_interval(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(br->multicast_last_member_interval));
+}
+
+static int set_last_member_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_last_member_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_last_member_interval(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_last_member_interval);
+}
+static DEVICE_ATTR(multicast_last_member_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_last_member_interval,
+		   store_multicast_last_member_interval);
+
+static ssize_t show_multicast_membership_interval(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(br->multicast_membership_interval));
+}
+
+static int set_membership_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_membership_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_membership_interval(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_membership_interval);
+}
+static DEVICE_ATTR(multicast_membership_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_membership_interval,
+		   store_multicast_membership_interval);
+
+static ssize_t show_multicast_querier_interval(struct device *d,
+					       struct device_attribute *attr,
+					       char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(br->multicast_querier_interval));
+}
+
+static int set_querier_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_querier_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_querier_interval(struct device *d,
+						struct device_attribute *attr,
+						const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_querier_interval);
+}
+static DEVICE_ATTR(multicast_querier_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_querier_interval,
+		   store_multicast_querier_interval);
+
+static ssize_t show_multicast_query_interval(struct device *d,
+					     struct device_attribute *attr,
+					     char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%lu\n",
+		       jiffies_to_clock_t(br->multicast_query_interval));
+}
+
+static int set_query_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_query_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_query_interval(struct device *d,
+					      struct device_attribute *attr,
+					      const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_query_interval);
+}
+static DEVICE_ATTR(multicast_query_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_query_interval,
+		   store_multicast_query_interval);
+
+static ssize_t show_multicast_query_response_interval(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(
+		buf, "%lu\n",
+		jiffies_to_clock_t(br->multicast_query_response_interval));
+}
+
+static int set_query_response_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_query_response_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_query_response_interval(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_query_response_interval);
+}
+static DEVICE_ATTR(multicast_query_response_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_query_response_interval,
+		   store_multicast_query_response_interval);
+
+static ssize_t show_multicast_startup_query_interval(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(
+		buf, "%lu\n",
+		jiffies_to_clock_t(br->multicast_startup_query_interval));
+}
+
+static int set_startup_query_interval(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_startup_query_interval = clock_t_to_jiffies(val);
+	return 0;
+}
+
+static ssize_t store_multicast_startup_query_interval(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_startup_query_interval);
+}
+static DEVICE_ATTR(multicast_startup_query_interval, S_IRUGO | S_IWUSR,
+		   show_multicast_startup_query_interval,
+		   store_multicast_startup_query_interval);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -441,6 +636,14 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_snooping.attr,
 	&dev_attr_hash_elasticity.attr,
 	&dev_attr_hash_max.attr,
+	&dev_attr_multicast_last_member_count.attr,
+	&dev_attr_multicast_startup_query_count.attr,
+	&dev_attr_multicast_last_member_interval.attr,
+	&dev_attr_multicast_membership_interval.attr,
+	&dev_attr_multicast_querier_interval.attr,
+	&dev_attr_multicast_query_interval.attr,
+	&dev_attr_multicast_query_response_interval.attr,
+	&dev_attr_multicast_startup_query_interval.attr,
 #endif
 	NULL
 };
