From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/6] d80211: remove useless callbacks from wmaster
Date: Mon, 29 Jan 2007 18:48:10 +0100 (CET)
Message-ID: <20070129174810.6CBDF4849A@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41734 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752522AbXA2Rr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:58 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invisible master interface doesn't need a lot of callbacks (actually, even
the previous visible one didn't need them but that's another story).

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c       |    4 ----
 net/d80211/ieee80211_i.h     |    1 -
 net/d80211/ieee80211_ioctl.c |   22 ----------------------
 3 files changed, 27 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -4479,10 +4479,6 @@ struct ieee80211_hw *ieee80211_alloc_hw(
         sta_info_init(local);
 
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
-	mdev->wireless_handlers =
-		(struct iw_handler_def *) &ieee80211_iw_master_handler_def;
-        mdev->do_ioctl = ieee80211_ioctl;
-	mdev->change_mtu = ieee80211_change_mtu;
         mdev->tx_timeout = ieee80211_tx_timeout;
         mdev->get_stats = ieee80211_get_stats;
 	mdev->open = ieee80211_master_open;
--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -622,7 +622,6 @@ struct net_device_stats *ieee80211_dev_s
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 extern const struct iw_handler_def ieee80211_iw_handler_def;
-extern const struct iw_handler_def ieee80211_iw_master_handler_def;
 
 /* Set hw encryption from ieee80211 */
 int ieee80211_set_hw_encryption(struct net_device *dev,
--- dscape.orig/net/d80211/ieee80211_ioctl.c
+++ dscape/net/d80211/ieee80211_ioctl.c
@@ -3243,25 +3243,3 @@ const struct iw_handler_def ieee80211_iw
 	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
 	.get_wireless_stats = ieee80211_get_wireless_stats,
 };
-
-/* Wireless handlers for master interface */
-
-static const iw_handler ieee80211_master_handler[] =
-{
-	[SIOCGIWNAME  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwname,
-	[SIOCSIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfreq,
-	[SIOCGIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfreq,
-	[SIOCGIWRANGE - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrange,
-	[SIOCSIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwrts,
-	[SIOCGIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrts,
-	[SIOCSIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfrag,
-	[SIOCGIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfrag,
-	[SIOCSIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwretry,
-	[SIOCGIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwretry,
-};
-
-const struct iw_handler_def ieee80211_iw_master_handler_def =
-{
-	.num_standard	= sizeof(ieee80211_master_handler) / sizeof(iw_handler),
-	.standard	= ieee80211_master_handler,
-};
