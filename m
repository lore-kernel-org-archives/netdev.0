From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/21] d80211: relax sysfs permissions
Date: Wed, 23 Aug 2006 21:24:09 +0200 (CEST)
Message-ID: <20060823192409.B2E714839B@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26576 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965011AbWHWTYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:09 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

The sysfs attributes add_iface and remove_iface both check for
CAP_NET_ADMIN whenever something is written. Hence, permissions for the
files should be relaxed so that someone who is not root but happens to
have CAP_NET_ADMIN can do things.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

b8fa453a5bff1710a6e170e9d50fa337bee5ebdf
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 9974668..6725ff7 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -195,8 +195,8 @@ static ssize_t ieee80211_local_fmt_rate_
 __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
 
 static struct class_device_attribute ieee80211_class_dev_attrs[] = {
-	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
-	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
+	__ATTR(add_iface, S_IWUGO, NULL, store_add_iface),
+	__ATTR(remove_iface, S_IWUGO, NULL, store_remove_iface),
 	__ATTR(channel, S_IRUGO, ieee80211_local_show_channel, NULL),
 	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
 	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
-- 
1.3.0

