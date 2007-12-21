From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: (2nd attempt) Please pull 'upstream-davem' branch of wireless-2.6
Date: Fri, 21 Dec 2007 09:05:27 -0500
Message-ID: <20071221140527.GA19874@tuxdriver.com>
References: <20071220155321.GF3139@tuxdriver.com> <20071220223850.GL3139@tuxdriver.com> <20071220.200429.242105762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071220.200429.242105762.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 20, 2007 at 08:04:29PM -0800, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Thu, 20 Dec 2007 17:38:50 -0500
> 
> > On Thu, Dec 20, 2007 at 10:53:21AM -0500, John W. Linville wrote:
> > 
> > > These are destined for 2.6.25.  The patches fall mostly into two
> > > categories: a new rate control algorithm for mac80211, and some
> > > cfg80211 enhancements (including mac80211 patches to use them).
> > 
> > >       mac80211: make PID rate control algorithm the default
> > 
> > This patch is busted.  I was mistaken about its readiness --
> > I apologize.  Don't pull if you haven't already.
> > 
> > We are actively working on fixing/replacing it.
> > 
> > Thanks for your patience!
> 
> No worries, let me know when there is a new tree to pull from.

[ This is the 2nd attempt, with the botched rate control selection patch
  revised and thoroughly tested... ]

Dave,

These are destined for 2.6.25.  The patches fall mostly into two
categories: a new rate control algorithm for mac80211, and some
cfg80211 enhancements (including mac80211 patches to use them).

Also there are some small hits in the iwlwifi drivers related to
rate control.  I'll CC Jeff since his tree has a lot of iwlwifi symbol
renames and those patches will conflict (or break the build, or both)
when your tree and his finally come together.

Let me know if there are any problems!

John

P.S.  I have a few more related to the cfg80211 changes, but the
patches are cross-dependent on both your tree and Jeff's.  I will
probably send those to akpm in the meantime, and push them after
Linus has pulled both your tree and Jeff's in the 2.6.25 merge window.

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

---

The following changes since commit adc292d3280278282d7b0e0813ccda711e739b5f:
  Herbert Xu (1):
        [IPSEC]: Do xfrm_state_check_space before encapsulation

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem ..BRANCH.NOT.VERIFIED..

Johannes Berg (13):
      mac80211: clean up eapol frame handling/port control
      mac80211: clean up eapol handling in TX path
      mac80211: make ieee80211_rx_mgmt_action static
      mac80211: allow easier multicast/broadcast buffering in hardware
      cfg80211/nl80211: introduce key handling
      mac80211: support adding/removing keys via cfg80211
      mac80211: support getting key sequence counters via cfg80211
      cfg80211/nl80211: add beacon settings
      cfg80211/nl80211: station handling
      cfg80211/nl80211: implement station attribute retrieval
      mac80211: implement station stats retrieval
      mac80211: move tx crypto decision
      mac80211: don't read ERP information from (re)association response

John W. Linville (2):
      net/wireless/Kconfig: whitespace corrections
      net/mac80211/Kconfig: whitespace corrections

Mattias Nissler (4):
      mac80211: clean up rate selection
      mac80211: add PID controller based rate control algorithm
      rc80211-pid: add debugging
      rc80211-pid: export tuning parameters through debugfs

Ron Rindjunsky (1):
      mac80211: pass in PS_POLL frames

Stefano Brivio (4):
      mac80211: make PID rate control algorithm the default
      rc80211-pid: add rate behaviour learning algorithm
      rc80211-pid: add sharpening factor
      doc: fix typo in feature-removal-schedule

 Documentation/feature-removal-schedule.txt |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c |   44 +--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c |   46 +--
 include/linux/nl80211.h                    |  154 ++++++
 include/net/cfg80211.h                     |  167 +++++++
 include/net/mac80211.h                     |   17 +-
 net/mac80211/Kconfig                       |   98 +++-
 net/mac80211/Makefile                      |   12 +-
 net/mac80211/cfg.c                         |  202 ++++++++-
 net/mac80211/debugfs_netdev.c              |   27 +-
 net/mac80211/ieee80211.c                   |   39 +-
 net/mac80211/ieee80211_i.h                 |   24 +-
 net/mac80211/ieee80211_iface.c             |    1 -
 net/mac80211/ieee80211_rate.c              |   71 +++-
 net/mac80211/ieee80211_rate.h              |   76 ++-
 net/mac80211/ieee80211_sta.c               |   35 +-
 net/mac80211/rc80211_pid.h                 |  261 ++++++++++
 net/mac80211/rc80211_pid_algo.c            |  510 +++++++++++++++++++
 net/mac80211/rc80211_pid_debugfs.c         |  223 +++++++++
 net/mac80211/rc80211_simple.c              |   64 +--
 net/mac80211/rx.c                          |  144 +++---
 net/mac80211/tx.c                          |  171 ++++---
 net/mac80211/util.c                        |   24 +-
 net/mac80211/wep.c                         |   10 -
 net/mac80211/wpa.c                         |   14 -
 net/wireless/Kconfig                       |   10 +-
 net/wireless/core.c                        |    3 +
 net/wireless/nl80211.c                     |  737 ++++++++++++++++++++++++++++
 28 files changed, 2748 insertions(+), 446 deletions(-)
 create mode 100644 net/mac80211/rc80211_pid.h
 create mode 100644 net/mac80211/rc80211_pid_algo.c
 create mode 100644 net/mac80211/rc80211_pid_debugfs.c

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index c9c3603..0ae682b 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -334,10 +334,18 @@ Who:	John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
 
 ---------------------------
 
-What:	iee80211 softmac wireless networking component
+What:	ieee80211 softmac wireless networking component
 When:	2.6.26 (or after removal of bcm43xx and port of zd1211rw to mac80211)
 Files:	net/ieee80211/softmac
 Why:	No in-kernel drivers will depend on it any longer.
 Who:	John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
 
 ---------------------------
+
+What:	rc80211-simple rate control algorithm for mac80211
+When:	2.6.26
+Files:	net/mac80211/rc80211-simple.c
+Why:	This algorithm was provided for reference but always exhibited bad
+	responsiveness and performance and has some serious flaws. It has been
+	replaced by rc80211-pid.
+Who:	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index c48b1b5..ea7f459 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -562,22 +562,6 @@ static void rs_tx_status(void *priv_rate,
 	return;
 }
 
