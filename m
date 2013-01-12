From: Yacine Belkadi <yacine.belkadi.1@gmail.com>
Subject: [PATCH] {cfg,mac}80211.h: fix some kernel-doc warnings
Date: Sat, 12 Jan 2013 13:54:14 +0100
Message-ID: <1357995254-2318-1-git-send-email-yacine.belkadi.1@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yacine Belkadi <yacine.belkadi.1@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building the 80211 DocBook, scripts/kernel-doc reports the following type
of warnings:

Warning(include/net/cfg80211.h:334): No description found for return value of       'cfg80211_get_chandef_type'

These warnings are only reported when scripts/kernel-doc runs in verbose mode.

Fix:
In comments, use "Return:" to describe function return values.

Signed-off-by: Yacine Belkadi <yacine.belkadi.1@gmail.com>
---
 include/net/cfg80211.h |  154 ++++++++++++++++++++++++++++--------------------
 include/net/mac80211.h |   74 ++++++++++++++++++-----
 2 files changed, 151 insertions(+), 77 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 8e6a6b7..9f2f585 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -326,7 +326,7 @@ struct cfg80211_chan_def {
  * cfg80211_get_chandef_type - return old channel type from chandef
  * @chandef: the channel definition
  *
- * Returns the old channel type (NOHT, HT20, HT40+/-) from a given
+ * Return: The old channel type (NOHT, HT20, HT40+/-) from a given
  * chandef, which must have a bandwidth allowing this conversion.
  */
 static inline enum nl80211_channel_type
@@ -364,7 +364,7 @@ void cfg80211_chandef_create(struct cfg80211_chan_def *chandef,
  * @chandef1: first channel definition
  * @chandef2: second channel definition
  *
- * Returns %true if the channels defined by the channel definitions are
+ * Return: %true if the channels defined by the channel definitions are
  * identical, %false otherwise.
  */
 static inline bool
@@ -382,7 +382,7 @@ cfg80211_chandef_identical(const struct cfg80211_chan_def *chandef1,
  * @chandef1: first channel definition
  * @chandef2: second channel definition
  *
- * Returns %NULL if the given channel definitions are incompatible,
+ * Return: %NULL if the given channel definitions are incompatible,
  * chandef1 or chandef2 otherwise.
  */
 const struct cfg80211_chan_def *
@@ -392,6 +392,7 @@ cfg80211_chandef_compatible(const struct cfg80211_chan_def *chandef1,
 /**
  * cfg80211_chandef_valid - check if a channel definition is valid
  * @chandef: the channel definition to check
+ * Return: %true if the channel definition is valid. %false otherwise.
  */
 bool cfg80211_chandef_valid(const struct cfg80211_chan_def *chandef);
 
@@ -399,7 +400,8 @@ bool cfg80211_chandef_valid(const struct cfg80211_chan_def *chandef);
  * cfg80211_chandef_usable - check if secondary channels can be used
  * @wiphy: the wiphy to validate against
  * @chandef: the channel definition to check
- * @prohibited_flags: the regulatory chanenl flags that must not be set
+ * @prohibited_flags: the regulatory channel flags that must not be set
+ * Return: %true if secondary channels are usable. %false otherwise.
  */
 bool cfg80211_chandef_usable(struct wiphy *wiphy,
 			     const struct cfg80211_chan_def *chandef,
@@ -1266,7 +1268,7 @@ struct cfg80211_bss {
  *
  * Note that the return value is an RCU-protected pointer, so
  * rcu_read_lock() must be held when calling this function.
- * Returns %NULL if not found.
+ * Return: %NULL if not found.
  */
 const u8 *ieee80211_bss_get_ie(struct cfg80211_bss *bss, u8 ie);
 
@@ -2409,6 +2411,7 @@ static inline void wiphy_net_set(struct wiphy *wiphy, struct net *net)
  * wiphy_priv - return priv from wiphy
  *
  * @wiphy: the wiphy whose priv pointer to return
+ * Return: The priv of @wiphy.
  */
 static inline void *wiphy_priv(struct wiphy *wiphy)
 {
@@ -2420,6 +2423,7 @@ static inline void *wiphy_priv(struct wiphy *wiphy)
  * priv_to_wiphy - return the wiphy containing the priv
  *
  * @priv: a pointer previously returned by wiphy_priv
+ * Return: The wiphy of @priv.
  */
 static inline struct wiphy *priv_to_wiphy(void *priv)
 {
@@ -2442,6 +2446,7 @@ static inline void set_wiphy_dev(struct wiphy *wiphy, struct device *dev)
  * wiphy_dev - get wiphy dev pointer
  *
  * @wiphy: The wiphy whose device struct to look up
+ * Return: The dev of @wiphy.
  */
 static inline struct device *wiphy_dev(struct wiphy *wiphy)
 {
@@ -2452,6 +2457,7 @@ static inline struct device *wiphy_dev(struct wiphy *wiphy)
  * wiphy_name - get wiphy name
  *
  * @wiphy: The wiphy whose name to return
+ * Return: The name of @wiphy.
  */
 static inline const char *wiphy_name(const struct wiphy *wiphy)
 {
@@ -2467,8 +2473,8 @@ static inline const char *wiphy_name(const struct wiphy *wiphy)
  * Create a new wiphy and associate the given operations with it.
  * @sizeof_priv bytes are allocated for private use.
  *
- * The returned pointer must be assigned to each netdev's
- * ieee80211_ptr for proper operation.
+ * Return: A pointer to the new wiphy. This pointer must be
+ * assigned to each netdev's ieee80211_ptr for proper operation.
  */
 struct wiphy *wiphy_new(const struct cfg80211_ops *ops, int sizeof_priv);
 
@@ -2477,7 +2483,7 @@ struct wiphy *wiphy_new(const struct cfg80211_ops *ops, int sizeof_priv);
  *
  * @wiphy: The wiphy to register.
  *
- * Returns a non-negative wiphy index or a negative error code.
+ * Return: A non-negative wiphy index or a negative error code.
  */
 extern int wiphy_register(struct wiphy *wiphy);
 
@@ -2626,6 +2632,7 @@ static inline u8 *wdev_address(struct wireless_dev *wdev)
  * wdev_priv - return wiphy priv from wireless_dev
  *
  * @wdev: The wireless device whose wiphy's priv pointer to return
+ * Return: The wiphy priv of @wdev.
  */
 static inline void *wdev_priv(struct wireless_dev *wdev)
 {
@@ -2643,12 +2650,14 @@ static inline void *wdev_priv(struct wireless_dev *wdev)
  * ieee80211_channel_to_frequency - convert channel number to frequency
  * @chan: channel number
  * @band: band, necessary due to channel number overlap
+ * Return: The corresponding frequency (in MHz), or 0 if the conversion failed.
  */
 extern int ieee80211_channel_to_frequency(int chan, enum ieee80211_band band);
 
 /**
  * ieee80211_frequency_to_channel - convert frequency to channel number
  * @freq: center frequency
+ * Return: The corresponding channel, or 0 if the conversion failed.
  */
 extern int ieee80211_frequency_to_channel(int freq);
 
@@ -2665,6 +2674,7 @@ extern struct ieee80211_channel *__ieee80211_get_channel(struct wiphy *wiphy,
  * ieee80211_get_channel - get channel struct from wiphy for specified frequency
  * @wiphy: the struct wiphy to get the channel for
  * @freq: the center frequency of the channel
+ * Return: The channel struct from @wiphy at @freq.
  */
 static inline struct ieee80211_channel *
 ieee80211_get_channel(struct wiphy *wiphy, int freq)
@@ -2679,10 +2689,10 @@ ieee80211_get_channel(struct wiphy *wiphy, int freq)
  * @basic_rates: bitmap of basic rates
  * @bitrate: the bitrate for which to find the basic rate
  *
- * This function returns the basic rate corresponding to a given
- * bitrate, that is the next lower bitrate contained in the basic
- * rate map, which is, for this function, given as a bitmap of
- * indices of rates in the band's bitrate table.
+ * Return: The basic rate corresponding to a given bitrate, that
+ * is the next lower bitrate contained in the basic rate map,
+ * which is, for this function, given as a bitmap of indices of
+ * rates in the band's bitrate table.
  */
 struct ieee80211_rate *
 ieee80211_get_response_rate(struct ieee80211_supported_band *sband,
@@ -2775,18 +2785,21 @@ extern const unsigned char bridge_tunnel_header[6];
 /**
  * ieee80211_get_hdrlen_from_skb - get header length from data
  *
+ * @skb: the frame
+ *
  * Given an skb with a raw 802.11 header at the data pointer this function
- * returns the 802.11 header length in bytes (not including encryption
- * headers). If the data in the sk_buff is too short to contain a valid 802.11
- * header the function returns 0.
+ * returns the 802.11 header length.
  *
- * @skb: the frame
+ * Return: The 802.11 header length in bytes (not including encryption
+ * headers). Or 0 if the data in the sk_buff is too short to contain a valid
+ * 802.11 header.
  */
 unsigned int ieee80211_get_hdrlen_from_skb(const struct sk_buff *skb);
 
 /**
  * ieee80211_hdrlen - get header length in bytes from frame control
  * @fc: frame control field in little-endian format
+ * Return: The header length in bytes.
  */
 unsigned int __attribute_const__ ieee80211_hdrlen(__le16 fc);
 
@@ -2794,7 +2807,7 @@ unsigned int __attribute_const__ ieee80211_hdrlen(__le16 fc);
  * ieee80211_get_mesh_hdrlen - get mesh extension header length
  * @meshhdr: the mesh extension header, only the flags field
  *	(first byte) will be accessed
- * Returns the length of the extension header, which is always at
+ * Return: The length of the extension header, which is always at
  * least 6 bytes and at most 18 if address 5 and 6 are present.
  */
 unsigned int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr);
@@ -2812,6 +2825,7 @@ unsigned int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr);
  * @skb: the 802.11 data frame
  * @addr: the device MAC address
  * @iftype: the virtual interface type
+ * Return: 0 on success. Non-zero on error.
  */
 int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 			   enum nl80211_iftype iftype);
@@ -2823,6 +2837,7 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
  * @iftype: the virtual interface type
  * @bssid: the network bssid (used only for iftype STATION and ADHOC)
  * @qos: build 802.11 QoS data frame
+ * Return: 0 on success, or a negative error code.
  */
 int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 			     enum nl80211_iftype iftype, u8 *bssid, bool qos);
@@ -2850,6 +2865,7 @@ void ieee80211_amsdu_to_8023s(struct sk_buff *skb, struct sk_buff_head *list,
 /**
  * cfg80211_classify8021d - determine the 802.1p/1d tag for a data frame
  * @skb: the data frame
+ * Return: The 802.1p/1d tag.
  */
 unsigned int cfg80211_classify8021d(struct sk_buff *skb);
 
@@ -2860,12 +2876,13 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb);
  * @ies: data consisting of IEs
  * @len: length of data
  *
- * This function will return %NULL if the element ID could
- * not be found or if the element is invalid (claims to be
- * longer than the given data), or a pointer to the first byte
- * of the requested element, that is the byte containing the
- * element ID. There are no checks on the element length
- * other than having to fit into the given data.
+ * Return: %NULL if the element ID could not be found or if
+ * the element is invalid (claims to be longer than the given
+ * data), or a pointer to the first byte of the requested
+ * element, that is the byte containing the element ID.
+ *
+ * Note: There are no checks on the element length other than
+ * having to fit into the given data.
  */
 const u8 *cfg80211_find_ie(u8 eid, const u8 *ies, int len);
 
@@ -2877,12 +2894,13 @@ const u8 *cfg80211_find_ie(u8 eid, const u8 *ies, int len);
  * @ies: data consisting of IEs
  * @len: length of data
  *
- * This function will return %NULL if the vendor specific element ID
- * could not be found or if the element is invalid (claims to be
- * longer than the given data), or a pointer to the first byte
- * of the requested element, that is the byte containing the
- * element ID. There are no checks on the element length
- * other than having to fit into the given data.
+ * Return: %NULL if the vendor specific element ID could not be found or if the
+ * element is invalid (claims to be longer than the given data), or a pointer to
+ * the first byte of the requested element, that is the byte containing the
+ * element ID.
+ *
+ * Note: There are no checks on the element length other than having to fit into
+ * the given data.
  */
 const u8 *cfg80211_find_vendor_ie(unsigned int oui, u8 oui_type,
 				  const u8 *ies, int len);
@@ -2915,6 +2933,8 @@ const u8 *cfg80211_find_vendor_ie(unsigned int oui, u8 oui_type,
  *
  * Drivers should check the return value, its possible you can get
  * an -ENOMEM.
+ *
+ * Return: 0 on success. -ENOMEM.
  */
 extern int regulatory_hint(struct wiphy *wiphy, const char *alpha2);
 
@@ -2949,12 +2969,13 @@ extern void wiphy_apply_custom_regulatory(
  * it wants to follow we respect that unless a country IE has been received
  * and processed already.
  *
- * Returns 0 if it was able to find a valid regulatory rule which does
- * apply to the given center_freq otherwise it returns non-zero. It will
- * also return -ERANGE if we determine the given center_freq does not even have
- * a regulatory rule for a frequency range in the center_freq's band. See
+ * Return: 0 if it was able to find a valid regulatory rule which does apply
+ * to the given center_freq.
+ * -ERANGE if we determine the given center_freq does not even have a
+ * regulatory rule for a frequency range in the center_freq's band. See
  * freq_in_rule_band() for our current definition of a band -- this is purely
  * subjective and right now its 802.11 specific.
+ * Non-zero otherwise.
  */
 extern int freq_reg_info(struct wiphy *wiphy,
 			 u32 center_freq,
@@ -3006,7 +3027,8 @@ void cfg80211_sched_scan_stopped(struct wiphy *wiphy);
  * This informs cfg80211 that BSS information was found and
  * the BSS should be updated/added.
  *
- * NOTE: Returns a referenced struct, must be released with cfg80211_put_bss()!
+ * Return: A referenced struct, must be released with cfg80211_put_bss()!
+ * Or %NULL on error.
  */
 struct cfg80211_bss * __must_check
 cfg80211_inform_bss_frame(struct wiphy *wiphy,
@@ -3031,7 +3053,8 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
  * This informs cfg80211 that BSS information was found and
  * the BSS should be updated/added.
  *
- * NOTE: Returns a referenced struct, must be released with cfg80211_put_bss()!
+ * Return: A referenced struct, must be released with cfg80211_put_bss()!
+ * Or %NULL on error.
  */
 struct cfg80211_bss * __must_check
 cfg80211_inform_bss(struct wiphy *wiphy,
@@ -3308,16 +3331,18 @@ void wiphy_rfkill_stop_polling(struct wiphy *wiphy);
  * the testmode command. Since it is intended for a reply, calling
  * it outside of the @testmode_cmd operation is invalid.
  *
- * The returned skb (or %NULL if any errors happen) is pre-filled
- * with the wiphy index and set up in a way that any data that is
- * put into the skb (with skb_put(), nla_put() or similar) will end
- * up being within the %NL80211_ATTR_TESTDATA attribute, so all that
- * needs to be done with the skb is adding data for the corresponding
- * userspace tool which can then read that data out of the testdata
- * attribute. You must not modify the skb in any other way.
+ * The returned skb is pre-filled with the wiphy index and set up in
+ * a way that any data that is put into the skb (with skb_put(),
+ * nla_put() or similar) will end up being within the
+ * %NL80211_ATTR_TESTDATA attribute, so all that needs to be done
+ * with the skb is adding data for the corresponding userspace tool
+ * which can then read that data out of the testdata attribute. You
+ * must not modify the skb in any other way.
  *
  * When done, call cfg80211_testmode_reply() with the skb and return
  * its error code as the result of the @testmode_cmd operation.
+ *
+ * Return: An allocated and pre-filled skb. %NULL if any errors happen.
  */
 struct sk_buff *cfg80211_testmode_alloc_reply_skb(struct wiphy *wiphy,
 						  int approxlen);
@@ -3327,11 +3352,12 @@ struct sk_buff *cfg80211_testmode_alloc_reply_skb(struct wiphy *wiphy,
  * @skb: The skb, must have been allocated with
  *	cfg80211_testmode_alloc_reply_skb()
  *
- * Returns an error code or 0 on success, since calling this
- * function will usually be the last thing before returning
- * from the @testmode_cmd you should return the error code.
- * Note that this function consumes the skb regardless of the
- * return value.
+ * Since calling this function will usually be the last thing
+ * before returning from the @testmode_cmd you should return
+ * the error code.  Note that this function consumes the skb
+ * regardless of the return value.
+ *
+ * Return: An error code or 0 on success.
  */
 int cfg80211_testmode_reply(struct sk_buff *skb);
 
@@ -3345,14 +3371,16 @@ int cfg80211_testmode_reply(struct sk_buff *skb);
  * This function allocates and pre-fills an skb for an event on the
  * testmode multicast group.
  *
- * The returned skb (or %NULL if any errors happen) is set up in the
- * same way as with cfg80211_testmode_alloc_reply_skb() but prepared
- * for an event. As there, you should simply add data to it that will
- * then end up in the %NL80211_ATTR_TESTDATA attribute. Again, you must
- * not modify the skb in any other way.
+ * The returned skb is set up in the same way as with
+ * cfg80211_testmode_alloc_reply_skb() but prepared for an event. As
+ * there, you should simply add data to it that will then end up in the
+ * %NL80211_ATTR_TESTDATA attribute. Again, you must not modify the skb
+ * in any other way.
  *
  * When done filling the skb, call cfg80211_testmode_event() with the
  * skb to send the event.
+ *
+ * Return: An allocated and pre-filled skb. %NULL if any errors happen.
  */
 struct sk_buff *cfg80211_testmode_alloc_event_skb(struct wiphy *wiphy,
 						  int approxlen, gfp_t gfp);
@@ -3533,13 +3561,13 @@ void cfg80211_conn_failed(struct net_device *dev, const u8 *mac_addr,
  * @len: length of the frame data
  * @gfp: context flags
  *
- * Returns %true if a user space application has registered for this frame.
+ * This function is called whenever an Action frame is received for a station
+ * mode interface, but is not processed in kernel.
+ *
+ * Return: %true if a user space application has registered for this frame.
  * For action frames, that makes it responsible for rejecting unrecognized
  * action frames; %false otherwise, in which case for action frames the
  * driver is responsible for rejecting the frame.
- *
- * This function is called whenever an Action frame is received for a station
- * mode interface, but is not processed in kernel.
  */
 bool cfg80211_rx_mgmt(struct wireless_dev *wdev, int freq, int sig_dbm,
 		      const u8 *buf, size_t len, gfp_t gfp);
@@ -3631,7 +3659,7 @@ void cfg80211_pmksa_candidate_notify(struct net_device *dev, int index,
  * This function is used in AP mode (only!) to inform userspace that
  * a spurious class 3 frame was received, to be able to deauth the
  * sender.
- * Returns %true if the frame was passed to userspace (or this failed
+ * Return: %true if the frame was passed to userspace (or this failed
  * for a reason other than not having a subscription.)
  */
 bool cfg80211_rx_spurious_frame(struct net_device *dev,
@@ -3647,7 +3675,7 @@ bool cfg80211_rx_spurious_frame(struct net_device *dev,
  * an associated station sent a 4addr frame but that wasn't expected.
  * It is allowed and desirable to send this event only once for each
  * station to avoid event flooding.
- * Returns %true if the frame was passed to userspace (or this failed
+ * Return: %true if the frame was passed to userspace (or this failed
  * for a reason other than not having a subscription.)
  */
 bool cfg80211_rx_unexpected_4addr_frame(struct net_device *dev,
@@ -3685,8 +3713,8 @@ void cfg80211_report_obss_beacon(struct wiphy *wiphy,
  * @wiphy: the wiphy
  * @chandef: the channel definition
  *
- * This function returns true if there is no secondary channel or the secondary
- * channel(s) can be used for beaconing (i.e. is not a radar channel etc.)
+ * Return: %true if there is no secondary channel or the secondary channel(s)
+ * can be used for beaconing (i.e. is not a radar channel etc.)
  */
 bool cfg80211_reg_can_beacon(struct wiphy *wiphy,
 			     struct cfg80211_chan_def *chandef);
@@ -3756,9 +3784,9 @@ void cfg80211_unregister_wdev(struct wireless_dev *wdev);
  * The function finds a given P2P attribute in the (vendor) IEs and
  * copies its contents to the given buffer.
  *
- * The return value is a negative error code (-%EILSEQ or -%ENOENT) if
- * the data is malformed or the attribute can't be found (respectively),
- * or the length of the found attribute (which can be zero).
+ * Return: A negative error code (-%EILSEQ or -%ENOENT) if the data is
+ * malformed or the attribute can't be found (respectively), or the
+ * length of the found attribute (which can be zero).
  */
 int cfg80211_get_p2p_attr(const u8 *ies, unsigned int len,
 			  enum ieee80211_p2p_attr_id attr,
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index ee50c5e..dbea2ec 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1522,6 +1522,8 @@ struct ieee80211_hw {
  * structure can then access it via hw->priv. Note that mac802111 drivers should
  * not use wiphy_priv() to try to get their private driver structure as this
  * is already used internally by mac80211.
+ *
+ * Return: The mac80211 driver hw struct of @wiphy.
  */
 struct ieee80211_hw *wiphy_to_ieee80211_hw(struct wiphy *wiphy);
 
@@ -2661,6 +2663,8 @@ struct ieee80211_ops {
  *
  * @priv_data_len: length of private data
  * @ops: callbacks for this device
+ *
+ * Return: A pointer to the new hardware device, or %NULL on error.
  */
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 					const struct ieee80211_ops *ops);
@@ -2673,6 +2677,8 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
  * need to fill the contained wiphy's information.
  *
  * @hw: the device to register as returned by ieee80211_alloc_hw()
+ *
+ * Return: 0 on success. An error code otherwise.
  */
 int ieee80211_register_hw(struct ieee80211_hw *hw);
 
@@ -2719,6 +2725,8 @@ extern char *__ieee80211_create_tpt_led_trigger(
  * of the trigger so you can automatically link the LED device.
  *
  * @hw: the hardware to get the LED trigger name for
+ *
+ * Return: The name of the LED trigger. %NULL if not configured for LEDs.
  */
 static inline char *ieee80211_get_tx_led_name(struct ieee80211_hw *hw)
 {
@@ -2738,6 +2746,8 @@ static inline char *ieee80211_get_tx_led_name(struct ieee80211_hw *hw)
  * of the trigger so you can automatically link the LED device.
  *
  * @hw: the hardware to get the LED trigger name for
+ *
+ * Return: The name of the LED trigger. %NULL if not configured for LEDs.
  */
 static inline char *ieee80211_get_rx_led_name(struct ieee80211_hw *hw)
 {
@@ -2757,6 +2767,8 @@ static inline char *ieee80211_get_rx_led_name(struct ieee80211_hw *hw)
  * of the trigger so you can automatically link the LED device.
  *
  * @hw: the hardware to get the LED trigger name for
+ *
+ * Return: The name of the LED trigger. %NULL if not configured for LEDs.
  */
 static inline char *ieee80211_get_assoc_led_name(struct ieee80211_hw *hw)
 {
@@ -2776,6 +2788,8 @@ static inline char *ieee80211_get_assoc_led_name(struct ieee80211_hw *hw)
  * of the trigger so you can automatically link the LED device.
  *
  * @hw: the hardware to get the LED trigger name for
+ *
+ * Return: The name of the LED trigger. %NULL if not configured for LEDs.
  */
 static inline char *ieee80211_get_radio_led_name(struct ieee80211_hw *hw)
 {
@@ -2793,9 +2807,10 @@ static inline char *ieee80211_get_radio_led_name(struct ieee80211_hw *hw)
  * @blink_table: the blink table -- needs to be ordered by throughput
  * @blink_table_len: size of the blink table
  *
- * This function returns %NULL (in case of error, or if no LED
- * triggers are configured) or the name of the new trigger.
- * This function must be called before ieee80211_register_hw().
+ * Return: %NULL (in case of error, or if no LED triggers are
+ * configured) or the name of the new trigger.
+ *
+ * Note: This function must be called before ieee80211_register_hw().
  */
 static inline char *
 ieee80211_create_tpt_led_trigger(struct ieee80211_hw *hw, unsigned int flags,
@@ -2928,10 +2943,10 @@ static inline void ieee80211_rx_ni(struct ieee80211_hw *hw,
  * Calls to this function for a single hardware must be synchronized against
  * each other.
  *
- * The function returns -EINVAL when the requested PS mode is already set.
- *
  * @sta: currently connected sta
  * @start: start or stop PS
+ *
+ * Return: 0 on success. -EINVAL when the requested PS mode is already set.
  */
 int ieee80211_sta_ps_transition(struct ieee80211_sta *sta, bool start);
 
@@ -2945,6 +2960,8 @@ int ieee80211_sta_ps_transition(struct ieee80211_sta *sta, bool start);
  *
  * @sta: currently connected sta
  * @start: start or stop PS
+ *
+ * Return: Like ieee80211_sta_ps_transition().
  */
 static inline int ieee80211_sta_ps_transition_ni(struct ieee80211_sta *sta,
 						  bool start)
@@ -3082,6 +3099,8 @@ void ieee80211_report_low_ack(struct ieee80211_sta *sta, u32 num_packets);
  * according to the current DTIM parameters/TIM bitmap.
  *
  * The driver is responsible for freeing the returned skb.
+ *
+ * Return: The beacon template. %NULL on error.
  */
 struct sk_buff *ieee80211_beacon_get_tim(struct ieee80211_hw *hw,
 					 struct ieee80211_vif *vif,
@@ -3093,6 +3112,8 @@ struct sk_buff *ieee80211_beacon_get_tim(struct ieee80211_hw *hw,
  * @vif: &struct ieee80211_vif pointer from the add_interface callback.
  *
  * See ieee80211_beacon_get_tim().
+ *
+ * Return: See ieee80211_beacon_get_tim().
  */
 static inline struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
 						   struct ieee80211_vif *vif)
@@ -3109,6 +3130,8 @@ static inline struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
  * hardware. The destination address should be set by the caller.
  *
  * Can only be called in AP mode.
+ *
+ * Return: The Probe Response template. %NULL on error.
  */
 struct sk_buff *ieee80211_proberesp_get(struct ieee80211_hw *hw,
 					struct ieee80211_vif *vif);
@@ -3124,6 +3147,8 @@ struct sk_buff *ieee80211_proberesp_get(struct ieee80211_hw *hw,
  *
  * Note: Caller (or hardware) is responsible for setting the
  * &IEEE80211_FCTL_PM bit.
+ *
+ * Return: The PS Poll template. %NULL on error.
  */
 struct sk_buff *ieee80211_pspoll_get(struct ieee80211_hw *hw,
 				     struct ieee80211_vif *vif);
@@ -3139,6 +3164,8 @@ struct sk_buff *ieee80211_pspoll_get(struct ieee80211_hw *hw,
  *
  * Note: Caller (or hardware) is responsible for setting the
  * &IEEE80211_FCTL_PM bit as well as Duration and Sequence Control fields.
+ *
+ * Return: The nullfunc template. %NULL on error.
  */
 struct sk_buff *ieee80211_nullfunc_get(struct ieee80211_hw *hw,
 				       struct ieee80211_vif *vif);
@@ -3153,6 +3180,8 @@ struct sk_buff *ieee80211_nullfunc_get(struct ieee80211_hw *hw,
  *
  * Creates a Probe Request template which can, for example, be uploaded to
  * hardware.
+ *
+ * Return: The Probe Request template. %NULL on error.
  */
 struct sk_buff *ieee80211_probereq_get(struct ieee80211_hw *hw,
 				       struct ieee80211_vif *vif,
@@ -3188,6 +3217,8 @@ void ieee80211_rts_get(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
  * If the RTS is generated in firmware, but the host system must provide
  * the duration field, the low-level driver uses this function to receive
  * the duration field value in little-endian byteorder.
+ *
+ * Return: The duration.
  */
 __le16 ieee80211_rts_duration(struct ieee80211_hw *hw,
 			      struct ieee80211_vif *vif, size_t frame_len,
@@ -3223,6 +3254,8 @@ void ieee80211_ctstoself_get(struct ieee80211_hw *hw,
  * If the CTS-to-self is generated in firmware, but the host system must provide
  * the duration field, the low-level driver uses this function to receive
  * the duration field value in little-endian byteorder.
+ *
+ * Return: The duration.
  */
 __le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw,
 				    struct ieee80211_vif *vif,
@@ -3239,6 +3272,8 @@ __le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw,
  *
  * Calculate the duration field of some generic frame, given its
  * length and transmission rate (in 100kbps).
+ *
+ * Return: The duration.
  */
 __le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw,
 					struct ieee80211_vif *vif,
@@ -3255,9 +3290,10 @@ __le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw,
  * hardware/firmware does not implement buffering of broadcast/multicast
  * frames when power saving is used, 802.11 code buffers them in the host
  * memory. The low-level driver uses this function to fetch next buffered
- * frame. In most cases, this is used when generating beacon frame. This
- * function returns a pointer to the next buffered skb or NULL if no more
- * buffered frames are available.
+ * frame. In most cases, this is used when generating beacon frame.
+ *
+ * Return: A pointer to the next buffered skb or NULL if no more buffered
+ * frames are available.
  *
  * Note: buffered frames are returned only after DTIM beacon frame was
  * generated with ieee80211_beacon_get() and the low-level driver must thus
@@ -3437,6 +3473,8 @@ void ieee80211_stop_queue(struct ieee80211_hw *hw, int queue);
  * @queue: queue number (counted from zero).
  *
  * Drivers should use this function instead of netif_stop_queue.
+ *
+ * Return: %true if the queue is stopped. %false otherwise.
  */
 
 int ieee80211_queue_stopped(struct ieee80211_hw *hw, int queue);
@@ -3634,7 +3672,9 @@ void ieee80211_stop_tx_ba_cb_irqsafe(struct ieee80211_vif *vif, const u8 *ra,
  * @vif: virtual interface to look for station on
  * @addr: station's address
  *
- * This function must be called under RCU lock and the
+ * Return: The station, if found. %NULL otherwise.
+ *
+ * Note: This function must be called under RCU lock and the
  * resulting pointer is only valid under RCU lock as well.
  */
 struct ieee80211_sta *ieee80211_find_sta(struct ieee80211_vif *vif,
@@ -3647,7 +3687,9 @@ struct ieee80211_sta *ieee80211_find_sta(struct ieee80211_vif *vif,
  * @addr: remote station's address
  * @localaddr: local address (vif->sdata->vif.addr). Use NULL for 'any'.
  *
- * This function must be called under RCU lock and the
+ * Return: The station, if found. %NULL otherwise.
+ *
+ * Note: This function must be called under RCU lock and the
  * resulting pointer is only valid under RCU lock as well.
  *
  * NOTE: You may pass NULL for localaddr, but then you will just get
@@ -3772,7 +3814,9 @@ void ieee80211_iter_chan_contexts_atomic(
  * information. This function must only be called from within the
  * .bss_info_changed callback function and only in managed mode. The function
  * is only useful when the interface is associated, otherwise it will return
- * NULL.
+ * %NULL.
+ *
+ * Return: The Probe Request template. %NULL on error.
  */
 struct sk_buff *ieee80211_ap_probereq_get(struct ieee80211_hw *hw,
 					  struct ieee80211_vif *vif);
@@ -4119,12 +4163,14 @@ void ieee80211_enable_rssi_reports(struct ieee80211_vif *vif,
 void ieee80211_disable_rssi_reports(struct ieee80211_vif *vif);
 
 /**
- * ieee80211_ave_rssi - report the average rssi for the specified interface
+ * ieee80211_ave_rssi - report the average RSSI for the specified interface
  *
  * @vif: the specified virtual interface
  *
- * This function return the average rssi value for the requested interface.
- * It assumes that the given vif is valid.
+ * Note: This function assumes that the given vif is valid.
+ *
+ * Return: The average RSSI value for the requested interface, or 0 if not
+ * applicable.
  */
 int ieee80211_ave_rssi(struct ieee80211_vif *vif);
 
-- 
1.7.9.5

