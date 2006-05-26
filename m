From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] network dev.c comment cleanups
Date: Fri, 26 May 2006 10:42:48 -0700
Message-ID: <20060526104248.3ad9d526@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2753 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751205AbWEZRmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 13:42:47 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Noticed that dev_alloc_name() comment was incorrect, and more spellung errors.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br.orig/net/core/dev.c
+++ br/net/core/dev.c
@@ -127,7 +127,7 @@
  *             sure which should go first, but I bet it won't make much
  *             difference if we are running VLANs.  The good news is that
  *             this protocol won't be in the list unless compiled in, so
- *             the average user (w/out VLANs) will not be adversly affected.
+ *             the average user (w/out VLANs) will not be adversely affected.
  *             --BLG
  *
  *		0800	IP
@@ -149,7 +149,7 @@ static struct list_head ptype_base[16];	
 static struct list_head ptype_all;		/* Taps */
 
 /*
- * The @dev_base list is protected by @dev_base_lock and the rtln
+ * The @dev_base list is protected by @dev_base_lock and the rtnl
  * semaphore.
  *
  * Pure readers hold dev_base_lock for reading.
@@ -641,10 +641,12 @@ int dev_valid_name(const char *name)
  *	@name: name format string
  *
  *	Passed a format string - eg "lt%d" it will try and find a suitable
- *	id. Not efficient for many devices, not called a lot. The caller
- *	must hold the dev_base or rtnl lock while allocating the name and
- *	adding the device in order to avoid duplicates. Returns the number
- *	of the unit assigned or a negative errno code.
+ *	id. It scans list of devices to build up a free map, then chooses
+ *	the first empty slot. The caller must hold the dev_base or rtnl lock
+ *	while allocating the name and adding the device in order to avoid
+ *	duplicates.
+ *	Limited to bits_per_byte * page size devices (ie 32K on most platforms).
+ *	Returns the number of the unit assigned or a negative errno code.
  */
 
 int dev_alloc_name(struct net_device *dev, const char *name)
@@ -744,7 +746,7 @@ int dev_change_name(struct net_device *d
 }
 
 /**
- *	netdev_features_change - device changes fatures
+ *	netdev_features_change - device changes features
  *	@dev: device to cause notification
  *
  *	Called to indicate a device has changed features.
@@ -2196,7 +2198,7 @@ int netdev_set_master(struct net_device 
  *	@dev: device
  *	@inc: modifier
  *
- *	Add or remove promsicuity from a device. While the count in the device
+ *	Add or remove promiscuity from a device. While the count in the device
  *	remains above zero the interface remains promiscuous. Once it hits zero
  *	the device reverts back to normal filtering operation. A negative inc
  *	value is used to drop promiscuity on the device.
@@ -3122,7 +3124,7 @@ EXPORT_SYMBOL(alloc_netdev);
 void free_netdev(struct net_device *dev)
 {
 #ifdef CONFIG_SYSFS
-	/*  Compatiablity with error handling in drivers */
+	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
 		return;