-static struct ieee80211_rate *iwl_get_lowest_rate(struct ieee80211_local
-						  *local)
-{
-	struct ieee80211_hw_mode *mode = local->oper_hw_mode;
-	int i;
-
-	for (i = 0; i < mode->num_rates; i++) {
-		struct ieee80211_rate *rate = &mode->rates[i];
-
-		if (rate->flags & IEEE80211_RATE_SUPPORTED)
-			return rate;
-	}
-
-	return &mode->rates[0];
-}
-
 static u16 iwl_get_adjacent_rate(struct iwl_rate_scale_priv *rs_priv,
 				 u8 index, u16 rate_mask, int phymode)
 {
@@ -656,10 +640,9 @@ static u16 iwl_get_adjacent_rate(struct iwl_rate_scale_priv *rs_priv,
  * rate table and must reference the driver allocated rate table
  *
  */
-static struct ieee80211_rate *rs_get_rate(void *priv_rate,
-					  struct net_device *dev,
-					  struct sk_buff *skb,
-					  struct rate_control_extra *extra)
+static void rs_get_rate(void *priv_rate, struct net_device *dev,
+			struct ieee80211_hw_mode *mode, struct sk_buff *skb,
+			struct rate_selection *sel)
 {
 	u8 low = IWL_RATE_INVALID;
 	u8 high = IWL_RATE_INVALID;
@@ -676,32 +659,19 @@ static struct ieee80211_rate *rs_get_rate(void *priv_rate,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct sta_info *sta;
-	u16 fc, rate_mask;
+	u16 rate_mask;
 	struct iwl_priv *priv = (struct iwl_priv *)priv_rate;
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_RATE("enter\n");
 
-	memset(extra, 0, sizeof(*extra));
-
-	fc = le16_to_cpu(hdr->frame_control);
-	if (((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA) ||
-	    (is_multicast_ether_addr(hdr->addr1))) {
-		/* Send management frames and broadcast/multicast data using
-		 * lowest rate. */
-		/* TODO: this could probably be improved.. */
-		IWL_DEBUG_RATE("leave: lowest rate (not data or is "
-			       "multicast)\n");
-
-		return iwl_get_lowest_rate(local);
-	}
-
 	sta = sta_info_get(local, hdr->addr1);
 	if (!sta || !sta->rate_ctrl_priv) {
 		IWL_DEBUG_RATE("leave: No STA priv data to update!\n");
+		sel->rate = rate_lowest(local, local->oper_hw_mode, sta);
 		if (sta)
 			sta_info_put(sta);
-		return NULL;
+		return;
 	}
 
 	rate_mask = sta->supp_rates;
@@ -846,7 +816,7 @@ static struct ieee80211_rate *rs_get_rate(void *priv_rate,
 
 	IWL_DEBUG_RATE("leave: %d\n", index);
 
-	return &priv->ieee_rates[index];
+	sel->rate = &priv->ieee_rates[index];
 }
 
 static struct rate_control_ops rs_ops = {
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
index 8dc78c0..62a3b52 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
@@ -1693,55 +1693,27 @@ static void rs_initialize_lq(struct iwl_priv *priv,
 	return;
 }
 
-static struct ieee80211_rate *rs_get_lowest_rate(struct ieee80211_local
-						 *local)
-{
-	struct ieee80211_hw_mode *mode = local->oper_hw_mode;
-	int i;
-
-	for (i = 0; i < mode->num_rates; i++) {
-		struct ieee80211_rate *rate = &mode->rates[i];
-
-		if (rate->flags & IEEE80211_RATE_SUPPORTED)
-			return rate;
-	}
-
-	return &mode->rates[0];
-}
-
-static struct ieee80211_rate *rs_get_rate(void *priv_rate,
-					       struct net_device *dev,
-					       struct sk_buff *skb,
-					       struct rate_control_extra
-					       *extra)
+static void rs_get_rate(void *priv_rate, struct net_device *dev,
+			struct ieee80211_hw_mode *mode, struct sk_buff *skb,
+			struct rate_selection *sel)
 {
 
 	int i;
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct sta_info *sta;
-	u16 fc;
 	struct iwl_priv *priv = (struct iwl_priv *)priv_rate;
 	struct iwl_rate_scale_priv *lq;
 
 	IWL_DEBUG_RATE_LIMIT("rate scale calculate new rate for skb\n");
 
-	memset(extra, 0, sizeof(*extra));
-
-	fc = le16_to_cpu(hdr->frame_control);
-	if (!ieee80211_is_data(fc) || is_multicast_ether_addr(hdr->addr1)) {
-		/* Send management frames and broadcast/multicast data using
-		 * lowest rate. */
-		/* TODO: this could probably be improved.. */
-		return rs_get_lowest_rate(local);
-	}
-
 	sta = sta_info_get(local, hdr->addr1);
 
 	if (!sta || !sta->rate_ctrl_priv) {
+		sel->rate = rate_lowest(local, local->oper_hw_mode, sta);
 		if (sta)
 			sta_info_put(sta);
-		return rs_get_lowest_rate(local);
+		return;
 	}
 
 	lq = (struct iwl_rate_scale_priv *)sta->rate_ctrl_priv;
@@ -1768,11 +1740,13 @@ static struct ieee80211_rate *rs_get_rate(void *priv_rate,
 	}
 
  done:
+	if ((i < 0) || (i > IWL_RATE_COUNT)) {
+		sel->rate = rate_lowest(local, local->oper_hw_mode, sta);
+		return;
+	}
 	sta_info_put(sta);
-	if ((i < 0) || (i > IWL_RATE_COUNT))
-		return rs_get_lowest_rate(local);
 
-	return &priv->ieee_rates[i];
+	sel->rate = &priv->ieee_rates[i];
 }
 
 static void *rs_alloc_sta(void *priv, gfp_t gfp)
diff --git a/include/linux/nl80211.h b/include/linux/nl80211.h
index 538ee1d..9fecf90 100644
--- a/include/linux/nl80211.h
+++ b/include/linux/nl80211.h
@@ -7,6 +7,18 @@
  */
 
 /**
+ * DOC: Station handling
+ *
+ * Stations are added per interface, but a special case exists with VLAN
+ * interfaces. When a station is bound to an AP interface, it may be moved
+ * into a VLAN identified by a VLAN interface index (%NL80211_ATTR_STA_VLAN).
+ * The station is still assumed to belong to the AP interface it was added
+ * to.
+ *
+ * TODO: need more info?
+ */
+
+/**
  * enum nl80211_commands - supported nl80211 commands
  *
  * @NL80211_CMD_UNSPEC: unspecified command to catch errors
@@ -37,6 +49,35 @@
  *	userspace to request deletion of a virtual interface, then requires
  *	attribute %NL80211_ATTR_IFINDEX.
  *
+ * @NL80211_CMD_GET_KEY: Get sequence counter information for a key specified
+ *	by %NL80211_ATTR_KEY_IDX and/or %NL80211_ATTR_MAC.
+ * @NL80211_CMD_SET_KEY: Set key attributes %NL80211_ATTR_KEY_DEFAULT or
+ *	%NL80211_ATTR_KEY_THRESHOLD.
+ * @NL80211_CMD_NEW_KEY: add a key with given %NL80211_ATTR_KEY_DATA,
+ *	%NL80211_ATTR_KEY_IDX, %NL80211_ATTR_MAC and %NL80211_ATTR_KEY_CIPHER
+ *	attributes.
+ * @NL80211_CMD_DEL_KEY: delete a key identified by %NL80211_ATTR_KEY_IDX
+ *	or %NL80211_ATTR_MAC.
+ *
+ * @NL80211_CMD_GET_BEACON: retrieve beacon information (returned in a
+ *	%NL80222_CMD_NEW_BEACON message)
+ * @NL80211_CMD_SET_BEACON: set the beacon on an access point interface
+ *	using the %NL80211_ATTR_BEACON_INTERVAL, %NL80211_ATTR_DTIM_PERIOD,
+ *	%NL80211_BEACON_HEAD and %NL80211_BEACON_TAIL attributes.
+ * @NL80211_CMD_NEW_BEACON: add a new beacon to an access point interface,
+ *	parameters are like for %NL80211_CMD_SET_BEACON.
+ * @NL80211_CMD_DEL_BEACON: remove the beacon, stop sending it
+ *
+ * @NL80211_CMD_GET_STATION: Get station attributes for station identified by
+ *	%NL80211_ATTR_MAC on the interface identified by %NL80211_ATTR_IFINDEX.
+ * @NL80211_CMD_SET_STATION: Set station attributes for station identified by
+ *	%NL80211_ATTR_MAC on the interface identified by %NL80211_ATTR_IFINDEX.
+ * @NL80211_CMD_NEW_STATION: Add a station with given attributes to the
+ *	the interface identified by %NL80211_ATTR_IFINDEX.
+ * @NL80211_CMD_DEL_STATION: Remove a station identified by %NL80211_ATTR_MAC
+ *	or, if no MAC address given, all stations, on the interface identified
+ *	by %NL80211_ATTR_IFINDEX.
+ *
  * @NL80211_CMD_MAX: highest used command number
  * @__NL80211_CMD_AFTER_LAST: internal use
  */
@@ -54,6 +95,21 @@ enum nl80211_commands {
 	NL80211_CMD_NEW_INTERFACE,
 	NL80211_CMD_DEL_INTERFACE,
 
+	NL80211_CMD_GET_KEY,
+	NL80211_CMD_SET_KEY,
+	NL80211_CMD_NEW_KEY,
+	NL80211_CMD_DEL_KEY,
+
+	NL80211_CMD_GET_BEACON,
+	NL80211_CMD_SET_BEACON,
+	NL80211_CMD_NEW_BEACON,
+	NL80211_CMD_DEL_BEACON,
+
+	NL80211_CMD_GET_STATION,
+	NL80211_CMD_SET_STATION,
+	NL80211_CMD_NEW_STATION,
+	NL80211_CMD_DEL_STATION,
+
 	/* add commands here */
 
 	/* used to define NL80211_CMD_MAX below */
@@ -75,6 +131,36 @@ enum nl80211_commands {
  * @NL80211_ATTR_IFNAME: network interface name
  * @NL80211_ATTR_IFTYPE: type of virtual interface, see &enum nl80211_iftype
  *
+ * @NL80211_ATTR_MAC: MAC address (various uses)
+ *
+ * @NL80211_ATTR_KEY_DATA: (temporal) key data; for TKIP this consists of
+ *	16 bytes encryption key followed by 8 bytes each for TX and RX MIC
+ *	keys
+ * @NL80211_ATTR_KEY_IDX: key ID (u8, 0-3)
+ * @NL80211_ATTR_KEY_CIPHER: key cipher suite (u32, as defined by IEEE 802.11
+ *	section 7.3.2.25.1, e.g. 0x000FAC04)
+ * @NL80211_ATTR_KEY_SEQ: transmit key sequence number (IV/PN) for TKIP and
+ *	CCMP keys, each six bytes in little endian
+ *
+ * @NL80211_ATTR_BEACON_INTERVAL: beacon interval in TU
+ * @NL80211_ATTR_DTIM_PERIOD: DTIM period for beaconing
+ * @NL80211_ATTR_BEACON_HEAD: portion of the beacon before the TIM IE
+ * @NL80211_ATTR_BEACON_TAIL: portion of the beacon after the TIM IE
+ *
+ * @NL80211_ATTR_STA_AID: Association ID for the station (u16)
+ * @NL80211_ATTR_STA_FLAGS: flags, nested element with NLA_FLAG attributes of
+ *	&enum nl80211_sta_flags.
+ * @NL80211_ATTR_STA_LISTEN_INTERVAL: listen interval as defined by
+ *	IEEE 802.11 7.3.1.6 (u16).
+ * @NL80211_ATTR_STA_SUPPORTED_RATES: supported rates, array of supported
+ *	rates as defined by IEEE 802.11 7.3.2.2 but without the length
+ *	restriction (at most %NL80211_MAX_SUPP_RATES).
+ * @NL80211_ATTR_STA_VLAN: interface index of VLAN interface to move station
+ *	to, or the AP interface the station was originally added to to.
+ * @NL80211_ATTR_STA_STATS: statistics for a station, part of station info
+ *	given for %NL80211_CMD_GET_STATION, nested attribute containing
+ *	info as possible, see &enum nl80211_sta_stats.
+ *
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
  */
@@ -89,12 +175,34 @@ enum nl80211_attrs {
 	NL80211_ATTR_IFNAME,
 	NL80211_ATTR_IFTYPE,
 
+	NL80211_ATTR_MAC,
+
+	NL80211_ATTR_KEY_DATA,
+	NL80211_ATTR_KEY_IDX,
+	NL80211_ATTR_KEY_CIPHER,
+	NL80211_ATTR_KEY_SEQ,
+	NL80211_ATTR_KEY_DEFAULT,
+
+	NL80211_ATTR_BEACON_INTERVAL,
+	NL80211_ATTR_DTIM_PERIOD,
+	NL80211_ATTR_BEACON_HEAD,
+	NL80211_ATTR_BEACON_TAIL,
+
+	NL80211_ATTR_STA_AID,
+	NL80211_ATTR_STA_FLAGS,
+	NL80211_ATTR_STA_LISTEN_INTERVAL,
+	NL80211_ATTR_STA_SUPPORTED_RATES,
+	NL80211_ATTR_STA_VLAN,
+	NL80211_ATTR_STA_STATS,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
 	NL80211_ATTR_MAX = __NL80211_ATTR_AFTER_LAST - 1
 };
 
+#define NL80211_MAX_SUPP_RATES	32
+
 /**
  * enum nl80211_iftype - (virtual) interface types
  *
@@ -126,4 +234,50 @@ enum nl80211_iftype {
 	NL80211_IFTYPE_MAX = __NL80211_IFTYPE_AFTER_LAST - 1
 };
 
+/**
+ * enum nl80211_sta_flags - station flags
+ *
+ * Station flags. When a station is added to an AP interface, it is
+ * assumed to be already associated (and hence authenticated.)
+ *
+ * @NL80211_STA_FLAG_AUTHORIZED: station is authorized (802.1X)
+ * @NL80211_STA_FLAG_SHORT_PREAMBLE: station is capable of receiving frames
+ *	with short barker preamble
+ * @NL80211_STA_FLAG_WME: station is WME/QoS capable
+ */
+enum nl80211_sta_flags {
+	__NL80211_STA_FLAG_INVALID,
+	NL80211_STA_FLAG_AUTHORIZED,
+	NL80211_STA_FLAG_SHORT_PREAMBLE,
+	NL80211_STA_FLAG_WME,
+
+	/* keep last */
+	__NL80211_STA_FLAG_AFTER_LAST,
+	NL80211_STA_FLAG_MAX = __NL80211_STA_FLAG_AFTER_LAST - 1
+};
+
+/**
+ * enum nl80211_sta_stats - station statistics
+ *
+ * These attribute types are used with %NL80211_ATTR_STA_STATS
+ * when getting information about a station.
+ *
+ * @__NL80211_STA_STAT_INVALID: attribute number 0 is reserved
+ * @NL80211_STA_STAT_INACTIVE_TIME: time since last activity (u32, msecs)
+ * @NL80211_STA_STAT_RX_BYTES: total received bytes (u32, from this station)
+ * @NL80211_STA_STAT_TX_BYTES: total transmitted bytes (u32, to this station)
+ * @__NL80211_STA_STAT_AFTER_LAST: internal
+ * @NL80211_STA_STAT_MAX: highest possible station stats attribute
+ */
+enum nl80211_sta_stats {
+	__NL80211_STA_STAT_INVALID,
+	NL80211_STA_STAT_INACTIVE_TIME,
+	NL80211_STA_STAT_RX_BYTES,
+	NL80211_STA_STAT_TX_BYTES,
+
+	/* keep last */
+	__NL80211_STA_STAT_AFTER_LAST,
+	NL80211_STA_STAT_MAX = __NL80211_STA_STAT_AFTER_LAST - 1
+};
+
 #endif /* __LINUX_NL80211_H */
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index d30960e..bcc480b 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -49,6 +49,120 @@ extern int ieee80211_radiotap_iterator_next(
    struct ieee80211_radiotap_iterator *iterator);
 
 
+ /**
+ * struct key_params - key information
+ *
+ * Information about a key
+ *
+ * @key: key material
+ * @key_len: length of key material
+ * @cipher: cipher suite selector
+ * @seq: sequence counter (IV/PN) for TKIP and CCMP keys, only used
+ *	with the get_key() callback, must be in little endian,
+ *	length given by @seq_len.
+ */
+struct key_params {
+	u8 *key;
+	u8 *seq;
+	int key_len;
+	int seq_len;
+	u32 cipher;
+};
+
+/**
+ * struct beacon_parameters - beacon parameters
+ *
+ * Used to configure the beacon for an interface.
+ *
+ * @head: head portion of beacon (before TIM IE)
+ *     or %NULL if not changed
+ * @tail: tail portion of beacon (after TIM IE)
+ *     or %NULL if not changed
+ * @interval: beacon interval or zero if not changed
+ * @dtim_period: DTIM period or zero if not changed
+ * @head_len: length of @head
+ * @tail_len: length of @tail
+ */
+struct beacon_parameters {
+	u8 *head, *tail;
+	int interval, dtim_period;
+	int head_len, tail_len;
+};
+
+/**
+ * enum station_flags - station flags
+ *
+ * Station capability flags. Note that these must be the bits
+ * according to the nl80211 flags.
+ *
+ * @STATION_FLAG_CHANGED: station flags were changed
+ * @STATION_FLAG_AUTHORIZED: station is authorized to send frames (802.1X)
+ * @STATION_FLAG_SHORT_PREAMBLE: station is capable of receiving frames
+ *	with short preambles
+ * @STATION_FLAG_WME: station is WME/QoS capable
+ */
+enum station_flags {
+	STATION_FLAG_CHANGED		= 1<<0,
+	STATION_FLAG_AUTHORIZED		= 1<<NL80211_STA_FLAG_AUTHORIZED,
+	STATION_FLAG_SHORT_PREAMBLE	= 1<<NL80211_STA_FLAG_SHORT_PREAMBLE,
+	STATION_FLAG_WME		= 1<<NL80211_STA_FLAG_WME,
+};
+
+/**
+ * struct station_parameters - station parameters
+ *
+ * Used to change and create a new station.
+ *
+ * @vlan: vlan interface station should belong to
+ * @supported_rates: supported rates in IEEE 802.11 format
+ *	(or NULL for no change)
+ * @supported_rates_len: number of supported rates
+ * @station_flags: station flags (see &enum station_flags)
+ * @listen_interval: listen interval or -1 for no change
+ * @aid: AID or zero for no change
+ */
+struct station_parameters {
+	u8 *supported_rates;
+	struct net_device *vlan;
+	u32 station_flags;
+	int listen_interval;
+	u16 aid;
+	u8 supported_rates_len;
+};
+
+/**
+ * enum station_stats_flags - station statistics flags
+ *
+ * Used by the driver to indicate which info in &struct station_stats
+ * it has filled in during get_station().
+ *
+ * @STATION_STAT_INACTIVE_TIME: @inactive_time filled
+ * @STATION_STAT_RX_BYTES: @rx_bytes filled
+ * @STATION_STAT_TX_BYTES: @tx_bytes filled
+ */
+enum station_stats_flags {
+	STATION_STAT_INACTIVE_TIME	= 1<<0,
+	STATION_STAT_RX_BYTES		= 1<<1,
+	STATION_STAT_TX_BYTES		= 1<<2,
+};
+
+/**
+ * struct station_stats - station statistics
+ *
+ * Station information filled by driver for get_station().
+ *
+ * @filled: bitflag of flags from &enum station_stats_flags
+ * @inactive_time: time since last station activity (tx/rx) in milliseconds
+ * @rx_bytes: bytes received from this station
+ * @tx_bytes: bytes transmitted to this station
+ */
+struct station_stats {
+	u32 filled;
+	u32 inactive_time;
+	u32 rx_bytes;
+	u32 tx_bytes;
+};
+
 /* from net/wireless.h */
 struct wiphy;
 
@@ -71,6 +185,31 @@ struct wiphy;
  *
  * @change_virtual_intf: change type of virtual interface
  *
+ * @add_key: add a key with the given parameters. @mac_addr will be %NULL
+ *	when adding a group key.
+ *
+ * @get_key: get information about the key with the given parameters.
+ *	@mac_addr will be %NULL when requesting information for a group
+ *	key. All pointers given to the @callback function need not be valid
+ *	after it returns.
+ *
+ * @del_key: remove a key given the @mac_addr (%NULL for a group key)
+ *	and @key_index
+ *
+ * @set_default_key: set the default key on an interface
+ *
+ * @add_beacon: Add a beacon with given parameters, @head, @interval
+ *	and @dtim_period will be valid, @tail is optional.
+ * @set_beacon: Change the beacon parameters for an access point mode
+ *	interface. This should reject the call when no beacon has been
+ *	configured.
+ * @del_beacon: Remove beacon configuration and stop sending the beacon.
+ *
+ * @add_station: Add a new station.
+ *
+ * @del_station: Remove a station; @mac may be NULL to remove all stations.
+ *
+ * @change_station: Modify a given station.
  */
 struct cfg80211_ops {
 	int	(*add_virtual_intf)(struct wiphy *wiphy, char *name,
@@ -78,6 +217,34 @@ struct cfg80211_ops {
 	int	(*del_virtual_intf)(struct wiphy *wiphy, int ifindex);
 	int	(*change_virtual_intf)(struct wiphy *wiphy, int ifindex,
 				       enum nl80211_iftype type);
+
+	int	(*add_key)(struct wiphy *wiphy, struct net_device *netdev,
+			   u8 key_index, u8 *mac_addr,
+			   struct key_params *params);
+	int	(*get_key)(struct wiphy *wiphy, struct net_device *netdev,
+			   u8 key_index, u8 *mac_addr, void *cookie,
+			   void (*callback)(void *cookie, struct key_params*));
+	int	(*del_key)(struct wiphy *wiphy, struct net_device *netdev,
+			   u8 key_index, u8 *mac_addr);
+	int	(*set_default_key)(struct wiphy *wiphy,
+				   struct net_device *netdev,
+				   u8 key_index);
+
+	int	(*add_beacon)(struct wiphy *wiphy, struct net_device *dev,
+			      struct beacon_parameters *info);
+	int	(*set_beacon)(struct wiphy *wiphy, struct net_device *dev,
+			      struct beacon_parameters *info);
+	int	(*del_beacon)(struct wiphy *wiphy, struct net_device *dev);
+
+
+	int	(*add_station)(struct wiphy *wiphy, struct net_device *dev,
+			       u8 *mac, struct station_parameters *params);
+	int	(*del_station)(struct wiphy *wiphy, struct net_device *dev,
+			       u8 *mac);
+	int	(*change_station)(struct wiphy *wiphy, struct net_device *dev,
+				  u8 *mac, struct station_parameters *params);
+	int	(*get_station)(struct wiphy *wiphy, struct net_device *dev,
+			       u8 *mac, struct station_stats *stats);
 };
 
 #endif /* __NET_CFG80211_H */
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 3bd970f..a762a75 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -307,6 +307,9 @@ struct ieee80211_tx_control {
 						  * using the through
 						  * set_retry_limit configured
 						  * long retry value */
+#define IEEE80211_TXCTL_EAPOL_FRAME	(1<<11) /* internal to mac80211 */
+#define IEEE80211_TXCTL_SEND_AFTER_DTIM	(1<<12) /* send this frame after DTIM
+						 * beacon */
 	u32 flags;			       /* tx control flags defined
 						* above */
 	u8 key_idx;		/* keyidx from hw->set_key(), undefined if
@@ -644,9 +647,6 @@ struct ieee80211_key_conf {
 	u8 key[0];
 };
 
-#define IEEE80211_SEQ_COUNTER_RX	0
-#define IEEE80211_SEQ_COUNTER_TX	1
-
 /**
  * enum set_key_cmd - key command
  *
@@ -993,9 +993,9 @@ enum ieee80211_erp_change_flags {
  *
  * @get_stats: return low-level statistics
  *
- * @get_sequence_counter: For devices that have internal sequence counters this
- *	callback allows mac80211 to access the current value of a counter.
- *	This callback seems not well-defined, tell us if you need it.
+ * @get_tkip_seq: If your device implements TKIP encryption in hardware this
+ *	callback should be provided to read the TKIP transmit IVs (both IV32
+ *	and IV16) for the given key from hardware.
  *
  * @set_rts_threshold: Configuration of RTS threshold (if device needs it)
  *
@@ -1070,9 +1070,8 @@ struct ieee80211_ops {
 	int (*hw_scan)(struct ieee80211_hw *hw, u8 *ssid, size_t len);
 	int (*get_stats)(struct ieee80211_hw *hw,
 			 struct ieee80211_low_level_stats *stats);
-	int (*get_sequence_counter)(struct ieee80211_hw *hw,
-				    u8* addr, u8 keyidx, u8 txrx,
-				    u32* iv32, u16* iv16);
+	void (*get_tkip_seq)(struct ieee80211_hw *hw, u8 hw_key_idx,
+			     u32 *iv32, u16 *iv16);
 	int (*set_rts_threshold)(struct ieee80211_hw *hw, u32 value);
 	int (*set_frag_threshold)(struct ieee80211_hw *hw, u32 value);
 	int (*set_retry_limit)(struct ieee80211_hw *hw,
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 09711b0..cac6cf2 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -10,27 +10,85 @@ config MAC80211
 	select CFG80211
 	select NET_SCH_FIFO
 	---help---
-	This option enables the hardware independent IEEE 802.11
-	networking stack.
+	  This option enables the hardware independent IEEE 802.11
+	  networking stack.
 
-config MAC80211_RCSIMPLE
-	bool "'simple' rate control algorithm" if EMBEDDED
+config MAC80211_RC_DEFAULT_CHOICE
+	bool "Choose default rate control algorithm" if EMBEDDED
 	default y
 	depends on MAC80211
-	help
-	  This option allows you to turn off the 'simple' rate
-	  control algorithm in mac80211. If you do turn it off,
-	  you absolutely need another rate control algorithm.
+	---help---
+	  This options enables selection of a default rate control
+	  algorithm to be built into the mac80211 module.  Alternate
+	  rate control algorithms might be built into the mac80211
+	  module as well.
+
+choice
+	prompt "Default rate control algorithm"
+	default MAC80211_RC_DEFAULT_PID
+	depends on MAC80211 && MAC80211_RC_DEFAULT_CHOICE
+	---help---
+	  This option selects the default rate control algorithm
+	  mac80211 will use. Note that this default can still be
+	  overriden through the ieee80211_default_rc_algo module
+	  parameter.
+
+config MAC80211_RC_DEFAULT_PID
+	bool "PID controller based rate control algorithm"
+	select MAC80211_RC_PID
+	---help---
+	  Select the PID controller based rate control as the
+	  default rate control algorithm. You should choose
+	  this unless you know what you are doing.
+
+config MAC80211_RC_DEFAULT_SIMPLE
+	bool "Simple rate control algorithm"
+	select MAC80211_RC_SIMPLE
+	---help---
+	  Select the simple rate control as the default rate
+	  control algorithm. Note that this is a non-responsive,
+	  dumb algorithm. You should choose the PID rate control
+	  instead.
+
+endchoice
+
+config MAC80211_RC_DEFAULT
+	string
+	depends on MAC80211
+	default "pid" if MAC80211_RC_DEFAULT_PID
+	default "simple" if MAC80211_RC_DEFAULT_SIMPLE
+	default ""
+
+config MAC80211_RC_PID
+	bool "PID controller based rate control algorithm"
+	default y
+	depends on MAC80211
+	---help---
+	  This option enables a TX rate control algorithm for
+	  mac80211 that uses a PID controller to select the TX
+	  rate.
+
+	  Say Y or M unless you're sure you want to use a
+	  different rate control algorithm.
+
+config MAC80211_RC_SIMPLE
+	bool "Simple rate control algorithm (DEPRECATED)"
+	default n
+	depends on MAC80211
+	---help---
+	  This option enables a very simple, non-responsive TX
+	  rate control algorithm. This algorithm is deprecated
+	  and will be removed from the kernel in near future.
+	  It has been replaced by the PID algorithm.
 
-	  Say Y unless you know you will have another algorithm
-	  available.
+	  Say N unless you know what you are doing.
 
 config MAC80211_LEDS
 	bool "Enable LED triggers"
 	depends on MAC80211 && LEDS_TRIGGERS
 	---help---
-	This option enables a few LED triggers for different
-	packet receive/transmit events.
+	  This option enables a few LED triggers for different
+	  packet receive/transmit events.
 
 config MAC80211_DEBUGFS
 	bool "Export mac80211 internals in DebugFS"
@@ -52,14 +110,14 @@ config MAC80211_DEBUG
 	  subsystem, you most likely want to say N here.
 
 config MAC80211_HT_DEBUG
-       bool "Enable HT debugging output"
-       depends on MAC80211_DEBUG
-       ---help---
-       This option enables 802.11n High Throughput features
-       debug tracing output.
-
-       If you are not trying to debug of develop the ieee80211
-       subsystem, you most likely want to say N here.
+	bool "Enable HT debugging output"
+	depends on MAC80211_DEBUG
+	---help---
+	  This option enables 802.11n High Throughput features
+	  debug tracing output.
+
+	  If you are not trying to debug of develop the ieee80211
+	  subsystem, you most likely want to say N here.
 
 config MAC80211_VERBOSE_DEBUG
 	bool "Verbose debugging output"
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 1e6237b..06aea80 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -1,9 +1,17 @@
 obj-$(CONFIG_MAC80211) += mac80211.o
 
 mac80211-objs-$(CONFIG_MAC80211_LEDS) += ieee80211_led.o
-mac80211-objs-$(CONFIG_MAC80211_DEBUGFS) += debugfs.o debugfs_sta.o debugfs_netdev.o debugfs_key.o
 mac80211-objs-$(CONFIG_NET_SCHED) += wme.o
-mac80211-objs-$(CONFIG_MAC80211_RCSIMPLE) += rc80211_simple.o
+mac80211-objs-$(CONFIG_MAC80211_RC_SIMPLE) += rc80211_simple.o
+mac80211-objs-$(CONFIG_MAC80211_RC_PID) += rc80211_pid_algo.o
+
+mac80211-debugfs-objs-$(CONFIG_MAC80211_RC_PID) += rc80211_pid_debugfs.o
+mac80211-objs-$(CONFIG_MAC80211_DEBUGFS) += \
+	debugfs.o \
+	debugfs_sta.o \
+	debugfs_netdev.o \
+	debugfs_key.o \
+	$(mac80211-debugfs-objs-y)
 
 mac80211-objs := \
 	ieee80211.o \
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 9e2bc1f..11156b3 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1,11 +1,12 @@
 /*
  * mac80211 configuration hooks for cfg80211
  *
- * Copyright 2006	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ * Copyright 2006, 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
  *
  * This file is GPLv2 as found in COPYING.
  */
 
+#include <linux/ieee80211.h>
 #include <linux/nl80211.h>
 #include <linux/rtnetlink.h>
 #include <net/net_namespace.h>
@@ -99,8 +100,207 @@ static int ieee80211_change_iface(struct wiphy *wiphy, int ifindex,
 	return 0;
 }
 
+static int ieee80211_add_key(struct wiphy *wiphy, struct net_device *dev,
+			     u8 key_idx, u8 *mac_addr,
+			     struct key_params *params)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct sta_info *sta = NULL;
+	enum ieee80211_key_alg alg;
+	int ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	switch (params->cipher) {
+	case WLAN_CIPHER_SUITE_WEP40:
+	case WLAN_CIPHER_SUITE_WEP104:
+		alg = ALG_WEP;
+		break;
+	case WLAN_CIPHER_SUITE_TKIP:
+		alg = ALG_TKIP;
+		break;
+	case WLAN_CIPHER_SUITE_CCMP:
+		alg = ALG_CCMP;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (mac_addr) {
+		sta = sta_info_get(sdata->local, mac_addr);
+		if (!sta)
+			return -ENOENT;
+	}
+
+	ret = 0;
+	if (!ieee80211_key_alloc(sdata, sta, alg, key_idx,
+				 params->key_len, params->key))
+		ret = -ENOMEM;
+
+	if (sta)
+		sta_info_put(sta);
+
+	return ret;
+}
+
+static int ieee80211_del_key(struct wiphy *wiphy, struct net_device *dev,
+			     u8 key_idx, u8 *mac_addr)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct sta_info *sta;
+	int ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	if (mac_addr) {
+		sta = sta_info_get(sdata->local, mac_addr);
+		if (!sta)
+			return -ENOENT;
+
+		ret = 0;
+		if (sta->key)
+			ieee80211_key_free(sta->key);
+		else
+			ret = -ENOENT;
+
+		sta_info_put(sta);
+		return ret;
+	}
+
+	if (!sdata->keys[key_idx])
+		return -ENOENT;
+
+	ieee80211_key_free(sdata->keys[key_idx]);
+
+	return 0;
+}
+
+static int ieee80211_get_key(struct wiphy *wiphy, struct net_device *dev,
+			     u8 key_idx, u8 *mac_addr, void *cookie,
+			     void (*callback)(void *cookie,
+					      struct key_params *params))
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct sta_info *sta = NULL;
+	u8 seq[6] = {0};
+	struct key_params params;
+	struct ieee80211_key *key;
+	u32 iv32;
+	u16 iv16;
+	int err = -ENOENT;
+
+	if (mac_addr) {
+		sta = sta_info_get(sdata->local, mac_addr);
+		if (!sta)
+			goto out;
+
+		key = sta->key;
+	} else
+		key = sdata->keys[key_idx];
+
+	if (!key)
+		goto out;
+
+	memset(&params, 0, sizeof(params));
+
+	switch (key->conf.alg) {
+	case ALG_TKIP:
+		params.cipher = WLAN_CIPHER_SUITE_TKIP;
+
+		iv32 = key->u.tkip.iv32;
+		iv16 = key->u.tkip.iv16;
+
+		if (key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE &&
+		    sdata->local->ops->get_tkip_seq)
+			sdata->local->ops->get_tkip_seq(
+				local_to_hw(sdata->local),
+				key->conf.hw_key_idx,
+				&iv32, &iv16);
+
+		seq[0] = iv16 & 0xff;
+		seq[1] = (iv16 >> 8) & 0xff;
+		seq[2] = iv32 & 0xff;
+		seq[3] = (iv32 >> 8) & 0xff;
+		seq[4] = (iv32 >> 16) & 0xff;
+		seq[5] = (iv32 >> 24) & 0xff;
+		params.seq = seq;
+		params.seq_len = 6;
+		break;
+	case ALG_CCMP:
+		params.cipher = WLAN_CIPHER_SUITE_CCMP;
+		seq[0] = key->u.ccmp.tx_pn[5];
+		seq[1] = key->u.ccmp.tx_pn[4];
+		seq[2] = key->u.ccmp.tx_pn[3];
+		seq[3] = key->u.ccmp.tx_pn[2];
+		seq[4] = key->u.ccmp.tx_pn[1];
+		seq[5] = key->u.ccmp.tx_pn[0];
+		params.seq = seq;
+		params.seq_len = 6;
+		break;
+	case ALG_WEP:
+		if (key->conf.keylen == 5)
+			params.cipher = WLAN_CIPHER_SUITE_WEP40;
+		else
+			params.cipher = WLAN_CIPHER_SUITE_WEP104;
+		break;
+	}
+
+	params.key = key->conf.key;
+	params.key_len = key->conf.keylen;
+
+	callback(cookie, &params);
+	err = 0;
+
+ out:
+	if (sta)
+		sta_info_put(sta);
+	return err;
+}
+
+static int ieee80211_config_default_key(struct wiphy *wiphy,
+					struct net_device *dev,
+					u8 key_idx)
+{
+	struct ieee80211_sub_if_data *sdata;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ieee80211_set_default_key(sdata, key_idx);
+
+	return 0;
+}
+
+static int ieee80211_get_station(struct wiphy *wiphy, struct net_device *dev,
+				 u8 *mac, struct station_stats *stats)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct sta_info *sta;
+
+	sta = sta_info_get(local, mac);
+	if (!sta)
+		return -ENOENT;
+
+	/* XXX: verify sta->dev == dev */
+
+	stats->filled = STATION_STAT_INACTIVE_TIME |
+			STATION_STAT_RX_BYTES |
+			STATION_STAT_TX_BYTES;
+
+	stats->inactive_time = jiffies_to_msecs(jiffies - sta->last_rx);
+	stats->rx_bytes = sta->rx_bytes;
+	stats->tx_bytes = sta->tx_bytes;
+
+	sta_info_put(sta);
+
+	return 0;
+}
+
 struct cfg80211_ops mac80211_config_ops = {
 	.add_virtual_intf = ieee80211_add_iface,
 	.del_virtual_intf = ieee80211_del_iface,
 	.change_virtual_intf = ieee80211_change_iface,
+	.add_key = ieee80211_add_key,
+	.del_key = ieee80211_del_key,
+	.get_key = ieee80211_get_key,
+	.set_default_key = ieee80211_config_default_key,
+	.get_station = ieee80211_get_station,
 };
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index f0e6ab7..bf715d2 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -91,8 +91,7 @@ static const struct file_operations name##_ops = {			\
 /* common attributes */
 IEEE80211_IF_FILE(channel_use, channel_use, DEC);
 IEEE80211_IF_FILE(drop_unencrypted, drop_unencrypted, DEC);
-IEEE80211_IF_FILE(eapol, eapol, DEC);
-IEEE80211_IF_FILE(ieee8021_x, ieee802_1x, DEC);
+IEEE80211_IF_FILE(ieee802_1x_pac, ieee802_1x_pac, DEC);
 
 /* STA/IBSS attributes */
 IEEE80211_IF_FILE(state, u.sta.state, DEC);
@@ -170,8 +169,7 @@ static void add_sta_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(channel_use, sta);
 	DEBUGFS_ADD(drop_unencrypted, sta);
-	DEBUGFS_ADD(eapol, sta);
-	DEBUGFS_ADD(ieee8021_x, sta);
+	DEBUGFS_ADD(ieee802_1x_pac, sta);
 	DEBUGFS_ADD(state, sta);
 	DEBUGFS_ADD(bssid, sta);
 	DEBUGFS_ADD(prev_bssid, sta);
@@ -192,8 +190,7 @@ static void add_ap_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(channel_use, ap);
 	DEBUGFS_ADD(drop_unencrypted, ap);
-	DEBUGFS_ADD(eapol, ap);
-	DEBUGFS_ADD(ieee8021_x, ap);
+	DEBUGFS_ADD(ieee802_1x_pac, ap);
 	DEBUGFS_ADD(num_sta_ps, ap);
 	DEBUGFS_ADD(dtim_period, ap);
 	DEBUGFS_ADD(dtim_count, ap);
@@ -209,8 +206,7 @@ static void add_wds_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(channel_use, wds);
 	DEBUGFS_ADD(drop_unencrypted, wds);
-	DEBUGFS_ADD(eapol, wds);
-	DEBUGFS_ADD(ieee8021_x, wds);
+	DEBUGFS_ADD(ieee802_1x_pac, wds);
 	DEBUGFS_ADD(peer, wds);
 }
 
@@ -218,8 +214,7 @@ static void add_vlan_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(channel_use, vlan);
 	DEBUGFS_ADD(drop_unencrypted, vlan);
-	DEBUGFS_ADD(eapol, vlan);
-	DEBUGFS_ADD(ieee8021_x, vlan);
+	DEBUGFS_ADD(ieee802_1x_pac, vlan);
 }
 
 static void add_monitor_files(struct ieee80211_sub_if_data *sdata)
@@ -263,8 +258,7 @@ static void del_sta_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(channel_use, sta);
 	DEBUGFS_DEL(drop_unencrypted, sta);
-	DEBUGFS_DEL(eapol, sta);
-	DEBUGFS_DEL(ieee8021_x, sta);
+	DEBUGFS_DEL(ieee802_1x_pac, sta);
 	DEBUGFS_DEL(state, sta);
 	DEBUGFS_DEL(bssid, sta);
 	DEBUGFS_DEL(prev_bssid, sta);
@@ -285,8 +279,7 @@ static void del_ap_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(channel_use, ap);
 	DEBUGFS_DEL(drop_unencrypted, ap);
-	DEBUGFS_DEL(eapol, ap);
-	DEBUGFS_DEL(ieee8021_x, ap);
+	DEBUGFS_DEL(ieee802_1x_pac, ap);
 	DEBUGFS_DEL(num_sta_ps, ap);
 	DEBUGFS_DEL(dtim_period, ap);
 	DEBUGFS_DEL(dtim_count, ap);
@@ -302,8 +295,7 @@ static void del_wds_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(channel_use, wds);
 	DEBUGFS_DEL(drop_unencrypted, wds);
-	DEBUGFS_DEL(eapol, wds);
-	DEBUGFS_DEL(ieee8021_x, wds);
+	DEBUGFS_DEL(ieee802_1x_pac, wds);
 	DEBUGFS_DEL(peer, wds);
 }
 
@@ -311,8 +303,7 @@ static void del_vlan_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(channel_use, vlan);
 	DEBUGFS_DEL(drop_unencrypted, vlan);
-	DEBUGFS_DEL(eapol, vlan);
-	DEBUGFS_DEL(ieee8021_x, vlan);
+	DEBUGFS_DEL(ieee802_1x_pac, vlan);
 }
 
 static void del_monitor_files(struct ieee80211_sub_if_data *sdata)
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index ca0a260..175735e 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -733,6 +733,8 @@ static void ieee80211_remove_tx_extra(struct ieee80211_local *local,
 		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
 	if (control->flags & IEEE80211_TXCTL_REQUEUE)
 		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
+	if (control->flags & IEEE80211_TXCTL_EAPOL_FRAME)
+		pkt_data->flags |= IEEE80211_TXPD_EAPOL_FRAME;
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
@@ -860,10 +862,8 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 			sta_info_put(sta);
 			return;
 		}
-	} else {
-		/* FIXME: STUPID to call this with both local and local->mdev */
-		rate_control_tx_status(local, local->mdev, skb, status);
-	}
+	} else
+		rate_control_tx_status(local->mdev, skb, status);
 
 	ieee80211_led_tx(local, 0);
 
@@ -1315,33 +1315,50 @@ static int __init ieee80211_init(void)
 
 	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
 
-#ifdef CONFIG_MAC80211_RCSIMPLE
+#ifdef CONFIG_MAC80211_RC_SIMPLE
 	ret = ieee80211_rate_control_register(&mac80211_rcsimple);
 	if (ret)
-		return ret;
+		goto fail;
+#endif
+
+#ifdef CONFIG_MAC80211_RC_PID
+	ret = ieee80211_rate_control_register(&mac80211_rcpid);
+	if (ret)
+		goto fail;
 #endif
 
 	ret = ieee80211_wme_register();
 	if (ret) {
-#ifdef CONFIG_MAC80211_RCSIMPLE
-		ieee80211_rate_control_unregister(&mac80211_rcsimple);
-#endif
 		printk(KERN_DEBUG "ieee80211_init: failed to "
 		       "initialize WME (err=%d)\n", ret);
-		return ret;
+		goto fail;
 	}
 
 	ieee80211_debugfs_netdev_init();
 	ieee80211_regdomain_init();
 
 	return 0;
+
+fail:
+
+#ifdef CONFIG_MAC80211_RC_SIMPLE
+	ieee80211_rate_control_unregister(&mac80211_rcsimple);
+#endif
+#ifdef CONFIG_MAC80211_RC_PID
+	ieee80211_rate_control_unregister(&mac80211_rcpid);
+#endif
+
+	return ret;
 }
 
 static void __exit ieee80211_exit(void)
 {
-#ifdef CONFIG_MAC80211_RCSIMPLE
+#ifdef CONFIG_MAC80211_RC_SIMPLE
 	ieee80211_rate_control_unregister(&mac80211_rcsimple);
 #endif
+#ifdef CONFIG_MAC80211_RC_PID
+	ieee80211_rate_control_unregister(&mac80211_rcpid);
+#endif
 
 	ieee80211_wme_unregister();
 	ieee80211_debugfs_netdev_exit();
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index b54ed5f..baf53c0 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -164,6 +164,7 @@ struct ieee80211_txrx_data {
 #define IEEE80211_TXPD_REQ_TX_STATUS	BIT(0)
 #define IEEE80211_TXPD_DO_NOT_ENCRYPT	BIT(1)
 #define IEEE80211_TXPD_REQUEUE		BIT(2)
+#define IEEE80211_TXPD_EAPOL_FRAME	BIT(3)
 /* Stored in sk_buff->cb */
 struct ieee80211_tx_packet_data {
 	int ifindex;
@@ -306,11 +307,11 @@ struct ieee80211_sub_if_data {
 	unsigned int flags;
 
 	int drop_unencrypted;
-	int eapol; /* 0 = process EAPOL frames as normal data frames,
-		    * 1 = send EAPOL frames through wlan#ap to hostapd
-		    *     (default) */
-	int ieee802_1x; /* IEEE 802.1X PAE - drop packet to/from unauthorized
-			 * port */
+	/*
+	 * IEEE 802.1X Port access control in effect,
+	 * drop packets to/from unauthorized port
+	 */
+	int ieee802_1x_pac;
 
 	u16 sequence;
 
@@ -339,8 +340,7 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *state;
 			struct dentry *bssid;
 			struct dentry *prev_bssid;
@@ -359,8 +359,7 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *num_sta_ps;
 			struct dentry *dtim_period;
 			struct dentry *dtim_count;
@@ -374,15 +373,13 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *peer;
 		} wds;
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 		} vlan;
 		struct {
 			struct dentry *mode;
@@ -802,7 +799,6 @@ extern void *mac80211_wiphy_privid; /* for wiphy privid */
 extern const unsigned char rfc1042_header[6];
 extern const unsigned char bridge_tunnel_header[6];
 u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
-int ieee80211_is_eapol(const struct sk_buff *skb, int hdrlen);
 int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 			     int rate, int erp, int short_preamble);
 void mac80211_ev_michael_mic_failure(struct net_device *dev, int keyidx,
diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index 43e505d..7cfd866 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -22,7 +22,6 @@ void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
 
 	/* Default values for sub-interface parameters */
 	sdata->drop_unencrypted = 0;
-	sdata->eapol = 1;
 	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
 		skb_queue_head_init(&sdata->fragments[i].skb_list);
 
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 7254bd6..581d803 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -21,6 +21,11 @@ struct rate_control_alg {
 static LIST_HEAD(rate_ctrl_algs);
 static DEFINE_MUTEX(rate_ctrl_mutex);
 
+static char *ieee80211_default_rc_algo = CONFIG_MAC80211_RC_DEFAULT;
+module_param(ieee80211_default_rc_algo, charp, 0644);
+MODULE_PARM_DESC(ieee80211_default_rc_algo,
+		 "Default rate control algorithm for mac80211 to use");
+
 int ieee80211_rate_control_register(struct rate_control_ops *ops)
 {
 	struct rate_control_alg *alg;
@@ -88,21 +93,27 @@ ieee80211_try_rate_control_ops_get(const char *name)
 	return ops;
 }
 
-/* Get the rate control algorithm. If `name' is NULL, get the first
- * available algorithm. */
+/* Get the rate control algorithm. */
 static struct rate_control_ops *
 ieee80211_rate_control_ops_get(const char *name)
 {
 	struct rate_control_ops *ops;
+	const char *alg_name;
 
 	if (!name)
-		name = "simple";
+		alg_name = ieee80211_default_rc_algo;
+	else
+		alg_name = name;
 
-	ops = ieee80211_try_rate_control_ops_get(name);
+	ops = ieee80211_try_rate_control_ops_get(alg_name);
 	if (!ops) {
-		request_module("rc80211_%s", name);
-		ops = ieee80211_try_rate_control_ops_get(name);
+		request_module("rc80211_%s", alg_name);
+		ops = ieee80211_try_rate_control_ops_get(alg_name);
 	}
+	if (!ops && name)
+		/* try default if specific alg requested but not found */
+		ops = ieee80211_try_rate_control_ops_get(ieee80211_default_rc_algo);
+
 	return ops;
 }
 
@@ -146,6 +157,53 @@ static void rate_control_release(struct kref *kref)
 	kfree(ctrl_ref);
 }
 
+void rate_control_get_rate(struct net_device *dev,
+			   struct ieee80211_hw_mode *mode, struct sk_buff *skb,
+			   struct rate_selection *sel)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct rate_control_ref *ref = local->rate_ctrl;
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct sta_info *sta = sta_info_get(local, hdr->addr1);
+	int i;
+	u16 fc;
+
+	memset(sel, 0, sizeof(struct rate_selection));
+
+	/* Send management frames and broadcast/multicast data using lowest
+	 * rate. */
+	fc = le16_to_cpu(hdr->frame_control);
+	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
+	    is_multicast_ether_addr(hdr->addr1))
+		sel->rate = rate_lowest(local, mode, sta);
+
+	/* If a forced rate is in effect, select it. */
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1)
+		sel->rate = &mode->rates[sdata->bss->force_unicast_rateidx];
+
+	/* If we haven't found the rate yet, ask the rate control algo. */
+	if (!sel->rate)
+		ref->ops->get_rate(ref->priv, dev, mode, skb, sel);
+
+	/* Select a non-ERP backup rate. */
+	if (!sel->nonerp) {
+		for (i = 0; i < mode->num_rates - 1; i++) {
+			struct ieee80211_rate *rate = &mode->rates[i];
+			if (sel->rate->rate < rate->rate)
+				break;
+
+			if (rate_supported(sta, mode, i) &&
+			    !(rate->flags & IEEE80211_RATE_ERP))
+				sel->nonerp = rate;
+		}
+	}
+
+	if (sta)
+		sta_info_put(sta);
+}
+
 struct rate_control_ref *rate_control_get(struct rate_control_ref *ref)
 {
 	kref_get(&ref->kref);
@@ -196,3 +254,4 @@ void rate_control_deinitialize(struct ieee80211_local *local)
 	local->rate_ctrl = NULL;
 	rate_control_put(ref);
 }
+
diff --git a/net/mac80211/ieee80211_rate.h b/net/mac80211/ieee80211_rate.h
index 2368813..3eb0696 100644
--- a/net/mac80211/ieee80211_rate.h
+++ b/net/mac80211/ieee80211_rate.h
@@ -18,31 +18,24 @@
 #include "ieee80211_i.h"
 #include "sta_info.h"
 
-#define RATE_CONTROL_NUM_DOWN 20
-#define RATE_CONTROL_NUM_UP   15
-
-
-struct rate_control_extra {
-	/* values from rate_control_get_rate() to the caller: */
-	struct ieee80211_rate *probe; /* probe with this rate, or NULL for no
-				       * probing */
+struct rate_selection {
+	/* Selected transmission rate */
+	struct ieee80211_rate *rate;
+	/* Non-ERP rate to use if mac80211 decides it cannot use an ERP rate */
 	struct ieee80211_rate *nonerp;
-
-	/* parameters from the caller to rate_control_get_rate(): */
-	struct ieee80211_hw_mode *mode;
-	u16 ethertype;
+	/* probe with this rate, or NULL for no probing */
+	struct ieee80211_rate *probe;
 };
 
-
 struct rate_control_ops {
 	struct module *module;
 	const char *name;
 	void (*tx_status)(void *priv, struct net_device *dev,
 			  struct sk_buff *skb,
 			  struct ieee80211_tx_status *status);
-	struct ieee80211_rate *(*get_rate)(void *priv, struct net_device *dev,
-					   struct sk_buff *skb,
-					   struct rate_control_extra *extra);
+	void (*get_rate)(void *priv, struct net_device *dev,
+			 struct ieee80211_hw_mode *mode, struct sk_buff *skb,
+			 struct rate_selection *sel);
 	void (*rate_init)(void *priv, void *priv_sta,
 			  struct ieee80211_local *local, struct sta_info *sta);
 	void (*clear)(void *priv);
@@ -68,6 +61,9 @@ struct rate_control_ref {
 /* default 'simple' algorithm */
 extern struct rate_control_ops mac80211_rcsimple;
 
+/* 'PID' algorithm */
+extern struct rate_control_ops mac80211_rcpid;
+
 int ieee80211_rate_control_register(struct rate_control_ops *ops);
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
@@ -75,25 +71,20 @@ void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
  * first available algorithm. */
 struct rate_control_ref *rate_control_alloc(const char *name,
 					    struct ieee80211_local *local);
+void rate_control_get_rate(struct net_device *dev,
+			   struct ieee80211_hw_mode *mode, struct sk_buff *skb,
+			   struct rate_selection *sel);
 struct rate_control_ref *rate_control_get(struct rate_control_ref *ref);
 void rate_control_put(struct rate_control_ref *ref);
 
-static inline void rate_control_tx_status(struct ieee80211_local *local,
-					  struct net_device *dev,
+static inline void rate_control_tx_status(struct net_device *dev,
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct rate_control_ref *ref = local->rate_ctrl;
-	ref->ops->tx_status(ref->priv, dev, skb, status);
-}
 
-
-static inline struct ieee80211_rate *
-rate_control_get_rate(struct ieee80211_local *local, struct net_device *dev,
-		      struct sk_buff *skb, struct rate_control_extra *extra)
-{
-	struct rate_control_ref *ref = local->rate_ctrl;
-	return ref->ops->get_rate(ref->priv, dev, skb, extra);
+	ref->ops->tx_status(ref->priv, dev, skb, status);
 }
 
 
@@ -142,6 +133,37 @@ static inline void rate_control_remove_sta_debugfs(struct sta_info *sta)
 #endif
 }
 
+static inline int
+rate_supported(struct sta_info *sta, struct ieee80211_hw_mode *mode, int index)
+{
+	return (sta == NULL || sta->supp_rates & BIT(index)) &&
+	       (mode->rates[index].flags & IEEE80211_RATE_SUPPORTED);
+}
+
+static inline int
+rate_lowest_index(struct ieee80211_local *local, struct ieee80211_hw_mode *mode,
+		  struct sta_info *sta)
+{
+	int i;
+
+	for (i = 0; i < mode->num_rates; i++) {
+		if (rate_supported(sta, mode, i))
+			return i;
+	}
+
+	/* warn when we cannot find a rate. */
+	WARN_ON(1);
+
+	return 0;
+}
+
+static inline struct ieee80211_rate *
+rate_lowest(struct ieee80211_local *local, struct ieee80211_hw_mode *mode,
+	    struct sta_info *sta)
+{
+	return &mode->rates[rate_lowest_index(local, mode, sta)];
+}
+
 
 /* functions for rate control related to a device */
 int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 5ee9622..8c61fed 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1375,20 +1375,6 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 		return;
 	}
 
-	/* it probably doesn't, but if the frame includes an ERP value then
-	 * update our stored copy */
-	if (elems.erp_info && elems.erp_info_len >= 1) {
-		struct ieee80211_sta_bss *bss
-			= ieee80211_rx_bss_get(dev, ifsta->bssid,
-					       local->hw.conf.channel,
-					       ifsta->ssid, ifsta->ssid_len);
-		if (bss) {
-			bss->erp_value = elems.erp_info[0];
-			bss->has_erp_value = 1;
-			ieee80211_rx_bss_put(dev, bss);
-		}
-	}
-
 	printk(KERN_DEBUG "%s: associated\n", dev->name);
 	ifsta->aid = aid;
 	ifsta->ap_capab = capab_info;
@@ -1998,10 +1984,10 @@ static void ieee80211_rx_mgmt_probe_req(struct net_device *dev,
 	ieee80211_sta_tx(dev, skb, 0);
 }
 
-void ieee80211_rx_mgmt_action(struct net_device *dev,
-			     struct ieee80211_if_sta *ifsta,
-			     struct ieee80211_mgmt *mgmt,
-			     size_t len)
+static void ieee80211_rx_mgmt_action(struct net_device *dev,
+				     struct ieee80211_if_sta *ifsta,
+				     struct ieee80211_mgmt *mgmt,
+				     size_t len)
 {
 	if (len < IEEE80211_MIN_ACTION_SIZE)
 		return;
@@ -2467,9 +2453,8 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	struct ieee80211_tx_control control;
-	struct ieee80211_rate *rate;
 	struct ieee80211_hw_mode *mode;
-	struct rate_control_extra extra;
+	struct rate_selection ratesel;
 	u8 *pos;
 	struct ieee80211_sub_if_data *sdata;
 
@@ -2554,18 +2539,16 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 		}
 
 		memset(&control, 0, sizeof(control));
-		memset(&extra, 0, sizeof(extra));
-		extra.mode = local->oper_hw_mode;
-		rate = rate_control_get_rate(local, dev, skb, &extra);
-		if (!rate) {
+		rate_control_get_rate(dev, local->oper_hw_mode, skb, &ratesel);
+		if (!ratesel.rate) {
 			printk(KERN_DEBUG "%s: Failed to determine TX rate "
 			       "for IBSS beacon\n", dev->name);
 			break;
 		}
 		control.tx_rate =
 			((sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE) &&
-			(rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
-			rate->val2 : rate->val;
+			(ratesel.rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
+			ratesel.rate->val2 : ratesel.rate->val;
 		control.antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control.power_level = local->hw.conf.power_level;
 		control.flags |= IEEE80211_TXCTL_NO_ACK;
diff --git a/net/mac80211/rc80211_pid.h b/net/mac80211/rc80211_pid.h
new file mode 100644
index 0000000..425eb70
--- /dev/null
+++ b/net/mac80211/rc80211_pid.h
@@ -0,0 +1,261 @@
+/*
+ * Copyright 2007, Mattias Nissler <mattias.nissler-Mmb7MZpHnFY@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef RC80211_PID_H
+#define RC80211_PID_H
+
+/* Sampling period for measuring percentage of failed frames. */
+#define RC_PID_INTERVAL (HZ / 8)
+
+/* Exponential averaging smoothness (used for I part of PID controller) */
+#define RC_PID_SMOOTHING_SHIFT 3
+#define RC_PID_SMOOTHING (1 << RC_PID_SMOOTHING_SHIFT)
+
+/* Sharpening factor (used for D part of PID controller) */
+#define RC_PID_SHARPENING_FACTOR 0
+#define RC_PID_SHARPENING_DURATION 0
+
+/* Fixed point arithmetic shifting amount. */
+#define RC_PID_ARITH_SHIFT 8
+
+/* Fixed point arithmetic factor. */
+#define RC_PID_ARITH_FACTOR (1 << RC_PID_ARITH_SHIFT)
+
+/* Proportional PID component coefficient. */
+#define RC_PID_COEFF_P 15
+/* Integral PID component coefficient. */
+#define RC_PID_COEFF_I 9
+/* Derivative PID component coefficient. */
+#define RC_PID_COEFF_D 15
+
+/* Target failed frames rate for the PID controller. NB: This effectively gives
+ * maximum failed frames percentage we're willing to accept. If the wireless
+ * link quality is good, the controller will fail to adjust failed frames
+ * percentage to the target. This is intentional.
+ */
+#define RC_PID_TARGET_PF (11 << RC_PID_ARITH_SHIFT)
+
+/* Rate behaviour normalization quantity over time. */
+#define RC_PID_NORM_OFFSET 3
+
+/* Push high rates right after loading. */
+#define RC_PID_FAST_START 0
+
+/* Arithmetic right shift for positive and negative values for ISO C. */
+#define RC_PID_DO_ARITH_RIGHT_SHIFT(x, y) \
+	(x) < 0 ? -((-(x)) >> (y)) : (x) >> (y)
+
+enum rc_pid_event_type {
+	RC_PID_EVENT_TYPE_TX_STATUS,
+	RC_PID_EVENT_TYPE_RATE_CHANGE,
+	RC_PID_EVENT_TYPE_TX_RATE,
+	RC_PID_EVENT_TYPE_PF_SAMPLE,
+};
+
+union rc_pid_event_data {
+	/* RC_PID_EVENT_TX_STATUS */
+	struct {
+		struct ieee80211_tx_status tx_status;
+	};
+	/* RC_PID_EVENT_TYPE_RATE_CHANGE */
+	/* RC_PID_EVENT_TYPE_TX_RATE */
+	struct {
+		int index;
+		int rate;
+	};
+	/* RC_PID_EVENT_TYPE_PF_SAMPLE */
+	struct {
+		s32 pf_sample;
+		s32 prop_err;
+		s32 int_err;
+		s32 der_err;
+	};
+};
+
+struct rc_pid_event {
+	/* The time when the event occured */
+	unsigned long timestamp;
+
+	/* Event ID number */
+	unsigned int id;
+
+	/* Type of event */
+	enum rc_pid_event_type type;
+
+	/* type specific data */
+	union rc_pid_event_data data;
+};
+
+/* Size of the event ring buffer. */
+#define RC_PID_EVENT_RING_SIZE 32
+
+struct rc_pid_event_buffer {
+	/* Counter that generates event IDs */
+	unsigned int ev_count;
+
+	/* Ring buffer of events */
+	struct rc_pid_event ring[RC_PID_EVENT_RING_SIZE];
+
+	/* Index to the entry in events_buf to be reused */
+	unsigned int next_entry;
+
+	/* Lock that guards against concurrent access to this buffer struct */
+	spinlock_t lock;
+
+	/* Wait queue for poll/select and blocking I/O */
+	wait_queue_head_t waitqueue;
+};
+
+struct rc_pid_events_file_info {
+	/* The event buffer we read */
+	struct rc_pid_event_buffer *events;
+
+	/* The entry we have should read next */
+	unsigned int next_entry;
+};
+
+struct rc_pid_debugfs_entries {
+	struct dentry *dir;
+	struct dentry *target;
+	struct dentry *sampling_period;
+	struct dentry *coeff_p;
+	struct dentry *coeff_i;
+	struct dentry *coeff_d;
+	struct dentry *smoothing_shift;
+	struct dentry *sharpen_factor;
+	struct dentry *sharpen_duration;
+	struct dentry *norm_offset;
+	struct dentry *fast_start;
+};
+
+void rate_control_pid_event_tx_status(struct rc_pid_event_buffer *buf,
+					     struct ieee80211_tx_status *stat);
+
+void rate_control_pid_event_rate_change(struct rc_pid_event_buffer *buf,
+					       int index, int rate);
+
+void rate_control_pid_event_tx_rate(struct rc_pid_event_buffer *buf,
+					   int index, int rate);
+
+void rate_control_pid_event_pf_sample(struct rc_pid_event_buffer *buf,
+					     s32 pf_sample, s32 prop_err,
+					     s32 int_err, s32 der_err);
+
+void rate_control_pid_add_sta_debugfs(void *priv, void *priv_sta,
+					     struct dentry *dir);
+
+void rate_control_pid_remove_sta_debugfs(void *priv, void *priv_sta);
+
+struct rc_pid_sta_info {
+	unsigned long last_change;
+	unsigned long last_sample;
+
+	u32 tx_num_failed;
+	u32 tx_num_xmit;
+
+	/* Average failed frames percentage error (i.e. actual vs. target
+	 * percentage), scaled by RC_PID_SMOOTHING. This value is computed
+	 * using using an exponential weighted average technique:
+	 *
+	 *           (RC_PID_SMOOTHING - 1) * err_avg_old + err
+	 * err_avg = ------------------------------------------
+	 *                       RC_PID_SMOOTHING
+	 *
+	 * where err_avg is the new approximation, err_avg_old the previous one
+	 * and err is the error w.r.t. to the current failed frames percentage
+	 * sample. Note that the bigger RC_PID_SMOOTHING the more weight is
+	 * given to the previous estimate, resulting in smoother behavior (i.e.
+	 * corresponding to a longer integration window).
+	 *
+	 * For computation, we actually don't use the above formula, but this
+	 * one:
+	 *
+	 * err_avg_scaled = err_avg_old_scaled - err_avg_old + err
+	 *
+	 * where:
+	 * 	err_avg_scaled = err * RC_PID_SMOOTHING
+	 * 	err_avg_old_scaled = err_avg_old * RC_PID_SMOOTHING
+	 *
+	 * This avoids floating point numbers and the per_failed_old value can
+	 * easily be obtained by shifting per_failed_old_scaled right by
+	 * RC_PID_SMOOTHING_SHIFT.
+	 */
+	s32 err_avg_sc;
+
+	/* Last framed failes percentage sample. */
+	u32 last_pf;
+
+	/* Sharpening needed. */
+	u8 sharp_cnt;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	/* Event buffer */
+	struct rc_pid_event_buffer events;
+
+	/* Events debugfs file entry */
+	struct dentry *events_entry;
+#endif
+};
+
+/* Algorithm parameters. We keep them on a per-algorithm approach, so they can
+ * be tuned individually for each interface.
+ */
+struct rc_pid_rateinfo {
+
+	/* Map sorted rates to rates in ieee80211_hw_mode. */
+	int index;
+
+	/* Map rates in ieee80211_hw_mode to sorted rates. */
+	int rev_index;
+
+	/* Did we do any measurement on this rate? */
+	bool valid;
+
+	/* Comparison with the lowest rate. */
+	int diff;
+};
+
+struct rc_pid_info {
+
+	/* The failed frames percentage target. */
+	unsigned int target;
+
+	/* Rate at which failed frames percentage is sampled in 0.001s. */
+	unsigned int sampling_period;
+
+	/* P, I and D coefficients. */
+	int coeff_p;
+	int coeff_i;
+	int coeff_d;
+
+	/* Exponential averaging shift. */
+	unsigned int smoothing_shift;
+
+	/* Sharpening factor and duration. */
+	unsigned int sharpen_factor;
+	unsigned int sharpen_duration;
+
+	/* Normalization offset. */
+	unsigned int norm_offset;
+
+	/* Fast starst parameter. */
+	unsigned int fast_start;
+
+	/* Rates information. */
+	struct rc_pid_rateinfo *rinfo;
+
+	/* Index of the last used rate. */
+	int oldrate;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	/* Debugfs entries created for the parameters above. */
+	struct rc_pid_debugfs_entries dentries;
+#endif
+};
+
+#endif /* RC80211_PID_H */
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
new file mode 100644
index 0000000..631e468
--- /dev/null
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -0,0 +1,510 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005, Devicescape Software, Inc.
+ * Copyright 2007, Mattias Nissler <mattias.nissler-Mmb7MZpHnFY@public.gmane.org>
+ * Copyright 2007, Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+
+#include <net/mac80211.h>
+#include "ieee80211_rate.h"
+
+#include "rc80211_pid.h"
+
+
+/* This is an implementation of a TX rate control algorithm that uses a PID
+ * controller. Given a target failed frames rate, the controller decides about
+ * TX rate changes to meet the target failed frames rate.
+ *
+ * The controller basically computes the following:
+ *
+ * adj = CP * err + CI * err_avg + CD * (err - last_err) * (1 + sharpening)
+ *
+ * where
+ * 	adj	adjustment value that is used to switch TX rate (see below)
+ * 	err	current error: target vs. current failed frames percentage
+ * 	last_err	last error
+ * 	err_avg	average (i.e. poor man's integral) of recent errors
+ *	sharpening	non-zero when fast response is needed (i.e. right after
+ *			association or no frames sent for a long time), heading
+ * 			to zero over time
+ * 	CP	Proportional coefficient
+ * 	CI	Integral coefficient
+ * 	CD	Derivative coefficient
+ *
+ * CP, CI, CD are subject to careful tuning.
+ *
+ * The integral component uses a exponential moving average approach instead of
+ * an actual sliding window. The advantage is that we don't need to keep an
+ * array of the last N error values and computation is easier.
+ *
+ * Once we have the adj value, we map it to a rate by means of a learning
+ * algorithm. This algorithm keeps the state of the percentual failed frames
+ * difference between rates. The behaviour of the lowest available rate is kept
+ * as a reference value, and every time we switch between two rates, we compute
+ * the difference between the failed frames each rate exhibited. By doing so,
+ * we compare behaviours which different rates exhibited in adjacent timeslices,
+ * thus the comparison is minimally affected by external conditions. This
+ * difference gets propagated to the whole set of measurements, so that the
+ * reference is always the same. Periodically, we normalize this set so that
+ * recent events weigh the most. By comparing the adj value with this set, we
+ * avoid pejorative switches to lower rates and allow for switches to higher
+ * rates if they behaved well.
+ *
+ * Note that for the computations we use a fixed-point representation to avoid
+ * floating point arithmetic. Hence, all values are shifted left by
+ * RC_PID_ARITH_SHIFT.
+ */
+
+
+/* Shift the adjustment so that we won't switch to a lower rate if it exhibited
+ * a worse failed frames behaviour and we'll choose the highest rate whose
+ * failed frames behaviour is not worse than the one of the original rate
+ * target. While at it, check that the adjustment is within the ranges. Then,
+ * provide the new rate index. */
+static int rate_control_pid_shift_adjust(struct rc_pid_rateinfo *r,
+					 int adj, int cur, int l)
+{
+	int i, j, k, tmp;
+
+	if (cur + adj < 0)
+		return 0;
+	if (cur + adj >= l)
+		return l - 1;
+
+	i = r[cur + adj].rev_index;
+
+	j = r[cur].rev_index;
+
+	if (adj < 0) {
+			tmp = i;
+			for (k = j; k >= i; k--)
+				if (r[k].diff <= r[j].diff)
+					tmp = k;
+			return r[tmp].index;
+	} else if (adj > 0) {
+			tmp = i;
+			for (k = i + 1; k + i < l; k++)
+				if (r[k].diff <= r[i].diff)
+					tmp = k;
+			return r[tmp].index;
+	}
+	return cur + adj;
+}
+
+static void rate_control_pid_adjust_rate(struct ieee80211_local *local,
+					 struct sta_info *sta, int adj,
+					 struct rc_pid_rateinfo *rinfo)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_hw_mode *mode;
+	int newidx;
+	int maxrate;
+	int back = (adj > 0) ? 1 : -1;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
+		/* forced unicast rate - do not change STA rate */
+		return;
+	}
+
+	mode = local->oper_hw_mode;
+	maxrate = sdata->bss ? sdata->bss->max_ratectrl_rateidx : -1;
+
+	newidx = rate_control_pid_shift_adjust(rinfo, adj, sta->txrate,
+					       mode->num_rates);
+
+	while (newidx != sta->txrate) {
+		if (rate_supported(sta, mode, newidx) &&
+		    (maxrate < 0 || newidx <= maxrate)) {
+			sta->txrate = newidx;
+			break;
+		}
+
+		newidx += back;
+	}
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	rate_control_pid_event_rate_change(
+		&((struct rc_pid_sta_info *)sta->rate_ctrl_priv)->events,
+		newidx, mode->rates[newidx].rate);
+#endif
+}
+
+/* Normalize the failed frames per-rate differences. */
+static void rate_control_pid_normalize(struct rc_pid_info *pinfo, int l)
+{
+	int i, norm_offset = pinfo->norm_offset;
+	struct rc_pid_rateinfo *r = pinfo->rinfo;
+
+	if (r[0].diff > norm_offset)
+		r[0].diff -= norm_offset;
+	else if (r[0].diff < -norm_offset)
+		r[0].diff += norm_offset;
+	for (i = 0; i < l - 1; i++)
+		if (r[i + 1].diff > r[i].diff + norm_offset)
+			r[i + 1].diff -= norm_offset;
+		else if (r[i + 1].diff <= r[i].diff)
+			r[i + 1].diff += norm_offset;
+}
+
+static void rate_control_pid_sample(struct rc_pid_info *pinfo,
+				    struct ieee80211_local *local,
+				    struct sta_info *sta)
+{
+	struct rc_pid_sta_info *spinfo = sta->rate_ctrl_priv;
+	struct rc_pid_rateinfo *rinfo = pinfo->rinfo;
+	struct ieee80211_hw_mode *mode;
+	u32 pf;
+	s32 err_avg;
+	u32 err_prop;
+	u32 err_int;
+	u32 err_der;
+	int adj, i, j, tmp;
+	unsigned long period;
+
+	mode = local->oper_hw_mode;
+	spinfo = sta->rate_ctrl_priv;
+
+	/* In case nothing happened during the previous control interval, turn
+	 * the sharpening factor on. */
+	period = (HZ * pinfo->sampling_period + 500) / 1000;
+	if (!period)
+		period = 1;
+	if (jiffies - spinfo->last_sample > 2 * period)
+		spinfo->sharp_cnt = pinfo->sharpen_duration;
+
+	spinfo->last_sample = jiffies;
+
+	/* This should never happen, but in case, we assume the old sample is
+	 * still a good measurement and copy it. */
+	if (unlikely(spinfo->tx_num_xmit == 0))
+		pf = spinfo->last_pf;
+	else {
+		pf = spinfo->tx_num_failed * 100 / spinfo->tx_num_xmit;
+		pf <<= RC_PID_ARITH_SHIFT;
+	}
+
+	spinfo->tx_num_xmit = 0;
+	spinfo->tx_num_failed = 0;
+
+	/* If we just switched rate, update the rate behaviour info. */
+	if (pinfo->oldrate != sta->txrate) {
+
+		i = rinfo[pinfo->oldrate].rev_index;
+		j = rinfo[sta->txrate].rev_index;
+
+		tmp = (pf - spinfo->last_pf);
+		tmp = RC_PID_DO_ARITH_RIGHT_SHIFT(tmp, RC_PID_ARITH_SHIFT);
+
+		rinfo[j].diff = rinfo[i].diff + tmp;
+		pinfo->oldrate = sta->txrate;
+	}
+	rate_control_pid_normalize(pinfo, mode->num_rates);
+
+	/* Compute the proportional, integral and derivative errors. */
+	err_prop = pinfo->target - pf;
+
+	err_avg = spinfo->err_avg_sc >> pinfo->smoothing_shift;
+	spinfo->err_avg_sc = spinfo->err_avg_sc - err_avg + err_prop;
+	err_int = spinfo->err_avg_sc >> pinfo->smoothing_shift;
+
+	err_der = (pf - spinfo->last_pf) *
+		  (1 + pinfo->sharpen_factor * spinfo->sharp_cnt);
+	spinfo->last_pf = pf;
+	if (spinfo->sharp_cnt)
+			spinfo->sharp_cnt--;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	rate_control_pid_event_pf_sample(&spinfo->events, pf, err_prop, err_int,
+					 err_der);
+#endif
+
+	/* Compute the controller output. */
+	adj = (err_prop * pinfo->coeff_p + err_int * pinfo->coeff_i
+	      + err_der * pinfo->coeff_d);
+	adj = RC_PID_DO_ARITH_RIGHT_SHIFT(adj, 2 * RC_PID_ARITH_SHIFT);
+
+	/* Change rate. */
+	if (adj)
+		rate_control_pid_adjust_rate(local, sta, adj, rinfo);
+}
+
+static void rate_control_pid_tx_status(void *priv, struct net_device *dev,
+				       struct sk_buff *skb,
+				       struct ieee80211_tx_status *status)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct rc_pid_info *pinfo = priv;
+	struct sta_info *sta;
+	struct rc_pid_sta_info *spinfo;
+	unsigned long period;
+
+	sta = sta_info_get(local, hdr->addr1);
+
+	if (!sta)
+		return;
+
+	/* Ignore all frames that were sent with a different rate than the rate
+	 * we currently advise mac80211 to use. */
+	if (status->control.rate != &local->oper_hw_mode->rates[sta->txrate])
+		return;
+
+	spinfo = sta->rate_ctrl_priv;
+	spinfo->tx_num_xmit++;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	rate_control_pid_event_tx_status(&spinfo->events, status);
+#endif
+
+	/* We count frames that totally failed to be transmitted as two bad
+	 * frames, those that made it out but had some retries as one good and
+	 * one bad frame. */
+	if (status->excessive_retries) {
+		spinfo->tx_num_failed += 2;
+		spinfo->tx_num_xmit++;
+	} else if (status->retry_count) {
+		spinfo->tx_num_failed++;
+		spinfo->tx_num_xmit++;
+	}
+
+	if (status->excessive_retries) {
+		sta->tx_retry_failed++;
+		sta->tx_num_consecutive_failures++;
+		sta->tx_num_mpdu_fail++;
+	} else {
+		sta->last_ack_rssi[0] = sta->last_ack_rssi[1];
+		sta->last_ack_rssi[1] = sta->last_ack_rssi[2];
+		sta->last_ack_rssi[2] = status->ack_signal;
+		sta->tx_num_consecutive_failures = 0;
+		sta->tx_num_mpdu_ok++;
+	}
+	sta->tx_retry_count += status->retry_count;
+	sta->tx_num_mpdu_fail += status->retry_count;
+
+	/* Update PID controller state. */
+	period = (HZ * pinfo->sampling_period + 500) / 1000;
+	if (!period)
+		period = 1;
+	if (time_after(jiffies, spinfo->last_sample + period))
+		rate_control_pid_sample(pinfo, local, sta);
+
+	sta_info_put(sta);
+}
+
+static void rate_control_pid_get_rate(void *priv, struct net_device *dev,
+				      struct ieee80211_hw_mode *mode,
+				      struct sk_buff *skb,
+				      struct rate_selection *sel)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct sta_info *sta;
+	int rateidx;
+
+	sta = sta_info_get(local, hdr->addr1);
+
+	if (!sta) {
+		sel->rate = rate_lowest(local, mode, NULL);
+		sta_info_put(sta);
+		return;
+	}
+
+	rateidx = sta->txrate;
+
+	if (rateidx >= mode->num_rates)
+		rateidx = mode->num_rates - 1;
+
+	sta_info_put(sta);
+
+	sel->rate = &mode->rates[rateidx];
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	rate_control_pid_event_tx_rate(
+		&((struct rc_pid_sta_info *) sta->rate_ctrl_priv)->events,
+		rateidx, mode->rates[rateidx].rate);
+#endif
+}
+
+static void rate_control_pid_rate_init(void *priv, void *priv_sta,
+					  struct ieee80211_local *local,
+					  struct sta_info *sta)
+{
+	/* TODO: This routine should consider using RSSI from previous packets
+	 * as we need to have IEEE 802.1X auth succeed immediately after assoc..
+	 * Until that method is implemented, we will use the lowest supported
+	 * rate as a workaround. */
+	sta->txrate = rate_lowest_index(local, local->oper_hw_mode, sta);
+}
+
+static void *rate_control_pid_alloc(struct ieee80211_local *local)
+{
+	struct rc_pid_info *pinfo;
+	struct rc_pid_rateinfo *rinfo;
+	struct ieee80211_hw_mode *mode;
+	int i, j, tmp;
+	bool s;
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct rc_pid_debugfs_entries *de;
+#endif
+
+	pinfo = kmalloc(sizeof(*pinfo), GFP_ATOMIC);
+	if (!pinfo)
+		return NULL;
+
+	/* We can safely assume that oper_hw_mode won't change unless we get
+	 * reinitialized. */
+	mode = local->oper_hw_mode;
+	rinfo = kmalloc(sizeof(*rinfo) * mode->num_rates, GFP_ATOMIC);
+	if (!rinfo) {
+		kfree(pinfo);
+		return NULL;
+	}
+
+	/* Sort the rates. This is optimized for the most common case (i.e.
+	 * almost-sorted CCK+OFDM rates). Kind of bubble-sort with reversed
+	 * mapping too. */
+	for (i = 0; i < mode->num_rates; i++) {
+		rinfo[i].index = i;
+		rinfo[i].rev_index = i;
+		if (pinfo->fast_start)
+			rinfo[i].diff = 0;
+		else
+			rinfo[i].diff = i * pinfo->norm_offset;
+	}
+	for (i = 1; i < mode->num_rates; i++) {
+		s = 0;
+		for (j = 0; j < mode->num_rates - i; j++)
+			if (unlikely(mode->rates[rinfo[j].index].rate >
+				     mode->rates[rinfo[j + 1].index].rate)) {
+				tmp = rinfo[j].index;
+				rinfo[j].index = rinfo[j + 1].index;
+				rinfo[j + 1].index = tmp;
+				rinfo[rinfo[j].index].rev_index = j;
+				rinfo[rinfo[j + 1].index].rev_index = j + 1;
+				s = 1;
+			}
+		if (!s)
+			break;
+	}
+
+	pinfo->target = RC_PID_TARGET_PF;
+	pinfo->sampling_period = RC_PID_INTERVAL;
+	pinfo->coeff_p = RC_PID_COEFF_P;
+	pinfo->coeff_i = RC_PID_COEFF_I;
+	pinfo->coeff_d = RC_PID_COEFF_D;
+	pinfo->smoothing_shift = RC_PID_SMOOTHING_SHIFT;
+	pinfo->sharpen_factor = RC_PID_SHARPENING_FACTOR;
+	pinfo->sharpen_duration = RC_PID_SHARPENING_DURATION;
+	pinfo->norm_offset = RC_PID_NORM_OFFSET;
+	pinfo->fast_start = RC_PID_FAST_START;
+	pinfo->rinfo = rinfo;
+	pinfo->oldrate = 0;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	de = &pinfo->dentries;
+	de->dir = debugfs_create_dir("rc80211_pid",
+				     local->hw.wiphy->debugfsdir);
+	de->target = debugfs_create_u32("target_pf", S_IRUSR | S_IWUSR,
+					de->dir, &pinfo->target);
+	de->sampling_period = debugfs_create_u32("sampling_period",
+						 S_IRUSR | S_IWUSR, de->dir,
+						 &pinfo->sampling_period);
+	de->coeff_p = debugfs_create_u32("coeff_p", S_IRUSR | S_IWUSR,
+					 de->dir, &pinfo->coeff_p);
+	de->coeff_i = debugfs_create_u32("coeff_i", S_IRUSR | S_IWUSR,
+					 de->dir, &pinfo->coeff_i);
+	de->coeff_d = debugfs_create_u32("coeff_d", S_IRUSR | S_IWUSR,
+					 de->dir, &pinfo->coeff_d);
+	de->smoothing_shift = debugfs_create_u32("smoothing_shift",
+						 S_IRUSR | S_IWUSR, de->dir,
+						 &pinfo->smoothing_shift);
+	de->sharpen_factor = debugfs_create_u32("sharpen_factor",
+					       S_IRUSR | S_IWUSR, de->dir,
+					       &pinfo->sharpen_factor);
+	de->sharpen_duration = debugfs_create_u32("sharpen_duration",
+						  S_IRUSR | S_IWUSR, de->dir,
+						  &pinfo->sharpen_duration);
+	de->norm_offset = debugfs_create_u32("norm_offset",
+					     S_IRUSR | S_IWUSR, de->dir,
+					     &pinfo->norm_offset);
+	de->fast_start = debugfs_create_bool("fast_start",
+					     S_IRUSR | S_IWUSR, de->dir,
+					     &pinfo->fast_start);
+#endif
+
+	return pinfo;
+}
+
+static void rate_control_pid_free(void *priv)
+{
+	struct rc_pid_info *pinfo = priv;
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct rc_pid_debugfs_entries *de = &pinfo->dentries;
+
+	debugfs_remove(de->fast_start);
+	debugfs_remove(de->norm_offset);
+	debugfs_remove(de->sharpen_duration);
+	debugfs_remove(de->sharpen_factor);
+	debugfs_remove(de->smoothing_shift);
+	debugfs_remove(de->coeff_d);
+	debugfs_remove(de->coeff_i);
+	debugfs_remove(de->coeff_p);
+	debugfs_remove(de->sampling_period);
+	debugfs_remove(de->target);
+	debugfs_remove(de->dir);
+#endif
+
+	kfree(pinfo->rinfo);
+	kfree(pinfo);
+}
+
+static void rate_control_pid_clear(void *priv)
+{
+}
+
+static void *rate_control_pid_alloc_sta(void *priv, gfp_t gfp)
+{
+	struct rc_pid_sta_info *spinfo;
+
+	spinfo = kzalloc(sizeof(*spinfo), gfp);
+	if (spinfo == NULL)
+		return NULL;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	spin_lock_init(&spinfo->events.lock);
+	init_waitqueue_head(&spinfo->events.waitqueue);
+#endif
+
+	return spinfo;
+}
+
+static void rate_control_pid_free_sta(void *priv, void *priv_sta)
+{
+	struct rc_pid_sta_info *spinfo = priv_sta;
+	kfree(spinfo);
+}
+
+struct rate_control_ops mac80211_rcpid = {
+	.name = "pid",
+	.tx_status = rate_control_pid_tx_status,
+	.get_rate = rate_control_pid_get_rate,
+	.rate_init = rate_control_pid_rate_init,
+	.clear = rate_control_pid_clear,
+	.alloc = rate_control_pid_alloc,
+	.free = rate_control_pid_free,
+	.alloc_sta = rate_control_pid_alloc_sta,
+	.free_sta = rate_control_pid_free_sta,
+#ifdef CONFIG_MAC80211_DEBUGFS
+	.add_sta_debugfs = rate_control_pid_add_sta_debugfs,
+	.remove_sta_debugfs = rate_control_pid_remove_sta_debugfs,
+#endif
+};
diff --git a/net/mac80211/rc80211_pid_debugfs.c b/net/mac80211/rc80211_pid_debugfs.c
new file mode 100644
index 0000000..91818e4
--- /dev/null
+++ b/net/mac80211/rc80211_pid_debugfs.c
@@ -0,0 +1,223 @@
+/*
+ * Copyright 2007, Mattias Nissler <mattias.nissler-Mmb7MZpHnFY@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/spinlock.h>
+#include <linux/poll.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+
+#include <net/mac80211.h>
+#include "ieee80211_rate.h"
+
+#include "rc80211_pid.h"
+
+static void rate_control_pid_event(struct rc_pid_event_buffer *buf,
+				   enum rc_pid_event_type type,
+				   union rc_pid_event_data *data)
+{
+	struct rc_pid_event *ev;
+	unsigned long status;
+
+	spin_lock_irqsave(&buf->lock, status);
+	ev = &(buf->ring[buf->next_entry]);
+	buf->next_entry = (buf->next_entry + 1) % RC_PID_EVENT_RING_SIZE;
+
+	ev->timestamp = jiffies;
+	ev->id = buf->ev_count++;
+	ev->type = type;
+	ev->data = *data;
+
+	spin_unlock_irqrestore(&buf->lock, status);
+
+	wake_up_all(&buf->waitqueue);
+}
+
+void rate_control_pid_event_tx_status(struct rc_pid_event_buffer *buf,
+					     struct ieee80211_tx_status *stat)
+{
+	union rc_pid_event_data evd;
+
+	memcpy(&evd.tx_status, stat, sizeof(struct ieee80211_tx_status));
+	rate_control_pid_event(buf, RC_PID_EVENT_TYPE_TX_STATUS, &evd);
+}
+
+void rate_control_pid_event_rate_change(struct rc_pid_event_buffer *buf,
+					       int index, int rate)
+{
+	union rc_pid_event_data evd;
+
+	evd.index = index;
+	evd.rate = rate;
+	rate_control_pid_event(buf, RC_PID_EVENT_TYPE_RATE_CHANGE, &evd);
+}
+
+void rate_control_pid_event_tx_rate(struct rc_pid_event_buffer *buf,
+					   int index, int rate)
+{
+	union rc_pid_event_data evd;
+
+	evd.index = index;
+	evd.rate = rate;
+	rate_control_pid_event(buf, RC_PID_EVENT_TYPE_TX_RATE, &evd);
+}
+
+void rate_control_pid_event_pf_sample(struct rc_pid_event_buffer *buf,
+					     s32 pf_sample, s32 prop_err,
+					     s32 int_err, s32 der_err)
+{
+	union rc_pid_event_data evd;
+
+	evd.pf_sample = pf_sample;
+	evd.prop_err = prop_err;
+	evd.int_err = int_err;
+	evd.der_err = der_err;
+	rate_control_pid_event(buf, RC_PID_EVENT_TYPE_PF_SAMPLE, &evd);
+}
+
+static int rate_control_pid_events_open(struct inode *inode, struct file *file)
+{
+	struct rc_pid_sta_info *sinfo = inode->i_private;
+	struct rc_pid_event_buffer *events = &sinfo->events;
+	struct rc_pid_events_file_info *file_info;
+	unsigned int status;
+
+	/* Allocate a state struct */
+	file_info = kmalloc(sizeof(*file_info), GFP_KERNEL);
+	if (file_info == NULL)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&events->lock, status);
+
+	file_info->next_entry = events->next_entry;
+	file_info->events = events;
+
+	spin_unlock_irqrestore(&events->lock, status);
+
+	file->private_data = file_info;
+
+	return 0;
+}
+
+static int rate_control_pid_events_release(struct inode *inode,
+					   struct file *file)
+{
+	struct rc_pid_events_file_info *file_info = file->private_data;
+
+	kfree(file_info);
+
+	return 0;
+}
+
+static unsigned int rate_control_pid_events_poll(struct file *file,
+						 poll_table *wait)
+{
+	struct rc_pid_events_file_info *file_info = file->private_data;
+
+	poll_wait(file, &file_info->events->waitqueue, wait);
+
+	return POLLIN | POLLRDNORM;
+}
+
+#define RC_PID_PRINT_BUF_SIZE 64
+
+static ssize_t rate_control_pid_events_read(struct file *file, char __user *buf,
+					    size_t length, loff_t *offset)
+{
+	struct rc_pid_events_file_info *file_info = file->private_data;
+	struct rc_pid_event_buffer *events = file_info->events;
+	struct rc_pid_event *ev;
+	char pb[RC_PID_PRINT_BUF_SIZE];
+	int ret;
+	int p;
+	unsigned int status;
+
+	/* Check if there is something to read. */
+	if (events->next_entry == file_info->next_entry) {
+		if (file->f_flags & O_NONBLOCK)
+			return -EAGAIN;
+
+		/* Wait */
+		ret = wait_event_interruptible(events->waitqueue,
+				events->next_entry != file_info->next_entry);
+
+		if (ret)
+			return ret;
+	}
+
+	/* Write out one event per call. I don't care whether it's a little
+	 * inefficient, this is debugging code anyway. */
+	spin_lock_irqsave(&events->lock, status);
+
+	/* Get an event */
+	ev = &(events->ring[file_info->next_entry]);
+	file_info->next_entry = (file_info->next_entry + 1) %
+				RC_PID_EVENT_RING_SIZE;
+
+	/* Print information about the event. Note that userpace needs to
+	 * provide large enough buffers. */
+	length = length < RC_PID_PRINT_BUF_SIZE ?
+		 length : RC_PID_PRINT_BUF_SIZE;
+	p = snprintf(pb, length, "%u %lu ", ev->id, ev->timestamp);
+	switch (ev->type) {
+	case RC_PID_EVENT_TYPE_TX_STATUS:
+		p += snprintf(pb + p, length - p, "tx_status %u %u",
+			      ev->data.tx_status.excessive_retries,
+			      ev->data.tx_status.retry_count);
+		break;
+	case RC_PID_EVENT_TYPE_RATE_CHANGE:
+		p += snprintf(pb + p, length - p, "rate_change %d %d",
+			      ev->data.index, ev->data.rate);
+		break;
+	case RC_PID_EVENT_TYPE_TX_RATE:
+		p += snprintf(pb + p, length - p, "tx_rate %d %d",
+			      ev->data.index, ev->data.rate);
+		break;
+	case RC_PID_EVENT_TYPE_PF_SAMPLE:
+		p += snprintf(pb + p, length - p,
+			      "pf_sample %d %d %d %d",
+			      ev->data.pf_sample, ev->data.prop_err,
+			      ev->data.int_err, ev->data.der_err);
+		break;
+	}
+	p += snprintf(pb + p, length - p, "\n");
+
+	spin_unlock_irqrestore(&events->lock, status);
+
+	if (copy_to_user(buf, pb, p))
+		return -EFAULT;
+
+	return p;
+}
+
+#undef RC_PID_PRINT_BUF_SIZE
+
+struct file_operations rc_pid_fop_events = {
+	.owner = THIS_MODULE,
+	.read = rate_control_pid_events_read,
+	.poll = rate_control_pid_events_poll,
+	.open = rate_control_pid_events_open,
+	.release = rate_control_pid_events_release,
+};
+
+void rate_control_pid_add_sta_debugfs(void *priv, void *priv_sta,
+					     struct dentry *dir)
+{
+	struct rc_pid_sta_info *spinfo = priv_sta;
+
+	spinfo->events_entry = debugfs_create_file("rc_pid_events", S_IRUGO,
+						   dir, spinfo,
+						   &rc_pid_fop_events);
+}
+
+void rate_control_pid_remove_sta_debugfs(void *priv, void *priv_sta)
+{
+	struct rc_pid_sta_info *spinfo = priv_sta;
+
+	debugfs_remove(spinfo->events_entry);
+}
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index da72737..c1c8b76 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -23,6 +23,8 @@
 /* This is a minimal implementation of TX rate controlling that can be used
  * as the default when no improved mechanisms are available. */
 
+#define RATE_CONTROL_NUM_DOWN 20
+#define RATE_CONTROL_NUM_UP   15
 
 #define RATE_CONTROL_EMERG_DEC 2
 #define RATE_CONTROL_INTERVAL (HZ / 20)
@@ -87,26 +89,6 @@ static void rate_control_rate_dec(struct ieee80211_local *local,
 	}
 }
 
