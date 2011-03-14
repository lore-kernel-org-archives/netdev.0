From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: [PATCH] Fix overflow of name in struct net_device, replaced str* and sprintf with strn* and snprintf respectivly.
Date: Tue, 15 Mar 2011 01:37:28 +0530
Message-ID: <1300133248-2927-1-git-send-email-sasikanth.v19@gmail.com>
Cc: netdev@vger.kernel.org, Sasikanth V <sasikanth.v19@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:57046 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab1CNUHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:07:40 -0400
Received: by qyk7 with SMTP id 7so1773319qyk.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 13:07:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/core/dev.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..9d06c1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -510,7 +510,7 @@ int netdev_boot_setup_check(struct net_device *dev)
 
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
 		if (s[i].name[0] != '\0' && s[i].name[0] != ' ' &&
-		    !strcmp(dev->name, s[i].name)) {
+		    !strncmp(dev->name, s[i].name, IFNAMSIZ)) {
 			dev->irq 	= s[i].map.irq;
 			dev->base_addr 	= s[i].map.base_addr;
 			dev->mem_start 	= s[i].map.mem_start;
@@ -539,7 +539,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
 	char name[IFNAMSIZ];
 	int i;
 
-	sprintf(name, "%s%d", prefix, unit);
+	snprintf(name, IFNAMSIZ, "%s%d", prefix, unit);
 
 	/*
 	 * If device already registered then return base of 1
@@ -549,7 +549,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
 		return 1;
 
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
-		if (!strcmp(name, s[i].name))
+		if (!strncmp(name, s[i].name, IFNAMSIZ))
 			return s[i].map.base_addr;
 	return 0;
 }
@@ -836,7 +836,7 @@ EXPORT_SYMBOL(dev_get_by_flags_rcu);
  */
 int dev_valid_name(const char *name)
 {
-	if (*name == '\0')
+	if (!name || *name == '\0')
 		return 0;
 	if (strlen(name) >= IFNAMSIZ)
 		return 0;
@@ -3834,7 +3834,7 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
 		return -ENODEV;
 	}
 
-	strcpy(ifr.ifr_name, dev->name);
+	strncpy(ifr.ifr_name, dev->name, IFNAMSIZ);
 	rcu_read_unlock();
 
 	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
@@ -4821,7 +4821,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
 
-	ifr.ifr_name[IFNAMSIZ-1] = 0;
+	ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
 	colon = strchr(ifr.ifr_name, ':');
 	if (colon)
@@ -5694,7 +5694,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		goto free_all;
 #endif
 
-	strcpy(dev->name, name);
+	strncpy(dev->name, name, IFNAMSIZ);
 	return dev;
 
 free_all:
-- 
1.7.3.4

