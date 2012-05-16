From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/2] cfg80211: deprecate CFG80211_WEXT
Date: Wed, 16 May 2012 23:40:19 +0200
Message-ID: <20120516214048.739945597@sipsolutions.net>
References: <20120516214017.936343357@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=004-cfg80211-deprecate-wext.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Almost all wireless tools have transitioned to
or at least added compatibility with nl80211 so
there's no real need for CONFIG_CFG80211_WEXT
any more. Mark it for removal, and also change
the default to not be enabled.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 Documentation/feature-removal-schedule.txt |   13 +++++++++++++
 net/wireless/Kconfig                       |    1 -
 2 files changed, 13 insertions(+), 1 deletion(-)

--- a/Documentation/feature-removal-schedule.txt	2012-05-15 20:14:51.000000000 +0200
+++ b/Documentation/feature-removal-schedule.txt	2012-05-15 20:14:51.000000000 +0200
@@ -433,6 +433,19 @@ Who:	Hans Verkuil <hans.verkuil-FYB4Gu1CFyU@public.gmane.org
 
 ----------------------------
 
+What:	CONFIG_CFG80211_WEXT
+When:	as soon as distributions ship new wireless tools, ie. wpa_supplicant 1.0
+	and NetworkManager/connman/etc. that are able to use nl80211
+Why:	Wireless extensions are deprecated, and userland tools are moving to
+	using nl80211. New drivers are no longer using wireless extensions,
+	and while there might still be old drivers, both new drivers and new
+	userland no longer needs them and they can't be used for an feature
+	developed in the past couple of years. As such, compatibility with
+	wireless extensions in new drivers will be removed.
+Who:	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+
+----------------------------
+
 What:	g_file_storage driver
 When:	3.8
 Why:	This driver has been superseded by g_mass_storage.
--- a/net/wireless/Kconfig	2012-05-15 20:14:51.000000000 +0200
+++ b/net/wireless/Kconfig	2012-05-15 20:14:51.000000000 +0200
@@ -114,7 +114,6 @@ config CFG80211_WEXT
 	bool "cfg80211 wireless extensions compatibility"
 	depends on CFG80211
 	select WEXT_CORE
-	default y
 	help
 	  Enable this option if you need old userspace for wireless
 	  extensions with cfg80211-based drivers.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