-
-static struct ieee80211_rate *
-rate_control_lowest_rate(struct ieee80211_local *local,
-			 struct ieee80211_hw_mode *mode)
-{
-	int i;
-
-	for (i = 0; i < mode->num_rates; i++) {
-		struct ieee80211_rate *rate = &mode->rates[i];
-
-		if (rate->flags & IEEE80211_RATE_SUPPORTED)
-			return rate;
-	}
-
-	printk(KERN_DEBUG "rate_control_lowest_rate - no supported rates "
-	       "found\n");
-	return &mode->rates[0];
-}
-
-
 struct global_rate_control {
 	int dummy;
 };
@@ -216,56 +198,32 @@ static void rate_control_simple_tx_status(void *priv, struct net_device *dev,
 }
 
 
-static struct ieee80211_rate *
+static void
 rate_control_simple_get_rate(void *priv, struct net_device *dev,
+			     struct ieee80211_hw_mode *mode,
 			     struct sk_buff *skb,
-			     struct rate_control_extra *extra)
+			     struct rate_selection *sel)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	struct ieee80211_hw_mode *mode = extra->mode;
 	struct sta_info *sta;
-	int rateidx, nonerp_idx;
-	u16 fc;
-
-	memset(extra, 0, sizeof(*extra));
-
-	fc = le16_to_cpu(hdr->frame_control);
-	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
-	    (hdr->addr1[0] & 0x01)) {
-		/* Send management frames and broadcast/multicast data using
-		 * lowest rate. */
-		/* TODO: this could probably be improved.. */
-		return rate_control_lowest_rate(local, mode);
-	}
+	int rateidx;
 
 	sta = sta_info_get(local, hdr->addr1);
 
