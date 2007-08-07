From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] allow device to stop packet mirror behaviour
Date: Tue, 07 Aug 2007 10:27:07 +0200
Message-ID: <1186475227.4067.19.camel@johannes.berg>
References: <1186475155.4067.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1186475155.4067.17.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the corresponding patch to mac80211.

It marks all monitor type interfaces with IFF_NO_MIRROR the reasons for
which I explained in the previous mail; it also marks the master device
with IFF_NO_MIRROR so you don't see *any* packets on the master device
(right now you see outgoing frames with 802.11 header.) We want to get
rid of it anyway so making it a bit more useless yet seems like a good
idea.

johannes

---
 net/mac80211/ieee80211.c       |    1 +
 net/mac80211/ieee80211_iface.c |    2 ++
 2 files changed, 3 insertions(+)

--- wireless-dev.orig/net/mac80211/ieee80211_iface.c	2007-08-06 21:14:37.398164177 +0200
+++ wireless-dev/net/mac80211/ieee80211_iface.c	2007-08-06 21:15:02.078164177 +0200
@@ -158,6 +158,7 @@ void ieee80211_if_set_type(struct net_de
 	int oldtype = sdata->type;
 
 	dev->hard_start_xmit = ieee80211_subif_start_xmit;
+	dev->flags &= ~IFF_NO_MIRROR;
 
 	sdata->type = type;
 	switch (type) {
@@ -216,6 +217,7 @@ void ieee80211_if_set_type(struct net_de
 	case IEEE80211_IF_TYPE_MNTR:
 		dev->type = ARPHRD_IEEE80211_RADIOTAP;
 		dev->hard_start_xmit = ieee80211_monitor_start_xmit;
+		dev->flags |= IFF_NO_MIRROR;
 		break;
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
--- wireless-dev.orig/net/mac80211/ieee80211.c	2007-08-06 21:15:01.898164177 +0200
+++ wireless-dev/net/mac80211/ieee80211.c	2007-08-06 21:15:02.088164177 +0200
@@ -5138,6 +5138,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	mdev->stop = ieee80211_master_stop;
 	mdev->type = ARPHRD_IEEE80211;
 	mdev->hard_header_parse = header_parse_80211;
+	mdev->flags |= IFF_NO_MIRROR;
 
 	sdata->type = IEEE80211_IF_TYPE_AP;
 	sdata->dev = mdev;
