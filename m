From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 010/493] isdn: remove CONFIG_HOTPLUG ifdefs
Date: Mon, 19 Nov 2012 13:19:19 -0500
Message-ID: <1353349642-3677-10-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41669 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534Ab2KSSiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:11 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove conditional code based on CONFIG_HOTPLUG being false.  It's
always on now in preparation of it going away as an option.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de> 
Cc: netdev@vger.kernel.org 
---
 drivers/isdn/hisax/config.c     | 3 ---
 drivers/isdn/hisax/hfc4s8s_l1.c | 8 --------
 drivers/isdn/mISDN/core.c       | 4 ----
 3 files changed, 15 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index b5edc0e..386f544 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1547,8 +1547,6 @@ static void __exit HiSax_exit(void)
 	printk(KERN_INFO "HiSax module removed\n");
 }
 
-#ifdef CONFIG_HOTPLUG
-
 int __devinit hisax_init_pcmcia(void *pcm_iob, int *busy_flag, struct IsdnCard *card)
 {
 	u_char ids[16];
@@ -1570,7 +1568,6 @@ error:
 }
 
 EXPORT_SYMBOL(hisax_init_pcmcia);
-#endif
 
 EXPORT_SYMBOL(HiSax_closecard);
 
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index dea04de..f794850 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1688,14 +1688,6 @@ hfc4s8s_module_init(void)
 	}
 	printk(KERN_INFO "HFC-4S/8S: found %d cards\n", card_cnt);
 
-#if !defined(CONFIG_HOTPLUG)
-	if (err == 0) {
-		err = -ENODEV;
-		pci_unregister_driver(&hfc4s8s_driver);
-		goto out;
-	}
-#endif
-
 	return 0;
 out:
 	return (err);
diff --git a/drivers/isdn/mISDN/core.c b/drivers/isdn/mISDN/core.c
index c401634..3e24571 100644
--- a/drivers/isdn/mISDN/core.c
+++ b/drivers/isdn/mISDN/core.c
@@ -140,7 +140,6 @@ static struct device_attribute mISDN_dev_attrs[] = {
 	{}
 };
 
-#ifdef CONFIG_HOTPLUG
 static int mISDN_uevent(struct device *dev, struct kobj_uevent_env *env)
 {
 	struct mISDNdevice *mdev = dev_to_mISDN(dev);
@@ -153,7 +152,6 @@ static int mISDN_uevent(struct device *dev, struct kobj_uevent_env *env)
 
 	return 0;
 }
-#endif
 
 static void mISDN_class_release(struct class *cls)
 {
@@ -163,9 +161,7 @@ static void mISDN_class_release(struct class *cls)
 static struct class mISDN_class = {
 	.name = "mISDN",
 	.owner = THIS_MODULE,
-#ifdef CONFIG_HOTPLUG
 	.dev_uevent = mISDN_uevent,
-#endif
 	.dev_attrs = mISDN_dev_attrs,
 	.dev_release = mISDN_dev_release,
 	.class_release = mISDN_class_release,
-- 
1.8.0