-	if (!sta)
-		return rate_control_lowest_rate(local, mode);
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1)
-		sta->txrate = sdata->bss->force_unicast_rateidx;
+	if (!sta) {
+		sel->rate = rate_lowest(local, mode, NULL);
+		return;
+	}
 
 	rateidx = sta->txrate;
 
 	if (rateidx >= mode->num_rates)
 		rateidx = mode->num_rates - 1;
 
-	sta->last_txrate = rateidx;
-	nonerp_idx = rateidx;
-	while (nonerp_idx > 0 &&
-	       ((mode->rates[nonerp_idx].flags & IEEE80211_RATE_ERP) ||
-		!(mode->rates[nonerp_idx].flags & IEEE80211_RATE_SUPPORTED) ||
-		!(sta->supp_rates & BIT(nonerp_idx))))
-		nonerp_idx--;
-	extra->nonerp = &mode->rates[nonerp_idx];
-
 	sta_info_put(sta);
 
-	return &mode->rates[rateidx];
+	sel->rate = &mode->rates[rateidx];
 }
 
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index b12d019..9afb253 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -61,8 +61,10 @@ static inline int should_drop_frame(struct ieee80211_rx_status *status,
 		return 1;
 	if (unlikely(skb->len < 16 + present_fcs_len + radiotap_len))
 		return 1;
-	if ((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
-			cpu_to_le16(IEEE80211_FTYPE_CTL))
+	if (((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_FTYPE)) ==
+			cpu_to_le16(IEEE80211_FTYPE_CTL)) &&
+	    ((hdr->frame_control & cpu_to_le16(IEEE80211_FCTL_STYPE)) !=
+			cpu_to_le16(IEEE80211_STYPE_PSPOLL)))
 		return 1;
 	return 0;
 }
