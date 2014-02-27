From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH 3/4] ath6kl: set NET_NAME_USER for P2P ifs
Date: Thu, 27 Feb 2014 15:47:13 +0100
Message-ID: <1393512434-1325-4-git-send-email-dh.herrmann@gmail.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	David Herrmann <dh.herrmann@gmail.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

P2P netdevs and other devices that are created via nl80211 from user-space
have a name provided by user-space. Therefore, set NET_NAME_USER so this
is correctly shown in sysfs.

Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c | 5 ++++-
 drivers/net/wireless/ath/ath6kl/cfg80211.h | 1 +
 drivers/net/wireless/ath/ath6kl/core.c     | 4 ++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index fd4c89d..74598ed 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -1516,7 +1516,8 @@ static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
 		return ERR_PTR(-EINVAL);
 	}
 
-	wdev = ath6kl_interface_add(ar, name, type, if_idx, nw_type);
+	wdev = ath6kl_interface_add(ar, name, NET_NAME_USER, type,
+				    if_idx, nw_type);
 	if (!wdev)
 		return ERR_PTR(-ENOMEM);
 
@@ -3625,6 +3626,7 @@ void ath6kl_cfg80211_vif_cleanup(struct ath6kl_vif *vif)
 }
 
 struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
+					  unsigned char name_assign_type,
 					  enum nl80211_iftype type,
 					  u8 fw_vif_idx, u8 nw_type)
 {
@@ -3661,6 +3663,7 @@ struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
 			ndev->dev_addr[4] ^= 0x80;
 	}
 
+	ndev->name_assign_type = name_assign_type;
 	init_netdev(ndev);
 
 	ath6kl_init_control_info(vif);
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.h b/drivers/net/wireless/ath/ath6kl/cfg80211.h
index b59becd..5aa57a7 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.h
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.h
@@ -25,6 +25,7 @@ enum ath6kl_cfg_suspend_mode {
 };
 
 struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
+					  unsigned char name_assign_type,
 					  enum nl80211_iftype type,
 					  u8 fw_vif_idx, u8 nw_type);
 void ath6kl_cfg80211_ch_switch_notify(struct ath6kl_vif *vif, int freq,
diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
index 4b46adb..3cc8145 100644
--- a/drivers/net/wireless/ath/ath6kl/core.c
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -195,8 +195,8 @@ int ath6kl_core_init(struct ath6kl *ar, enum ath6kl_htc_type htc_type)
 	rtnl_lock();
 
 	/* Add an initial station interface */
-	wdev = ath6kl_interface_add(ar, "wlan%d", NL80211_IFTYPE_STATION, 0,
-				    INFRA_NETWORK);
+	wdev = ath6kl_interface_add(ar, "wlan%d", NET_NAME_ENUM,
+				    NL80211_IFTYPE_STATION, 0, INFRA_NETWORK);
 
 	rtnl_unlock();
 
-- 
1.9.0
