From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Mon, 28 Aug 2006 13:50:54 -0700
Message-ID: <44F3572E.8020506@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070107090300090104000806"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:39460 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S932070AbWH1Uuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:50:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070107090300090104000806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------070107090300090104000806
Content-Type: text/x-patch;
 name="d80211-wnick.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-wnick.patch"


This patch modify d80211 to add nick wireless command 

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0d2d79d..02242c6 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -241,6 +241,7 @@ struct ieee80211_if_sta {
 		IEEE80211_IBSS_SEARCH, IEEE80211_IBSS_JOINED
 	} state;
 	struct timer_list timer;
+	u8 nick[IW_ESSID_MAX_SIZE];
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..956eabb 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2153,6 +2153,39 @@ static void ieee80211_ioctl_unmask_chann
 }
 
 
+static int ieee80211_ioctl_siwnick(struct net_device *dev,
+				   struct iw_request_info *info,
+				   union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_if_sta *ifsta;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ifsta = &sdata->u.sta;
+	if (wrqu->data.length >= IW_ESSID_MAX_SIZE)
+		return -E2BIG;
+
+	memset(ifsta->nick, 0, sizeof(ifsta->nick));
+	memcpy(ifsta->nick, extra, wrqu->data.length);
+	return 0;
+}
+
+static int ieee80211_ioctl_giwnick(struct net_device *dev,
+				   struct iw_request_info *info,
+				   union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_if_sta *ifsta;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ifsta = &sdata->u.sta;
+
+	wrqu->data.length = strlen(ifsta->nick) + 1;
+	memcpy(extra, ifsta->nick, wrqu->data.length);
+	wrqu->data.flags = 1;   /* active */
+	return 0;
+}
+
 static int ieee80211_ioctl_test_mode(struct net_device *dev, int mode)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -3138,8 +3171,8 @@ static const iw_handler ieee80211_handle
 	(iw_handler) ieee80211_ioctl_giwscan,		/* SIOCGIWSCAN */
 	(iw_handler) ieee80211_ioctl_siwessid,		/* SIOCSIWESSID */
 	(iw_handler) ieee80211_ioctl_giwessid,		/* SIOCGIWESSID */
-	(iw_handler) NULL,				/* SIOCSIWNICKN */
-	(iw_handler) NULL,				/* SIOCGIWNICKN */
+	(iw_handler) ieee80211_ioctl_siwnick,		/* SIOCSIWNICKN */
+	(iw_handler) ieee80211_ioctl_giwnick,		/* SIOCGIWNICKN */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* SIOCSIWRATE */

--------------070107090300090104000806--
