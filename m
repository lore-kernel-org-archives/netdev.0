From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 4/5] net: show numa_node for net_device  in /sys
Date: Tue, 10 Jul 2007 16:52:58 -0700
Message-ID: <200707101652.59346.yinghai.lu@sun.com>
References: <200707101641.17672.yinghai.lu@sun.com>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:38434 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763303AbXGKABA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:01:00 -0400
In-reply-to: <200707101641.17672.yinghai.lu@sun.com>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 4/5] net: show numa_node for net_device  in /sys

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5c19b06..45b87a5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -230,6 +230,14 @@ static ssize_t store_weight(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_weight);
 }
 
+#ifdef CONFIG_NUMA
+static ssize_t
+numa_node_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+        return sprintf (buf, "%d\n", dev->numa_node);
+}
+#endif
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -247,6 +255,9 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
 	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
+#ifdef CONFIG_NUMA
+        __ATTR_RO(numa_node),
+#endif
 	{}
 };
 
