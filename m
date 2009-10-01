From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 3/3] at76c50x-usb: set firmware and hardware version in wiphy
Date: Wed, 30 Sep 2009 21:19:02 -0400
Message-ID: <1254359942-3483-3-git-send-email-linville@tuxdriver.com>
References: <20091001011340.GA3123@tuxdriver.com>
 <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
 <1254359942-3483-2-git-send-email-linville@tuxdriver.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254359942-3483-2-git-send-email-linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>

Set firmware and hardware version in wiphy so that user space can access
it.

(Modification from original in favor of cfg80211 ethtool support. -- JWL)

Cc: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 drivers/net/wireless/at76c50x-usb.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 8e1a55d..533954d 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2217,6 +2217,8 @@ static struct ieee80211_supported_band at76_supported_band = {
 static int at76_init_new_device(struct at76_priv *priv,
 				struct usb_interface *interface)
 {
+	struct wiphy *wiphy;
+	size_t len;
 	int ret;
 
 	/* set up the endpoint information */
@@ -2254,6 +2256,7 @@ static int at76_init_new_device(struct at76_priv *priv,
 	priv->device_unplugged = 0;
 
 	/* mac80211 initialisation */
+	wiphy = priv->hw->wiphy;
 	priv->hw->wiphy->max_scan_ssids = 1;
 	priv->hw->wiphy->max_scan_ie_len = 0;
 	priv->hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION);
@@ -2265,6 +2268,15 @@ static int at76_init_new_device(struct at76_priv *priv,
 	SET_IEEE80211_DEV(priv->hw, &interface->dev);
 	SET_IEEE80211_PERM_ADDR(priv->hw, priv->mac_addr);
 
+	len = sizeof(wiphy->fw_version);
+	snprintf(wiphy->fw_version, len, "%d.%d.%d-%d",
+		 priv->fw_version.major, priv->fw_version.minor,
+		 priv->fw_version.patch, priv->fw_version.build);
+	/* null terminate the strings in case they were truncated */
+	wiphy->fw_version[len - 1] = '\0';
+
+	wiphy->hw_version = priv->board_type;
+
 	ret = ieee80211_register_hw(priv->hw);
 	if (ret) {
 		printk(KERN_ERR "cannot register mac80211 hw (status %d)!\n",
-- 
1.6.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