@@ -206,7 +208,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 		rthdr->it_len = cpu_to_le16(rtap_len);
 	}
 
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
@@ -403,18 +405,6 @@ ieee80211_rx_h_check(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 	}
 
-	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
-		rx->skb->pkt_type = PACKET_OTHERHOST;
-	else if (compare_ether_addr(rx->dev->dev_addr, hdr->addr1) == 0)
-		rx->skb->pkt_type = PACKET_HOST;
-	else if (is_multicast_ether_addr(hdr->addr1)) {
-		if (is_broadcast_ether_addr(hdr->addr1))
-			rx->skb->pkt_type = PACKET_BROADCAST;
-		else
-			rx->skb->pkt_type = PACKET_MULTICAST;
-	} else
-		rx->skb->pkt_type = PACKET_OTHERHOST;
-
 	/* Drop disallowed frame classes based on STA auth/assoc state;
 	 * IEEE 802.11, Chap 5.5.
 	 *
@@ -896,6 +886,7 @@ ieee80211_rx_h_defragment(struct ieee80211_txrx_data *rx)
 static ieee80211_txrx_result
 ieee80211_rx_h_ps_poll(struct ieee80211_txrx_data *rx)
 {
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
 	struct sk_buff *skb;
 	int no_pending_pkts;
 	DECLARE_MAC_BUF(mac);
@@ -906,6 +897,10 @@ ieee80211_rx_h_ps_poll(struct ieee80211_txrx_data *rx)
 		   !(rx->flags & IEEE80211_TXRXD_RXRA_MATCH)))
 		return TXRX_CONTINUE;
 
+	if ((sdata->type != IEEE80211_IF_TYPE_AP) &&
+	    (sdata->type != IEEE80211_IF_TYPE_VLAN))
+		return TXRX_DROP;
+
 	skb = skb_dequeue(&rx->sta->tx_filtered);
 	if (!skb) {
 		skb = skb_dequeue(&rx->sta->ps_tx_buf);
@@ -983,18 +978,10 @@ ieee80211_rx_h_remove_qos_control(struct ieee80211_txrx_data *rx)
 }
 
 static int
-ieee80211_drop_802_1x_pae(struct ieee80211_txrx_data *rx, int hdrlen)
+ieee80211_802_1x_port_control(struct ieee80211_txrx_data *rx)
 {
-	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb, hdrlen) &&
-	    rx->sdata->type != IEEE80211_IF_TYPE_STA &&
-	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
-		return 0;
-
-	if (unlikely(rx->sdata->ieee802_1x &&
-		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
-		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)) &&
-		     !ieee80211_is_eapol(rx->skb, hdrlen))) {
+	if (unlikely(rx->sdata->ieee802_1x_pac &&
+		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)))) {
 #ifdef CONFIG_MAC80211_DEBUG
 		printk(KERN_DEBUG "%s: dropped frame "
 		       "(unauthorized port)\n", rx->dev->name);
@@ -1006,7 +993,7 @@ ieee80211_drop_802_1x_pae(struct ieee80211_txrx_data *rx, int hdrlen)
 }
 
 static int
-ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx, int hdrlen)
+ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx)
 {
 	/*
 	 * Pass through unencrypted frames if the hardware has
@@ -1019,9 +1006,7 @@ ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx, int hdrlen)
 	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     (rx->key || rx->sdata->drop_unencrypted) &&
-		     (rx->sdata->eapol == 0 ||
-		      !ieee80211_is_eapol(rx->skb, hdrlen)))) {
+		     (rx->key || rx->sdata->drop_unencrypted))) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: RX non-WEP frame, but expected "
 			       "encryption\n", rx->dev->name);
@@ -1149,6 +1134,7 @@ ieee80211_data_to_8023(struct ieee80211_txrx_data *rx)
 	} else {
 		struct ethhdr *ehdr;
 		__be16 len;
+
 		skb_pull(skb, hdrlen);
 		len = htons(skb->len);
 		ehdr = (struct ethhdr *) skb_push(skb, sizeof(struct ethhdr));
@@ -1159,6 +1145,34 @@ ieee80211_data_to_8023(struct ieee80211_txrx_data *rx)
 	return 0;
 }
 
+/*
+ * requires that rx->skb is a frame with ethernet header
+ */
+static bool ieee80211_frame_allowed(struct ieee80211_txrx_data *rx)
+{
+	static const u8 pae_group_addr[ETH_ALEN]
+		= { 0x01, 0x80, 0xC2, 0x00, 0x00, 0x03 };
+	struct ethhdr *ehdr = (struct ethhdr *) rx->skb->data;
+
+	/*
+	 * Allow EAPOL frames to us/the PAE group address regardless
+	 * of whether the frame was encrypted or not.
+	 */
+	if (ehdr->h_proto == htons(ETH_P_PAE) &&
+	    (compare_ether_addr(ehdr->h_dest, rx->dev->dev_addr) == 0 ||
+	     compare_ether_addr(ehdr->h_dest, pae_group_addr) == 0))
+		return true;
+
+	if (ieee80211_802_1x_port_control(rx) ||
+	    ieee80211_drop_unencrypted(rx))
+		return false;
+
+	return true;
+}
+
+/*
+ * requires that rx->skb is a frame with ethernet header
+ */
 static void
 ieee80211_deliver_skb(struct ieee80211_txrx_data *rx)
 {
@@ -1166,31 +1180,32 @@ ieee80211_deliver_skb(struct ieee80211_txrx_data *rx)
 	struct ieee80211_local *local = rx->local;
 	struct sk_buff *skb, *xmit_skb;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ethhdr *ehdr = (struct ethhdr *) rx->skb->data;
+	struct sta_info *dsta;
 
 	skb = rx->skb;
 	xmit_skb = NULL;
 
-	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
-	    || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
+	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP ||
+				      sdata->type == IEEE80211_IF_TYPE_VLAN) &&
 	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
