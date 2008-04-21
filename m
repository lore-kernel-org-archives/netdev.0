From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6 patch] remove ieee80211_wx_{get,set}_auth()
Date: Mon, 21 Apr 2008 11:48:34 +0300
Message-ID: <20080421084834.GP26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:35034 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436AbYDUItE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:49:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the bcm43xx removal ieee80211_wx_{get,set}_auth() were no longer 
used.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/net/ieee80211.h      |    8 ---
 net/ieee80211/ieee80211_wx.c |   89 -----------------------------------
 2 files changed, 97 deletions(-)

ec783a7fb0fdacebefd93c7bf40493467a825c70 diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index facd0ff..b31399e 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1309,14 +1309,6 @@ extern int ieee80211_wx_set_encodeext(struct ieee80211_device *ieee,
 extern int ieee80211_wx_get_encodeext(struct ieee80211_device *ieee,
 				      struct iw_request_info *info,
 				      union iwreq_data *wrqu, char *extra);
-extern int ieee80211_wx_set_auth(struct net_device *dev,
-				 struct iw_request_info *info,
-				 union iwreq_data *wrqu,
-				 char *extra);
-extern int ieee80211_wx_get_auth(struct net_device *dev,
-				 struct iw_request_info *info,
-				 union iwreq_data *wrqu,
-				 char *extra);
 
 static inline void ieee80211_increment_scans(struct ieee80211_device *ieee)
 {
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index 623489a..822606b 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -744,98 +744,9 @@ int ieee80211_wx_get_encodeext(struct ieee80211_device *ieee,
 	return 0;
 }
 
-int ieee80211_wx_set_auth(struct net_device *dev,
-			  struct iw_request_info *info,
-			  union iwreq_data *wrqu,
-			  char *extra)
-{
-	struct ieee80211_device *ieee = netdev_priv(dev);
-	unsigned long flags;
-	int err = 0;
-
-	spin_lock_irqsave(&ieee->lock, flags);
-
-	switch (wrqu->param.flags & IW_AUTH_INDEX) {
-	case IW_AUTH_WPA_VERSION:
-	case IW_AUTH_CIPHER_PAIRWISE:
-	case IW_AUTH_CIPHER_GROUP:
-	case IW_AUTH_KEY_MGMT:
-		/*
-		 * Host AP driver does not use these parameters and allows
-		 * wpa_supplicant to control them internally.
-		 */
-		break;
-	case IW_AUTH_TKIP_COUNTERMEASURES:
-		break;		/* FIXME */
-	case IW_AUTH_DROP_UNENCRYPTED:
-		ieee->drop_unencrypted = !!wrqu->param.value;
-		break;
-	case IW_AUTH_80211_AUTH_ALG:
-		break;		/* FIXME */
-	case IW_AUTH_WPA_ENABLED:
-		ieee->privacy_invoked = ieee->wpa_enabled = !!wrqu->param.value;
-		break;
-	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-		ieee->ieee802_1x = !!wrqu->param.value;
-		break;
-	case IW_AUTH_PRIVACY_INVOKED:
-		ieee->privacy_invoked = !!wrqu->param.value;
-		break;
-	default:
-		err = -EOPNOTSUPP;
-		break;
-	}
-	spin_unlock_irqrestore(&ieee->lock, flags);
-	return err;
-}
-
-int ieee80211_wx_get_auth(struct net_device *dev,
-			  struct iw_request_info *info,
-			  union iwreq_data *wrqu,
-			  char *extra)
-{
-	struct ieee80211_device *ieee = netdev_priv(dev);
-	unsigned long flags;
-	int err = 0;
-
-	spin_lock_irqsave(&ieee->lock, flags);
-
-	switch (wrqu->param.flags & IW_AUTH_INDEX) {
-	case IW_AUTH_WPA_VERSION:
-	case IW_AUTH_CIPHER_PAIRWISE:
-	case IW_AUTH_CIPHER_GROUP:
-	case IW_AUTH_KEY_MGMT:
-	case IW_AUTH_TKIP_COUNTERMEASURES:		/* FIXME */
-	case IW_AUTH_80211_AUTH_ALG:			/* FIXME */
-		/*
-		 * Host AP driver does not use these parameters and allows
-		 * wpa_supplicant to control them internally.
-		 */
-		err = -EOPNOTSUPP;
-		break;
-	case IW_AUTH_DROP_UNENCRYPTED:
-		wrqu->param.value = ieee->drop_unencrypted;
-		break;
-	case IW_AUTH_WPA_ENABLED:
-		wrqu->param.value = ieee->wpa_enabled;
-		break;
-	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-		wrqu->param.value = ieee->ieee802_1x;
-		break;
-	default:
-		err = -EOPNOTSUPP;
-		break;
-	}
-	spin_unlock_irqrestore(&ieee->lock, flags);
-	return err;
-}
-
 EXPORT_SYMBOL(ieee80211_wx_set_encodeext);
 EXPORT_SYMBOL(ieee80211_wx_get_encodeext);
 
 EXPORT_SYMBOL(ieee80211_wx_get_scan);
 EXPORT_SYMBOL(ieee80211_wx_set_encode);
 EXPORT_SYMBOL(ieee80211_wx_get_encode);
-
-EXPORT_SYMBOL_GPL(ieee80211_wx_set_auth);
-EXPORT_SYMBOL_GPL(ieee80211_wx_get_auth);

