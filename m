From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Sun, 04 May 2008 23:32:25 +0200
Message-ID: <1209936745.7304.16.camel@johannes.berg>
References: <1209936253.7304.10.camel@johannes.berg>
	 (sfid-20080504_232356_925288_0C998746)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209936253.7304.10.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_232356_925288_0C998746)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This assigns the netdev's needed_headroom/tailroom members
to take advantage of pre-allocated space for 802.11 headers.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 net/mac80211/iface.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- everything.orig/net/mac80211/iface.c	2008-05-04 23:24:17.000000000 +0200
+++ everything/net/mac80211/iface.c	2008-05-04 23:31:46.000000000 +0200
@@ -53,6 +53,15 @@ int ieee80211_if_add(struct net_device *
 	if (!ndev)
 		return -ENOMEM;
 
+	ndev->needed_headroom = local->tx_headroom +
+				4*6 /* four MAC addresses */
+				+ 2 + 2 + 2 + 2 /* ctl, dur, seq, qos */
+				+ 6 /* mesh */
+				+ 8 /* rfc1042/bridge tunnel */
+				- ETH_HLEN /* ethernet hard_header_len */
+				+ IEEE80211_ENCRYPT_HEADROOM;
+	ndev->needed_tailroom = IEEE80211_ENCRYPT_TAILROOM;
+
 	ret = dev_alloc_name(ndev, ndev->name);
 	if (ret < 0)
 		goto fail;


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
