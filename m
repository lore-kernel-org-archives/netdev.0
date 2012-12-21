From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] CONFIG_HOTPLUG removal from networking core
Date: Fri, 21 Dec 2012 15:44:29 -0800
Message-ID: <20121221234429.GB13447@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Pemberton <wfp5p@virginia.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60386 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab2LUXlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 18:41:23 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so3105689pad.34
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 15:41:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is always enabled now, so remove the unused code that was
trying to be compiled out when this option was disabled, in the
networking core.

Cc: Bill Pemberton <wfp5p@virginia.edu>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 334efd5..28c5f5a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1334,7 +1334,6 @@ struct kobj_ns_type_operations net_ns_type_operations = {
 };
 EXPORT_SYMBOL_GPL(net_ns_type_operations);
 
-#ifdef CONFIG_HOTPLUG
 static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 {
 	struct net_device *dev = to_net_dev(d);
@@ -1353,7 +1352,6 @@ static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 exit:
 	return retval;
 }
-#endif
 
 /*
  *	netdev_release -- destroy and free a dead device.
@@ -1382,9 +1380,7 @@ static struct class net_class = {
 #ifdef CONFIG_SYSFS
 	.dev_attrs = net_class_attributes,
 #endif /* CONFIG_SYSFS */
-#ifdef CONFIG_HOTPLUG
 	.dev_uevent = netdev_uevent,
-#endif
 	.ns_type = &net_ns_type_operations,
 	.namespace = net_namespace,
 };
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 6e53089..82c4fc7 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2365,7 +2365,6 @@ int set_regdom(const struct ieee80211_regdomain *rd)
 	return r;
 }
 
-#ifdef CONFIG_HOTPLUG
 int reg_device_uevent(struct device *dev, struct kobj_uevent_env *env)
 {
 	if (last_request && !last_request->processed) {
@@ -2377,12 +2376,6 @@ int reg_device_uevent(struct device *dev, struct kobj_uevent_env *env)
 
 	return 0;
 }
-#else
-int reg_device_uevent(struct device *dev, struct kobj_uevent_env *env)
-{
-	return -ENODEV;
-}
-#endif /* CONFIG_HOTPLUG */
 
 void wiphy_regulatory_register(struct wiphy *wiphy)
 {
diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index 9bf6d5e..1f6f01e 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -77,13 +77,11 @@ static void wiphy_dev_release(struct device *dev)
 	cfg80211_dev_free(rdev);
 }
 
-#ifdef CONFIG_HOTPLUG
 static int wiphy_uevent(struct device *dev, struct kobj_uevent_env *env)
 {
 	/* TODO, we probably need stuff here */
 	return 0;
 }
-#endif
 
 static int wiphy_suspend(struct device *dev, pm_message_t state)
 {
@@ -134,9 +132,7 @@ struct class ieee80211_class = {
 	.owner = THIS_MODULE,
 	.dev_release = wiphy_dev_release,
 	.dev_attrs = ieee80211_dev_attrs,
-#ifdef CONFIG_HOTPLUG
 	.dev_uevent = wiphy_uevent,
-#endif
 	.suspend = wiphy_suspend,
 	.resume = wiphy_resume,
 	.ns_type = &net_ns_type_operations,
