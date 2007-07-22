From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 05/12 -Rev2] sysfs changes.
Date: Sun, 22 Jul 2007 14:35:44 +0530
Message-ID: <20070722090544.7787.87947.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, kaber@trash.net, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/net/core/net-sysfs.c rev2/net/core/net-sysfs.c
--- org/net/core/net-sysfs.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/net/core/net-sysfs.c	2007-07-21 22:56:32.000000000 +0530
@@ -230,6 +230,21 @@ static ssize_t store_weight(struct devic
 	return netdev_store(dev, attr, buf, len, change_weight);
 }
 
+static ssize_t show_tx_batch_skb(struct device *dev,
+				 struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+
+	return sprintf(buf, fmt_dec, BATCHING_ON(netdev));
+}
+
+static ssize_t store_tx_batch_skb(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, dev_change_tx_batching);
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -246,6 +261,8 @@ static struct device_attribute net_class
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(tx_batch_skbs, S_IRUGO | S_IWUSR, show_tx_batch_skb,
+	       store_tx_batch_skb),
 	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
 	{}
 };
