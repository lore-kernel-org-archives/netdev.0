From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 31 May 2005 10:40:11 -0700
Message-ID: <20050531104011.654ad281@dxpl.pdx.osdl.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
	<20050527085055.79da3d75@dxpl.pdx.osdl.net>
	<Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
	<20050527140132.1435132d@dxpl.pdx.osdl.net>
	<1117241786.6251.7.camel@localhost.localdomain>
	<Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "Williams, Mitch A"
 <mitch.a.williams@intel.com>,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse"
 <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Like this (untested) patch:

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
