From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 017/493] wireless: remove CONFIG_HOTPLUG ifdefs
Date: Mon, 19 Nov 2012 13:19:26 -0500
Message-ID: <1353349642-3677-17-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41652 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab2KSSiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:03 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove conditional code based on CONFIG_HOTPLUG being false.  It's
always on now in preparation of it going away as an option.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Johannes Berg <johannes@sipsolutions.net> 
Cc: "John W. Linville" <linville@tuxdriver.com> 
Cc: "David S. Miller" <davem@davemloft.net> 
Cc: linux-wireless@vger.kernel.org 
Cc: netdev@vger.kernel.org 
---
 net/wireless/reg.c   | 7 -------
 net/wireless/sysfs.c | 4 ----
 2 files changed, 11 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index b75756b..d3768a3 100644
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
-- 
1.8.0