-		if (is_multicast_ether_addr(skb->data)) {
-			/* send multicast frames both to higher layers in
-			 * local net stack and back to the wireless media */
+		if (is_multicast_ether_addr(ehdr->h_dest)) {
+			/*
+			 * send multicast frames both to higher layers in
+			 * local net stack and back to the wireless medium
+			 */
 			xmit_skb = skb_copy(skb, GFP_ATOMIC);
 			if (!xmit_skb && net_ratelimit())
 				printk(KERN_DEBUG "%s: failed to clone "
 				       "multicast frame\n", dev->name);
 		} else {
-			struct sta_info *dsta;
 			dsta = sta_info_get(local, skb->data);
-			if (dsta && !dsta->dev) {
-				if (net_ratelimit())
-					printk(KERN_DEBUG "Station with null "
-					       "dev structure!\n");
-			} else if (dsta && dsta->dev == dev) {
-				/* Destination station is associated to this
-				 * AP, so send the frame directly to it and
-				 * do not pass the frame to local net stack.
+			if (dsta && dsta->dev == dev) {
+				/*
+				 * The destination station is associated to
+				 * this AP (in this VLAN), so send the frame
+				 * directly to it and do not pass it to local
+				 * net stack.
 				 */
 				xmit_skb = skb;
 				skb = NULL;
@@ -1210,8 +1225,8 @@ ieee80211_deliver_skb(struct ieee80211_txrx_data *rx)
 	if (xmit_skb) {
 		/* send to wireless media */
 		xmit_skb->protocol = htons(ETH_P_802_3);
-		skb_set_network_header(xmit_skb, 0);
-		skb_set_mac_header(xmit_skb, 0);
+		skb_reset_network_header(xmit_skb);
+		skb_reset_mac_header(xmit_skb);
 		dev_queue_xmit(xmit_skb);
 	}
 }
@@ -1296,38 +1311,36 @@ ieee80211_rx_h_amsdu(struct ieee80211_txrx_data *rx)
 			}
 		}
 
