From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/8] cfg80211.h/mac80211.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:37 -0700
Message-ID: <a0250b4b3803cd27e4b6ff7aa82db9fc148ce372.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cfg80211.h | 34 +++++++++++++++++-----------------
 include/net/mac80211.h | 16 ++++++++--------
 2 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 7b0730a..f49de28 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2841,7 +2841,7 @@ struct wiphy *wiphy_new(const struct cfg80211_ops *ops, int sizeof_priv);
  *
  * Return: A non-negative wiphy index or a negative error code.
  */
-extern int wiphy_register(struct wiphy *wiphy);
+int wiphy_register(struct wiphy *wiphy);
 
 /**
  * wiphy_unregister - deregister a wiphy from cfg80211
@@ -2852,14 +2852,14 @@ extern int wiphy_register(struct wiphy *wiphy);
  * pointer, but the call may sleep to wait for an outstanding
  * request that is being handled.
  */
-extern void wiphy_unregister(struct wiphy *wiphy);
+void wiphy_unregister(struct wiphy *wiphy);
 
 /**
  * wiphy_free - free wiphy
  *
  * @wiphy: The wiphy to free
  */
-extern void wiphy_free(struct wiphy *wiphy);
+void wiphy_free(struct wiphy *wiphy);
 
 /* internal structs */
 struct cfg80211_conn;
@@ -3014,14 +3014,14 @@ static inline void *wdev_priv(struct wireless_dev *wdev)
  * @band: band, necessary due to channel number overlap
  * Return: The corresponding frequency (in MHz), or 0 if the conversion failed.
  */
-extern int ieee80211_channel_to_frequency(int chan, enum ieee80211_band band);
+int ieee80211_channel_to_frequency(int chan, enum ieee80211_band band);
 
 /**
  * ieee80211_frequency_to_channel - convert frequency to channel number
  * @freq: center frequency
  * Return: The corresponding channel, or 0 if the conversion failed.
  */
-extern int ieee80211_frequency_to_channel(int freq);
+int ieee80211_frequency_to_channel(int freq);
 
 /*
  * Name indirection necessary because the ieee80211 code also has
@@ -3030,8 +3030,8 @@ extern int ieee80211_frequency_to_channel(int freq);
  * to include both header files you'll (rightfully!) get a symbol
  * clash.
  */
-extern struct ieee80211_channel *__ieee80211_get_channel(struct wiphy *wiphy,
-							 int freq);
+struct ieee80211_channel *__ieee80211_get_channel(struct wiphy *wiphy,
+						  int freq);
 /**
  * ieee80211_get_channel - get channel struct from wiphy for specified frequency
  * @wiphy: the struct wiphy to get the channel for
@@ -3141,13 +3141,14 @@ struct ieee80211_radiotap_iterator {
 	int _reset_on_ext;
 };
 
-extern int ieee80211_radiotap_iterator_init(
-	struct ieee80211_radiotap_iterator *iterator,
-	struct ieee80211_radiotap_header *radiotap_header,
-	int max_length, const struct ieee80211_radiotap_vendor_namespaces *vns);
+int
+ieee80211_radiotap_iterator_init(struct ieee80211_radiotap_iterator *iterator,
+				 struct ieee80211_radiotap_header *radiotap_header,
+				 int max_length,
+				 const struct ieee80211_radiotap_vendor_namespaces *vns);
 
-extern int ieee80211_radiotap_iterator_next(
-	struct ieee80211_radiotap_iterator *iterator);
+int
+ieee80211_radiotap_iterator_next(struct ieee80211_radiotap_iterator *iterator);
 
 
 extern const unsigned char rfc1042_header[6];
@@ -3307,7 +3308,7 @@ const u8 *cfg80211_find_vendor_ie(unsigned int oui, u8 oui_type,
  *
  * Return: 0 on success. -ENOMEM.
  */
-extern int regulatory_hint(struct wiphy *wiphy, const char *alpha2);
+int regulatory_hint(struct wiphy *wiphy, const char *alpha2);
 
 /**
  * wiphy_apply_custom_regulatory - apply a custom driver regulatory domain
@@ -3321,9 +3322,8 @@ extern int regulatory_hint(struct wiphy *wiphy, const char *alpha2);
  * default channel settings will be disregarded. If no rule is found for a
  * channel on the regulatory domain the channel will be disabled.
  */
-extern void wiphy_apply_custom_regulatory(
-	struct wiphy *wiphy,
-	const struct ieee80211_regdomain *regd);
+void wiphy_apply_custom_regulatory(struct wiphy *wiphy,
+				   const struct ieee80211_regdomain *regd);
 
 /**
  * freq_reg_info - get regulatory information for the given frequency
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5b7a3da..e5f0290 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2877,14 +2877,14 @@ enum ieee80211_tpt_led_trigger_flags {
 };
 
 #ifdef CONFIG_MAC80211_LEDS
-extern char *__ieee80211_get_tx_led_name(struct ieee80211_hw *hw);
-extern char *__ieee80211_get_rx_led_name(struct ieee80211_hw *hw);
-extern char *__ieee80211_get_assoc_led_name(struct ieee80211_hw *hw);
-extern char *__ieee80211_get_radio_led_name(struct ieee80211_hw *hw);
-extern char *__ieee80211_create_tpt_led_trigger(
-				struct ieee80211_hw *hw, unsigned int flags,
-				const struct ieee80211_tpt_blink *blink_table,
-				unsigned int blink_table_len);
+char *__ieee80211_get_tx_led_name(struct ieee80211_hw *hw);
+char *__ieee80211_get_rx_led_name(struct ieee80211_hw *hw);
+char *__ieee80211_get_assoc_led_name(struct ieee80211_hw *hw);
+char *__ieee80211_get_radio_led_name(struct ieee80211_hw *hw);
+char *__ieee80211_create_tpt_led_trigger(struct ieee80211_hw *hw,
+					 unsigned int flags,
+					 const struct ieee80211_tpt_blink *blink_table,
+					 unsigned int blink_table_len);
 #endif
 /**
  * ieee80211_get_tx_led_name - get name of TX LED
-- 
1.8.1.2.459.gbcd45b4.dirty
