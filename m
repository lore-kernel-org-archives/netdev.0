From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] netdev: use const for some name functions
Date: Tue, 23 Sep 2008 08:39:34 -0700
Message-ID: <20080923083934.032d6098@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52479 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbYIWPq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 11:46:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_change_name and netdev_drivername should use const char on parameters
that are read-only input values. The strcpy to newname is not needed since
newname is not used later in function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/netdevice.h	2008-09-23 08:29:15.000000000 -0700
+++ b/include/linux/netdevice.h	2008-09-23 08:29:16.000000000 -0700
@@ -1225,7 +1225,7 @@ extern int		dev_ioctl(struct net *net, u
 extern int		dev_ethtool(struct net *net, struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
-extern int		dev_change_name(struct net_device *, char *);
+extern int		dev_change_name(struct net_device *, const char *);
 extern int		dev_set_alias(struct net_device *, const char *, size_t);
 extern int		dev_change_net_namespace(struct net_device *,
 						 struct net *, const char *);
@@ -1670,7 +1670,7 @@ extern void dev_seq_stop(struct seq_file
 extern int netdev_class_create_file(struct class_attribute *class_attr);
 extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
-extern char *netdev_drivername(struct net_device *dev, char *buffer, int len);
+extern char *netdev_drivername(const struct net_device *dev, char *buffer, int len);
 
 extern void linkwatch_run_queue(void);
 
--- a/net/core/dev.c	2008-09-23 08:29:15.000000000 -0700
+++ b/net/core/dev.c	2008-09-23 08:32:48.000000000 -0700
@@ -890,7 +890,7 @@ int dev_alloc_name(struct net_device *de
  *	Change name of a device, can pass format strings "eth%d".
  *	for wildcarding.
  */
-int dev_change_name(struct net_device *dev, char *newname)
+int dev_change_name(struct net_device *dev, const char *newname)
 {
 	char oldname[IFNAMSIZ];
 	int err = 0;
@@ -916,7 +916,6 @@ int dev_change_name(struct net_device *d
 		err = dev_alloc_name(dev, newname);
 		if (err < 0)
 			return err;
-		strcpy(newname, dev->name);
 	}
 	else if (__dev_get_by_name(net, newname))
 		return -EEXIST;
@@ -4746,10 +4745,10 @@ err_name:
 	return -ENOMEM;
 }
 
-char *netdev_drivername(struct net_device *dev, char *buffer, int len)
+char *netdev_drivername(const struct net_device *dev, char *buffer, int len)
 {
-	struct device_driver *driver;
-	struct device *parent;
+	const struct device_driver *driver;
+	const struct device *parent;
 
 	if (len <= 0 || !buffer)
 		return buffer;
