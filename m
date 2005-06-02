From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net: allow controlling NAPI weight with sysfs
Date: Thu, 2 Jun 2005 11:14:37 -0700
Message-ID: <20050602111437.1c492138@dxpl.pdx.osdl.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simple interface to allow changing network device scheduling weight
with sysfs. Please consider this for 2.6.12, since risk/impact is small.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: napi-sysfs/net/core/net-sysfs.c
===================================================================
--- napi-sysfs.orig/net/core/net-sysfs.c
+++ napi-sysfs/net/core/net-sysfs.c
@@ -184,6 +184,22 @@ static ssize_t store_tx_queue_len(struct
 static CLASS_DEVICE_ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len, 
 			 store_tx_queue_len);
 
+NETDEVICE_SHOW(weight, fmt_ulong);
+
+static int change_weight(struct net_device *net, unsigned long new_weight)
+{
+	net->weight = new_weight;
+	return 0;
+}
+
+static ssize_t store_weight(struct class_device *dev, const char *buf, size_t len)
+{
+	return netdev_store(dev, buf, len, change_weight);
+}
+
+static CLASS_DEVICE_ATTR(weight, S_IRUGO | S_IWUSR, show_weight, 
+			 store_weight);
+
 
 static struct class_device_attribute *net_class_attributes[] = {
 	&class_device_attr_ifindex,
@@ -193,6 +209,7 @@ static struct class_device_attribute *ne
 	&class_device_attr_features,
 	&class_device_attr_mtu,
 	&class_device_attr_flags,
+	&class_device_attr_weight,
 	&class_device_attr_type,
 	&class_device_attr_address,
 	&class_device_attr_broadcast,
