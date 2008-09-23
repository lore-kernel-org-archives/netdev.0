From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] netdev: docbook comment update (revised)
Date: Tue, 23 Sep 2008 10:02:40 -0700
Message-ID: <20080923100240.5168d861@extreme>
References: <20080923083750.59eaac97@extreme>
	<20080923091035.102d4106@extreme>
	<Pine.LNX.4.64.0809230917020.27041@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56276 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499AbYIWRCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 13:02:54 -0400
In-Reply-To: <Pine.LNX.4.64.0809230917020.27041@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add more docbook comments to network device functions and cleanup
the comments.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/net/core/dev.c	2008-09-23 08:32:48.000000000 -0700
+++ b/net/core/dev.c	2008-09-23 10:00:10.000000000 -0700
@@ -956,6 +956,7 @@ rollback:
  *	dev_set_alias - change ifalias of a device
  *	@dev: device
  *	@alias: name up to IFALIASZ
+ *	@len: limit of bytes to copy from info
  *
  *	Set ifalias for a device,
  */
@@ -3322,6 +3323,12 @@ static void dev_addr_discard(struct net_
 	netif_addr_unlock_bh(dev);
 }
 
+/**
+ *	dev_get_flags - get flags reported to userspace
+ *	@dev: device
+ *
+ *	Get the combination of flag bits exported throug APIs to userspace.
+ */
 unsigned dev_get_flags(const struct net_device *dev)
 {
 	unsigned flags;
@@ -3346,6 +3353,14 @@ unsigned dev_get_flags(const struct net_
 	return flags;
 }
 
+/**
+ *	dev_change_flags - change device settings
+ *	@dev: device
+ *	@flags: device state flags
+ *
+ *	Change settings on device based state flags. The flags are
+ *	in the userspace exported format.
+ */
 int dev_change_flags(struct net_device *dev, unsigned flags)
 {
 	int ret, changes;
@@ -3415,6 +3430,13 @@ int dev_change_flags(struct net_device *
 	return ret;
 }
 
+/**
+ *	dev_set_mtu - Change maximum transfer unit
+ *	@dev: device
+ *	@new_mtu: new transfer unit
+ *
+ *	Change the maximum transfer size of the network device.
+ */
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
 	int err;
@@ -3439,6 +3461,13 @@ int dev_set_mtu(struct net_device *dev, 
 	return err;
 }
 
+/**
+ *	dev_set_mac_address - Change Media Access Control Address
+ *	@dev: device
+ *	@sa: new address
+ *
+ *	Change the hardware (MAC) address of the device
+ */
 int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 {
 	int err;
@@ -4342,7 +4371,12 @@ void free_netdev(struct net_device *dev)
 	put_device(&dev->dev);
 }
 
-/* Synchronize with packet receive processing. */
+/**
+ *	synchronize_net -  Synchronize with packet receive processing
+ *
+ *	Wait for packets currently being received to be done.
+ *	Does not block later packets from starting.
+ */
 void synchronize_net(void)
 {
 	might_sleep();
@@ -4644,7 +4678,7 @@ netdev_dma_event(struct dma_client *clie
 }
 
 /**
- * netdev_dma_regiser - register the networking subsystem as a DMA client
+ * netdev_dma_register - register the networking subsystem as a DMA client
  */
 static int __init netdev_dma_register(void)
 {
@@ -4745,6 +4779,14 @@ err_name:
 	return -ENOMEM;
 }
 
+/**
+ *	netdev_drivername - network driver for the device
+ *	@dev: network device
+ *	@buffer: buffer for resulting name
+ *	@len: size of buffer
+ *
+ *	Determine network driver for device.
+ */
 char *netdev_drivername(const struct net_device *dev, char *buffer, int len)
 {
 	const struct device_driver *driver;