-		skb_set_network_header(frame, 0);
+		skb_reset_network_header(frame);
 		frame->dev = dev;
 		frame->priority = skb->priority;
 		rx->skb = frame;
 
-		if ((ieee80211_drop_802_1x_pae(rx, 0)) ||
-		    (ieee80211_drop_unencrypted(rx, 0))) {
-			if (skb == frame) /* last frame */
-				return TXRX_DROP;
-			dev_kfree_skb(frame);
-			continue;
-		}
-
 		payload = frame->data;
 		ethertype = (payload[6] << 8) | payload[7];
 
 		if (likely((compare_ether_addr(payload, rfc1042_header) == 0 &&
-			ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
-			compare_ether_addr(payload,
-					   bridge_tunnel_header) == 0)) {
+			    ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
+			   compare_ether_addr(payload,
+					      bridge_tunnel_header) == 0)) {
 			/* remove RFC1042 or Bridge-Tunnel
 			 * encapsulation and replace EtherType */
 			skb_pull(frame, 6);
 			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
 			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
 		} else {
-			memcpy(skb_push(frame, sizeof(__be16)), &len,
-				sizeof(__be16));
+			memcpy(skb_push(frame, sizeof(__be16)),
+			       &len, sizeof(__be16));
 			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
 			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
 		}
 
+		if (!ieee80211_frame_allowed(rx)) {
+			if (skb == frame) /* last frame */
+				return TXRX_DROP;
+			dev_kfree_skb(frame);
+			continue;
+		}
 
 		ieee80211_deliver_skb(rx);
 	}
@@ -1340,7 +1353,7 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 {
 	struct net_device *dev = rx->dev;
 	u16 fc;
-	int err, hdrlen;
+	int err;
 
 	fc = rx->fc;
 	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
@@ -1349,16 +1362,13 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
 		return TXRX_DROP;
 
-	hdrlen = ieee80211_get_hdrlen(fc);
-
-	if ((ieee80211_drop_802_1x_pae(rx, hdrlen)) ||
-	    (ieee80211_drop_unencrypted(rx, hdrlen)))
-		return TXRX_DROP;
-
 	err = ieee80211_data_to_8023(rx);
 	if (unlikely(err))
 		return TXRX_DROP;
 
+	if (!ieee80211_frame_allowed(rx))
+		return TXRX_DROP;
+
 	rx->skb->dev = dev;
 
 	dev->stats.rx_packets++;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 12c1558..8302c70 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -261,18 +261,6 @@ ieee80211_tx_h_check_assoc(struct ieee80211_txrx_data *tx)
 		return TXRX_CONTINUE;
 	}
 
-	if (unlikely(/* !injected && */ tx->sdata->ieee802_1x &&
-		     !(sta_flags & WLAN_STA_AUTHORIZED))) {
-#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		DECLARE_MAC_BUF(mac);
-		printk(KERN_DEBUG "%s: dropped frame to %s"
-		       " (unauthorized port)\n", tx->dev->name,
-		       print_mac(mac, hdr->addr1));
-#endif
-		I802_DEBUG_INC(tx->local->tx_handlers_drop_unauth_port);
-		return TXRX_DROP;
-	}
-
 	return TXRX_CONTINUE;
 }
 
@@ -334,16 +322,27 @@ static void purge_old_ps_buffers(struct ieee80211_local *local)
 	       wiphy_name(local->hw.wiphy), purged);
 }
 
