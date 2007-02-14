From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] ipw2200: add channels sysfs entry
Date: Wed, 14 Feb 2007 16:04:24 +0800
Message-ID: <20070214080424.GA9797@mail.intel.com>
Reply-To: yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Add 'channels' sysfs entry for ipw2200. The entry exports channels
information for the user space.

Signed-off-by: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

--
diff -urp a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
--- a/drivers/net/wireless/ipw2200.c	2007-02-05 17:40:23.000000000 +0800
+++ b/drivers/net/wireless/ipw2200.c	2007-02-14 15:44:56.000000000 +0800
@@ -1847,6 +1847,52 @@ static ssize_t store_net_stats(struct de
 static DEVICE_ATTR(net_stats, S_IWUSR | S_IRUGO,
 		   show_net_stats, store_net_stats);
 
+static ssize_t show_channels(struct device *d,
+			     struct device_attribute *attr,
+			     char *buf)
+{
+	struct ipw_priv *priv = dev_get_drvdata(d);
+	const struct ieee80211_geo *geo = ipw_get_geo(priv->ieee);
+	int len = 0, i;
+
+	len = sprintf(&buf[len],
+		      "Displaying %d channels in 2.4Ghz band "
+		      "(802.11bg):\n", geo->bg_channels);
+
+	for (i = 0; i < geo->bg_channels; i++) {
+		len += sprintf(&buf[len], "%d: BSS%s%s, %s, Band %s.\n",
+			       geo->bg[i].channel,
+			       geo->bg[i].flags & IEEE80211_CH_RADAR_DETECT ?
+			       " (radar spectrum)" : "",
+			       ((geo->bg[i].flags & IEEE80211_CH_NO_IBSS) ||
+				(geo->bg[i].flags & IEEE80211_CH_RADAR_DETECT))
+			       ? "" : ", IBSS",
+			       geo->bg[i].flags & IEEE80211_CH_PASSIVE_ONLY ?
+			       "passive only" : "active/passive",
+			       geo->bg[i].flags & IEEE80211_CH_B_ONLY ?
+			       "B" : "B/G");
+	}
+
+	len += sprintf(&buf[len],
+		       "Displaying %d channels in 5.2Ghz band "
+		       "(802.11a):\n", geo->a_channels);
+	for (i = 0; i < geo->a_channels; i++) {
+		len += sprintf(&buf[len], "%d: BSS%s%s, %s.\n",
+			       geo->a[i].channel,
+			       geo->a[i].flags & IEEE80211_CH_RADAR_DETECT ?
+			       " (radar spectrum)" : "",
+			       ((geo->a[i].flags & IEEE80211_CH_NO_IBSS) ||
+				(geo->a[i].flags & IEEE80211_CH_RADAR_DETECT))
+			       ? "" : ", IBSS",
+			       geo->a[i].flags & IEEE80211_CH_PASSIVE_ONLY ?
+			       "passive only" : "active/passive");
+	}
+
+	return len;
+}
+
+static DEVICE_ATTR(channels, S_IRUSR, show_channels, NULL);
+
 static void notify_wx_assoc_event(struct ipw_priv *priv)
 {
 	union iwreq_data wrqu;
@@ -11383,6 +11383,7 @@ static struct attribute *ipw_sysfs_entri
 	&dev_attr_led.attr,
 	&dev_attr_speed_scan.attr,
 	&dev_attr_net_stats.attr,
+	&dev_attr_channels.attr,
 #ifdef CONFIG_IPW2200_PROMISCUOUS
 	&dev_attr_rtap_iface.attr,
 	&dev_attr_rtap_filter.attr,