-static inline ieee80211_txrx_result
+static ieee80211_txrx_result
 ieee80211_tx_h_multicast_ps_buf(struct ieee80211_txrx_data *tx)
 {
-	/* broadcast/multicast frame */
-	/* If any of the associated stations is in power save mode,
-	 * the frame is buffered to be sent after DTIM beacon frame */
-	if ((tx->local->hw.flags & IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING) &&
-	    tx->sdata->type != IEEE80211_IF_TYPE_WDS &&
-	    tx->sdata->bss && atomic_read(&tx->sdata->bss->num_sta_ps) &&
-	    !(tx->fc & IEEE80211_FCTL_ORDER)) {
+	/*
+	 * broadcast/multicast frame
+	 *
+	 * If any of the associated stations is in power save mode,
+	 * the frame is buffered to be sent after DTIM beacon frame.
+	 * This is done either by the hardware or us.
+	 */
+
+	/* not AP/IBSS or ordered frame */
+	if (!tx->sdata->bss || (tx->fc & IEEE80211_FCTL_ORDER))
+		return TXRX_CONTINUE;
+
+	/* no stations in PS mode */
+	if (!atomic_read(&tx->sdata->bss->num_sta_ps))
+		return TXRX_CONTINUE;
+
+	/* buffered in mac80211 */
+	if (tx->local->hw.flags & IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING) {
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
 			purge_old_ps_buffers(tx->local);
 		if (skb_queue_len(&tx->sdata->bss->ps_bc_buf) >=
@@ -360,10 +359,13 @@ ieee80211_tx_h_multicast_ps_buf(struct ieee80211_txrx_data *tx)
 		return TXRX_QUEUED;
 	}
 
+	/* buffered in hardware */
+	tx->u.tx.control->flags |= IEEE80211_TXCTL_SEND_AFTER_DTIM;
+
 	return TXRX_CONTINUE;
 }
 
-static inline ieee80211_txrx_result
+static ieee80211_txrx_result
 ieee80211_tx_h_unicast_ps_buf(struct ieee80211_txrx_data *tx)
 {
 	struct sta_info *sta = tx->sta;
@@ -436,11 +438,7 @@ static ieee80211_txrx_result
 ieee80211_tx_h_select_key(struct ieee80211_txrx_data *tx)
 {
 	struct ieee80211_key *key;
-	const struct ieee80211_hdr *hdr;
-	u16 fc;
-
-	hdr = (const struct ieee80211_hdr *) tx->skb->data;
-	fc = le16_to_cpu(hdr->frame_control);
+	u16 fc = tx->fc;
 
 	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
@@ -449,20 +447,38 @@ ieee80211_tx_h_select_key(struct ieee80211_txrx_data *tx)
 	else if ((key = rcu_dereference(tx->sdata->default_key)))
 		tx->key = key;
 	else if (tx->sdata->drop_unencrypted &&
-		 !(tx->sdata->eapol &&
-		   ieee80211_is_eapol(tx->skb, ieee80211_get_hdrlen(fc)))) {
+		 !(tx->u.tx.control->flags & IEEE80211_TXCTL_EAPOL_FRAME) &&
+		 !(tx->flags & IEEE80211_TXRXD_TX_INJECTED)) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TXRX_DROP;
-	} else {
+	} else
 		tx->key = NULL;
-		tx->u.tx.control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-	}
 
 	if (tx->key) {
+		u16 ftype, stype;
+
 		tx->key->tx_rx_count++;
 		/* TODO: add threshold stuff again */
+
+		switch (tx->key->conf.alg) {
+		case ALG_WEP:
+			ftype = fc & IEEE80211_FCTL_FTYPE;
+			stype = fc & IEEE80211_FCTL_STYPE;
+
+			if (ftype == IEEE80211_FTYPE_MGMT &&
+			    stype == IEEE80211_STYPE_AUTH)
+				break;
+		case ALG_TKIP:
+		case ALG_CCMP:
+			if (!WLAN_FC_DATA_PRESENT(fc))
+				tx->key = NULL;
+			break;
+		}
 	}
 
+	if (!tx->key || !(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
+		tx->u.tx.control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
+
 	return TXRX_CONTINUE;
 }
 
@@ -569,21 +585,17 @@ ieee80211_tx_h_encrypt(struct ieee80211_txrx_data *tx)
 static ieee80211_txrx_result
 ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 {
-	struct rate_control_extra extra;
+	struct rate_selection rsel;
 
 	if (likely(!tx->u.tx.rate)) {
-		memset(&extra, 0, sizeof(extra));
-		extra.mode = tx->u.tx.mode;
-		extra.ethertype = tx->ethertype;
-
-		tx->u.tx.rate = rate_control_get_rate(tx->local, tx->dev,
-						      tx->skb, &extra);
-		if (unlikely(extra.probe != NULL)) {
+		rate_control_get_rate(tx->dev, tx->u.tx.mode, tx->skb, &rsel);
+		tx->u.tx.rate = rsel.rate;
+		if (unlikely(rsel.probe != NULL)) {
 			tx->u.tx.control->flags |=
 				IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			tx->flags |= IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
 			tx->u.tx.control->alt_retry_rate = tx->u.tx.rate->val;
-			tx->u.tx.rate = extra.probe;
+			tx->u.tx.rate = rsel.probe;
 		} else
 			tx->u.tx.control->alt_retry_rate = -1;
 
@@ -594,14 +606,14 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 
 	if (tx->u.tx.mode->mode == MODE_IEEE80211G &&
 	    (tx->sdata->flags & IEEE80211_SDATA_USE_PROTECTION) &&
-	    (tx->flags & IEEE80211_TXRXD_FRAGMENTED) && extra.nonerp) {
+	    (tx->flags & IEEE80211_TXRXD_FRAGMENTED) && rsel.nonerp) {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
-		if (extra.probe)
+		if (rsel.probe)
 			tx->flags &= ~IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
 		else
 			tx->flags |= IEEE80211_TXRXD_TXPROBE_LAST_FRAG;
-		tx->u.tx.rate = extra.nonerp;
-		tx->u.tx.control->rate = extra.nonerp;
+		tx->u.tx.rate = rsel.nonerp;
+		tx->u.tx.control->rate = rsel.nonerp;
 		tx->u.tx.control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 	} else {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
@@ -708,15 +720,6 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 		}
 	}
 
-	/*
-	 * Tell hardware to not encrypt when we had sw crypto.
-	 * Because we use the same flag to internally indicate that
-	 * no (software) encryption should be done, we have to set it
-	 * after all crypto handlers.
-	 */
-	if (tx->key && !(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
-		tx->u.tx.control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-
 	return TXRX_CONTINUE;
 }
 
@@ -1258,6 +1261,8 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	if (pkt_data->flags & IEEE80211_TXPD_REQUEUE)
 		control.flags |= IEEE80211_TXCTL_REQUEUE;
+	if (pkt_data->flags & IEEE80211_TXPD_EAPOL_FRAME)
+		control.flags |= IEEE80211_TXCTL_EAPOL_FRAME;
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control);
@@ -1350,6 +1355,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	int encaps_len, skip_header_bytes;
 	int nh_pos, h_pos;
 	struct sta_info *sta;
+	u32 sta_flags = 0;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (unlikely(skb->len < ETH_HLEN)) {
@@ -1365,7 +1371,6 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	/* convert Ethernet header to proper 802.11 header (based on
 	 * operation mode) */
 	ethertype = (skb->data[12] << 8) | skb->data[13];
-	/* TODO: handling for 802.1x authorized/unauthorized port */
 	fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
 
 	switch (sdata->type) {
@@ -1407,16 +1412,42 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 		goto fail;
 	}
 
-	/* receiver is QoS enabled, use a QoS type frame */
 	sta = sta_info_get(local, hdr.addr1);
 	if (sta) {
-		if (sta->flags & WLAN_STA_WME) {
-			fc |= IEEE80211_STYPE_QOS_DATA;
-			hdrlen += 2;
-		}
+		sta_flags = sta->flags;
 		sta_info_put(sta);
 	}
 
+	/* receiver is QoS enabled, use a QoS type frame */
+	if (sta_flags & WLAN_STA_WME) {
+		fc |= IEEE80211_STYPE_QOS_DATA;
+		hdrlen += 2;
+	}
+
+	/*
+	 * If port access control is enabled, drop frames to unauthorised
+	 * stations unless they are EAPOL frames from the local station.
+	 */
+	if (unlikely(sdata->ieee802_1x_pac &&
+		     !(sta_flags & WLAN_STA_AUTHORIZED) &&
+		     !(ethertype == ETH_P_PAE &&
+		       compare_ether_addr(dev->dev_addr,
+					  skb->data + ETH_ALEN) == 0))) {
+#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
+		DECLARE_MAC_BUF(mac);
+
+		if (net_ratelimit())
+			printk(KERN_DEBUG "%s: dropped frame to %s"
+			       " (unauthorized port)\n", dev->name,
+			       print_mac(mac, hdr.addr1));
+#endif
+
+		I802_DEBUG_INC(local->tx_handlers_drop_unauth_port);
+
+		ret = 0;
+		goto fail;
+	}
+
 	hdr.frame_control = cpu_to_le16(fc);
 	hdr.duration_id = 0;
 	hdr.seq_ctrl = 0;
@@ -1505,6 +1536,8 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = dev->ifindex;
+	if (ethertype == ETH_P_PAE)
+		pkt_data->flags |= IEEE80211_TXPD_EAPOL_FRAME;
 
 	skb->dev = local->mdev;
 	dev->stats.tx_packets++;
@@ -1667,8 +1700,7 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw, int if_id,
 	struct net_device *bdev;
 	struct ieee80211_sub_if_data *sdata = NULL;
 	struct ieee80211_if_ap *ap = NULL;
-	struct ieee80211_rate *rate;
-	struct rate_control_extra extra;
+	struct rate_selection rsel;
 	u8 *b_head, *b_tail;
 	int bh_len, bt_len;
 
@@ -1712,14 +1744,13 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw, int if_id,
 	}
 
 	if (control) {
-		memset(&extra, 0, sizeof(extra));
-		extra.mode = local->oper_hw_mode;
-
-		rate = rate_control_get_rate(local, local->mdev, skb, &extra);
-		if (!rate) {
+		rate_control_get_rate(local->mdev, local->oper_hw_mode, skb,
+				      &rsel);
+		if (!rsel.rate) {
 			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
-				       "found\n", wiphy_name(local->hw.wiphy));
+				printk(KERN_DEBUG "%s: ieee80211_beacon_get: "
+				       "no rate found\n",
+				       wiphy_name(local->hw.wiphy));
 			}
 			dev_kfree_skb(skb);
 			return NULL;
@@ -1727,8 +1758,8 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw, int if_id,
 
 		control->tx_rate =
 			((sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE) &&
-			(rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
-			rate->val2 : rate->val;
+			(rsel.rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
+			rsel.rate->val2 : rsel.rate->val;
 		control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control->power_level = local->hw.conf.power_level;
 		control->flags |= IEEE80211_TXCTL_NO_ACK;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 7b278e9..2b02b2b 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -40,10 +40,6 @@ const unsigned char rfc1042_header[] =
 const unsigned char bridge_tunnel_header[] =
 	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
 
-/* No encapsulation header if EtherType < 0x600 (=length) */
-static const unsigned char eapol_header[] =
-	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
-
 
 static int rate_list_match(const int *rate_list, int rate)
 {
@@ -135,13 +131,16 @@ u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
 {
 	u16 fc;
 
-	if (len < 24)
+	 /* drop ACK/CTS frames and incorrect hdr len (ctrl) */
+	if (len < 16)
 		return NULL;
 
 	fc = le16_to_cpu(hdr->frame_control);
 
 	switch (fc & IEEE80211_FCTL_FTYPE) {
 	case IEEE80211_FTYPE_DATA:
+		if (len < 24) /* drop incorrect hdr len (data) */
+			return NULL;
 		switch (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
 		case IEEE80211_FCTL_TODS:
 			return hdr->addr1;
@@ -154,6 +153,8 @@ u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
 		}
 		break;
 	case IEEE80211_FTYPE_MGMT:
+		if (len < 24) /* drop incorrect hdr len (mgmt) */
+			return NULL;
 		return hdr->addr3;
 	case IEEE80211_FTYPE_CTL:
 		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)
@@ -218,19 +219,6 @@ int ieee80211_get_hdrlen_from_skb(const struct sk_buff *skb)
 }
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
-int ieee80211_is_eapol(const struct sk_buff *skb, int hdrlen)
-{
-	if (unlikely(skb->len < 10))
-		return 0;
-
-	if (unlikely(skb->len >= hdrlen + sizeof(eapol_header) &&
-		     memcmp(skb->data + hdrlen, eapol_header,
-			    sizeof(eapol_header)) == 0))
-		return 1;
-
-	return 0;
-}
-
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
diff --git a/net/mac80211/wep.c b/net/mac80211/wep.c
index b5f3413..a0cff72 100644
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -349,16 +349,6 @@ static int wep_encrypt_skb(struct ieee80211_txrx_data *tx, struct sk_buff *skb)
 ieee80211_txrx_result
 ieee80211_crypto_wep_encrypt(struct ieee80211_txrx_data *tx)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
-	u16 fc;
-
-	fc = le16_to_cpu(hdr->frame_control);
-
-	if (((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA &&
-	     ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
-	      (fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_AUTH)))
-		return TXRX_CONTINUE;
-
 	tx->u.tx.control->iv_len = WEP_IV_LEN;
 	tx->u.tx.control->icv_len = WEP_ICV_LEN;
 	ieee80211_tx_set_iswep(tx);
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 20cec1c..6f04311 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -245,16 +245,9 @@ static int tkip_encrypt_skb(struct ieee80211_txrx_data *tx,
 ieee80211_txrx_result
 ieee80211_crypto_tkip_encrypt(struct ieee80211_txrx_data *tx)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
-	u16 fc;
 	struct sk_buff *skb = tx->skb;
 	int wpa_test = 0, test = 0;
 
-	fc = le16_to_cpu(hdr->frame_control);
-
-	if (!WLAN_FC_DATA_PRESENT(fc))
-		return TXRX_CONTINUE;
-
 	tx->u.tx.control->icv_len = TKIP_ICV_LEN;
 	tx->u.tx.control->iv_len = TKIP_IV_LEN;
 	ieee80211_tx_set_iswep(tx);
@@ -501,16 +494,9 @@ static int ccmp_encrypt_skb(struct ieee80211_txrx_data *tx,
 ieee80211_txrx_result
 ieee80211_crypto_ccmp_encrypt(struct ieee80211_txrx_data *tx)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
-	u16 fc;
 	struct sk_buff *skb = tx->skb;
 	int test = 0;
 
-	fc = le16_to_cpu(hdr->frame_control);
-
-	if (!WLAN_FC_DATA_PRESENT(fc))
-		return TXRX_CONTINUE;
-
 	tx->u.tx.control->icv_len = CCMP_MIC_LEN;
 	tx->u.tx.control->iv_len = CCMP_HDR_LEN;
 	ieee80211_tx_set_iswep(tx);
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index 6426055..7927090 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -6,13 +6,13 @@ config NL80211
 	depends on CFG80211
 	default y
 	---help---
-         This option turns on the new netlink interface
-         (nl80211) support in cfg80211.
+	  This option turns on the new netlink interface
+	  (nl80211) support in cfg80211.
 
-         If =n, drivers using mac80211 will be configured via
-         wireless extension support provided by that subsystem.
+	  If =n, drivers using mac80211 will be configured via
+	  wireless extension support provided by that subsystem.
 
-         If unsure, say Y.
+	  If unsure, say Y.
 
 config WIRELESS_EXT
 	bool "Wireless extensions"
diff --git a/net/wireless/core.c b/net/wireless/core.c
index febc33b..cfc5fc5 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -184,6 +184,9 @@ struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
 	struct cfg80211_registered_device *drv;
 	int alloc_size;
 
+	WARN_ON(!ops->add_key && ops->del_key);
+	WARN_ON(ops->add_key && !ops->del_key);
+
 	alloc_size = sizeof(*drv) + sizeof_priv;
 
 	drv = kzalloc(alloc_size, GFP_KERNEL);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 48b0d45..e3a214f 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -61,6 +61,27 @@ static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
 	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
 	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
 	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
+
+	[NL80211_ATTR_MAC] = { .type = NLA_BINARY, .len = ETH_ALEN },
+
+	[NL80211_ATTR_KEY_DATA] = { .type = NLA_BINARY,
+				    .len = WLAN_MAX_KEY_LEN },
+	[NL80211_ATTR_KEY_IDX] = { .type = NLA_U8 },
+	[NL80211_ATTR_KEY_CIPHER] = { .type = NLA_U32 },
+	[NL80211_ATTR_KEY_DEFAULT] = { .type = NLA_FLAG },
+
+	[NL80211_ATTR_BEACON_INTERVAL] = { .type = NLA_U32 },
+	[NL80211_ATTR_DTIM_PERIOD] = { .type = NLA_U32 },
+	[NL80211_ATTR_BEACON_HEAD] = { .type = NLA_BINARY,
+				       .len = IEEE80211_MAX_DATA_LEN },
+	[NL80211_ATTR_BEACON_TAIL] = { .type = NLA_BINARY,
+				       .len = IEEE80211_MAX_DATA_LEN },
+	[NL80211_ATTR_STA_AID] = { .type = NLA_U16 },
+	[NL80211_ATTR_STA_FLAGS] = { .type = NLA_NESTED },
+	[NL80211_ATTR_STA_LISTEN_INTERVAL] = { .type = NLA_U16 },
+	[NL80211_ATTR_STA_SUPPORTED_RATES] = { .type = NLA_BINARY,
+					       .len = NL80211_MAX_SUPP_RATES },
+	[NL80211_ATTR_STA_VLAN] = { .type = NLA_U32 },
 };
 
 /* message building helper */
@@ -335,6 +356,655 @@ static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+struct get_key_cookie {
+	struct sk_buff *msg;
+	int error;
+};
+
+static void get_key_callback(void *c, struct key_params *params)
+{
+	struct get_key_cookie *cookie = c;
+
+	if (params->key)
+		NLA_PUT(cookie->msg, NL80211_ATTR_KEY_DATA,
+			params->key_len, params->key);
+
+	if (params->seq)
+		NLA_PUT(cookie->msg, NL80211_ATTR_KEY_SEQ,
+			params->seq_len, params->seq);
+
+	if (params->cipher)
+		NLA_PUT_U32(cookie->msg, NL80211_ATTR_KEY_CIPHER,
+			    params->cipher);
+
+	return;
+ nla_put_failure:
+	cookie->error = 1;
+}
+
+static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	u8 key_idx = 0;
+	u8 *mac_addr = NULL;
+	struct get_key_cookie cookie = {
+		.error = 0,
+	};
+	void *hdr;
+	struct sk_buff *msg;
+
+	if (info->attrs[NL80211_ATTR_KEY_IDX])
+		key_idx = nla_get_u8(info->attrs[NL80211_ATTR_KEY_IDX]);
+
+	if (key_idx > 3)
+		return -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_MAC])
+		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->get_key) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+			     NL80211_CMD_NEW_KEY);
+
+	if (IS_ERR(hdr)) {
+		err = PTR_ERR(hdr);
+		goto out;
+	}
+
+	cookie.msg = msg;
+
+	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, dev->ifindex);
+	NLA_PUT_U8(msg, NL80211_ATTR_KEY_IDX, key_idx);
+	if (mac_addr)
+		NLA_PUT(msg, NL80211_ATTR_MAC, ETH_ALEN, mac_addr);
+
+	rtnl_lock();
+	err = drv->ops->get_key(&drv->wiphy, dev, key_idx, mac_addr,
+				&cookie, get_key_callback);
+	rtnl_unlock();
+
+	if (err)
+		goto out;
+
+	if (cookie.error)
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	err = genlmsg_unicast(msg, info->snd_pid);
+	goto out;
+
+ nla_put_failure:
+	err = -ENOBUFS;
+	nlmsg_free(msg);
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_set_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	u8 key_idx;
+
+	if (!info->attrs[NL80211_ATTR_KEY_IDX])
+		return -EINVAL;
+
+	key_idx = nla_get_u8(info->attrs[NL80211_ATTR_KEY_IDX]);
+
+	if (key_idx > 3)
+		return -EINVAL;
+
+	/* currently only support setting default key */
+	if (!info->attrs[NL80211_ATTR_KEY_DEFAULT])
+		return -EINVAL;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->set_default_key) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->set_default_key(&drv->wiphy, dev, key_idx);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_new_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	struct key_params params;
+	u8 key_idx = 0;
+	u8 *mac_addr = NULL;
+
+	memset(&params, 0, sizeof(params));
+
+	if (!info->attrs[NL80211_ATTR_KEY_CIPHER])
+		return -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_KEY_DATA]) {
+		params.key = nla_data(info->attrs[NL80211_ATTR_KEY_DATA]);
+		params.key_len = nla_len(info->attrs[NL80211_ATTR_KEY_DATA]);
+	}
+
+	if (info->attrs[NL80211_ATTR_KEY_IDX])
+		key_idx = nla_get_u8(info->attrs[NL80211_ATTR_KEY_IDX]);
+
+	params.cipher = nla_get_u32(info->attrs[NL80211_ATTR_KEY_CIPHER]);
+
+	if (info->attrs[NL80211_ATTR_MAC])
+		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	if (key_idx > 3)
+		return -EINVAL;
+
+	/*
+	 * Disallow pairwise keys with non-zero index unless it's WEP
+	 * (because current deployments use pairwise WEP keys with
+	 * non-zero indizes but 802.11i clearly specifies to use zero)
+	 */
+	if (mac_addr && key_idx &&
+	    params.cipher != WLAN_CIPHER_SUITE_WEP40 &&
+	    params.cipher != WLAN_CIPHER_SUITE_WEP104)
+		return -EINVAL;
+
+	/* TODO: add definitions for the lengths to linux/ieee80211.h */
+	switch (params.cipher) {
+	case WLAN_CIPHER_SUITE_WEP40:
+		if (params.key_len != 5)
+			return -EINVAL;
+		break;
+	case WLAN_CIPHER_SUITE_TKIP:
+		if (params.key_len != 32)
+			return -EINVAL;
+		break;
+	case WLAN_CIPHER_SUITE_CCMP:
+		if (params.key_len != 16)
+			return -EINVAL;
+		break;
+	case WLAN_CIPHER_SUITE_WEP104:
+		if (params.key_len != 13)
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->add_key) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->add_key(&drv->wiphy, dev, key_idx, mac_addr, &params);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_del_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	u8 key_idx = 0;
+	u8 *mac_addr = NULL;
+
+	if (info->attrs[NL80211_ATTR_KEY_IDX])
+		key_idx = nla_get_u8(info->attrs[NL80211_ATTR_KEY_IDX]);
+
+	if (key_idx > 3)
+		return -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_MAC])
+		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->del_key) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->del_key(&drv->wiphy, dev, key_idx, mac_addr);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_addset_beacon(struct sk_buff *skb, struct genl_info *info)
+{
+        int (*call)(struct wiphy *wiphy, struct net_device *dev,
+		    struct beacon_parameters *info);
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	struct beacon_parameters params;
+	int haveinfo = 0;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	switch (info->genlhdr->cmd) {
+	case NL80211_CMD_NEW_BEACON:
+		/* these are required for NEW_BEACON */
+		if (!info->attrs[NL80211_ATTR_BEACON_INTERVAL] ||
+		    !info->attrs[NL80211_ATTR_DTIM_PERIOD] ||
+		    !info->attrs[NL80211_ATTR_BEACON_HEAD]) {
+			err = -EINVAL;
+			goto out;
+		}
+
+		call = drv->ops->add_beacon;
+		break;
+	case NL80211_CMD_SET_BEACON:
+		call = drv->ops->set_beacon;
+		break;
+	default:
+		WARN_ON(1);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (!call) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	memset(&params, 0, sizeof(params));
+
+	if (info->attrs[NL80211_ATTR_BEACON_INTERVAL]) {
+		params.interval =
+		    nla_get_u32(info->attrs[NL80211_ATTR_BEACON_INTERVAL]);
+		haveinfo = 1;
+	}
+
+	if (info->attrs[NL80211_ATTR_DTIM_PERIOD]) {
+		params.dtim_period =
+		    nla_get_u32(info->attrs[NL80211_ATTR_DTIM_PERIOD]);
+		haveinfo = 1;
+	}
+
+	if (info->attrs[NL80211_ATTR_BEACON_HEAD]) {
+		params.head = nla_data(info->attrs[NL80211_ATTR_BEACON_HEAD]);
+		params.head_len =
+		    nla_len(info->attrs[NL80211_ATTR_BEACON_HEAD]);
+		haveinfo = 1;
+	}
+
+	if (info->attrs[NL80211_ATTR_BEACON_TAIL]) {
+		params.tail = nla_data(info->attrs[NL80211_ATTR_BEACON_TAIL]);
+		params.tail_len =
+		    nla_len(info->attrs[NL80211_ATTR_BEACON_TAIL]);
+		haveinfo = 1;
+	}
+
+	if (!haveinfo) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = call(&drv->wiphy, dev, &params);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_del_beacon(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->del_beacon) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->del_beacon(&drv->wiphy, dev);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static const struct nla_policy sta_flags_policy[NL80211_STA_FLAG_MAX + 1] = {
+	[NL80211_STA_FLAG_AUTHORIZED] = { .type = NLA_FLAG },
+	[NL80211_STA_FLAG_SHORT_PREAMBLE] = { .type = NLA_FLAG },
+	[NL80211_STA_FLAG_WME] = { .type = NLA_FLAG },
+};
+
+static int parse_station_flags(struct nlattr *nla, u32 *staflags)
+{
+	struct nlattr *flags[NL80211_STA_FLAG_MAX + 1];
+	int flag;
+
+	*staflags = 0;
+
+	if (!nla)
+		return 0;
+
+	if (nla_parse_nested(flags, NL80211_STA_FLAG_MAX,
+			     nla, sta_flags_policy))
+		return -EINVAL;
+
+	*staflags = STATION_FLAG_CHANGED;
+
+	for (flag = 1; flag <= NL80211_STA_FLAG_MAX; flag++)
+		if (flags[flag])
+			*staflags |= (1<<flag);
+
+	return 0;
+}
+
+static int nl80211_send_station(struct sk_buff *msg, u32 pid, u32 seq,
+				int flags, struct net_device *dev,
+				u8 *mac_addr, struct station_stats *stats)
+{
+	void *hdr;
+	struct nlattr *statsattr;
+
+	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_STATION);
+	if (!hdr)
+		return -1;
+
+	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, dev->ifindex);
+	NLA_PUT(msg, NL80211_ATTR_MAC, ETH_ALEN, mac_addr);
+
+	statsattr = nla_nest_start(msg, NL80211_ATTR_STA_STATS);
+	if (!statsattr)
+		goto nla_put_failure;
+	if (stats->filled & STATION_STAT_INACTIVE_TIME)
+		NLA_PUT_U32(msg, NL80211_STA_STAT_INACTIVE_TIME,
+			    stats->inactive_time);
+	if (stats->filled & STATION_STAT_RX_BYTES)
+		NLA_PUT_U32(msg, NL80211_STA_STAT_RX_BYTES,
+			    stats->rx_bytes);
+	if (stats->filled & STATION_STAT_TX_BYTES)
+		NLA_PUT_U32(msg, NL80211_STA_STAT_TX_BYTES,
+			    stats->tx_bytes);
+
+	nla_nest_end(msg, statsattr);
+
+	return genlmsg_end(msg, hdr);
+
+ nla_put_failure:
+	return genlmsg_cancel(msg, hdr);
+}
+
+
+static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	struct station_stats stats;
+	struct sk_buff *msg;
+	u8 *mac_addr = NULL;
+
+	memset(&stats, 0, sizeof(stats));
+
+	if (!info->attrs[NL80211_ATTR_MAC])
+		return -EINVAL;
+
+	mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->get_station) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->get_station(&drv->wiphy, dev, mac_addr, &stats);
+	rtnl_unlock();
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto out;
+
+	if (nl80211_send_station(msg, info->snd_pid, info->snd_seq, 0,
+				 dev, mac_addr, &stats) < 0)
+		goto out_free;
+
+	err = genlmsg_unicast(msg, info->snd_pid);
+	goto out;
+
+ out_free:
+	nlmsg_free(msg);
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+/*
+ * Get vlan interface making sure it is on the right wiphy.
+ */
+static int get_vlan(struct nlattr *vlanattr,
+		    struct cfg80211_registered_device *rdev,
+		    struct net_device **vlan)
+{
+	*vlan = NULL;
+
+	if (vlanattr) {
+		*vlan = dev_get_by_index(&init_net, nla_get_u32(vlanattr));
+		if (!*vlan)
+			return -ENODEV;
+		if (!(*vlan)->ieee80211_ptr)
+			return -EINVAL;
+		if ((*vlan)->ieee80211_ptr->wiphy != &rdev->wiphy)
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static int nl80211_set_station(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	struct station_parameters params;
+	u8 *mac_addr = NULL;
+
+	memset(&params, 0, sizeof(params));
+
+	params.listen_interval = -1;
+
+	if (info->attrs[NL80211_ATTR_STA_AID])
+		return -EINVAL;
+
+	if (!info->attrs[NL80211_ATTR_MAC])
+		return -EINVAL;
+
+	mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	if (info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]) {
+		params.supported_rates =
+			nla_data(info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]);
+		params.supported_rates_len =
+			nla_len(info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]);
+	}
+
+	if (info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL])
+		params.listen_interval =
+		    nla_get_u16(info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL]);
+
+	if (parse_station_flags(info->attrs[NL80211_ATTR_STA_FLAGS],
+				&params.station_flags))
+		return -EINVAL;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	if (err)
+		goto out;
+
+	if (!drv->ops->change_station) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->change_station(&drv->wiphy, dev, mac_addr, &params);
+	rtnl_unlock();
+
+ out:
+	if (params.vlan)
+		dev_put(params.vlan);
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	struct station_parameters params;
+	u8 *mac_addr = NULL;
+
+	memset(&params, 0, sizeof(params));
+
+	if (!info->attrs[NL80211_ATTR_MAC])
+		return -EINVAL;
+
+	if (!info->attrs[NL80211_ATTR_STA_AID])
+		return -EINVAL;
+
+	if (!info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL])
+		return -EINVAL;
+
+	if (!info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES])
+		return -EINVAL;
+
+	mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+	params.supported_rates =
+		nla_data(info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]);
+	params.supported_rates_len =
+		nla_len(info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]);
+	params.listen_interval =
+		nla_get_u16(info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL]);
+	params.listen_interval = nla_get_u16(info->attrs[NL80211_ATTR_STA_AID]);
+
+	if (parse_station_flags(info->attrs[NL80211_ATTR_STA_FLAGS],
+				&params.station_flags))
+		return -EINVAL;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	if (err)
+		goto out;
+
+	if (!drv->ops->add_station) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->add_station(&drv->wiphy, dev, mac_addr, &params);
+	rtnl_unlock();
+
+ out:
+	if (params.vlan)
+		dev_put(params.vlan);
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	struct net_device *dev;
+	u8 *mac_addr = NULL;
+
+	if (info->attrs[NL80211_ATTR_MAC])
+		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+
+	if (!drv->ops->del_station) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->del_station(&drv->wiphy, dev, mac_addr);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	dev_put(dev);
+	return err;
+}
+
 static struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_GET_WIPHY,
@@ -374,6 +1044,73 @@ static struct genl_ops nl80211_ops[] = {
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NL80211_CMD_GET_KEY,
+		.doit = nl80211_get_key,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_SET_KEY,
+		.doit = nl80211_set_key,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_NEW_KEY,
+		.doit = nl80211_new_key,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_DEL_KEY,
+		.doit = nl80211_del_key,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_SET_BEACON,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+		.doit = nl80211_addset_beacon,
+	},
+	{
+		.cmd = NL80211_CMD_NEW_BEACON,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+		.doit = nl80211_addset_beacon,
+	},
+	{
+		.cmd = NL80211_CMD_DEL_BEACON,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+		.doit = nl80211_del_beacon,
+	},
+	{
+		.cmd = NL80211_CMD_GET_STATION,
+		.doit = nl80211_get_station,
+		/* TODO: implement dumpit */
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_SET_STATION,
+		.doit = nl80211_set_station,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_NEW_STATION,
+		.doit = nl80211_new_station,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_DEL_STATION,
+		.doit = nl80211_del_station,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 /* multicast groups */
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
