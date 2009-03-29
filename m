From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 10/10] Staging: wlan-ng: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:31:28 +0400
Message-ID: <20090329153128.GJ11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:55116 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758251AbZC2Pbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:31:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/wlan-ng/p80211netdev.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index b2a606a..393e4df 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -711,6 +711,20 @@ static int wlan_change_mtu(netdevice_t *dev, int new_mtu)
 	return 0;
 }
 
+static const struct net_device_ops p80211_netdev_ops = {
+	.ndo_init		= p80211knetdev_init,
+	.ndo_open		= p80211knetdev_open,
+	.ndo_stop		= p80211knetdev_stop,
+	.ndo_get_stats		= p80211knetdev_get_stats,
+	.ndo_start_xmit		= p80211knetdev_hard_start_xmit,
+	.ndo_set_multicast_list	= p80211knetdev_set_multicast_list,
+	.ndo_do_ioctl		= p80211knetdev_do_ioctl,
+	.ndo_set_mac_address	= p80211knetdev_set_mac_address,
+	.ndo_tx_timeout		= p80211knetdev_tx_timeout,
+	.ndo_change_mtu		= wlan_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*----------------------------------------------------------------
 * wlan_setup
 *
@@ -756,11 +770,7 @@ int wlan_setup(wlandevice_t *wlandev)
 	} else {
 		wlandev->netdev = dev;
 		dev->ml_priv = wlandev;
-		dev->hard_start_xmit = p80211knetdev_hard_start_xmit;
-		dev->get_stats = p80211knetdev_get_stats;
-		dev->init = p80211knetdev_init;
-		dev->open = p80211knetdev_open;
-		dev->stop = p80211knetdev_stop;
+		dev->netdev_ops = &p80211_netdev_ops;
 
 		mutex_init(&wlandev->ioctl_lock);
 		/* block ioctls until fully initialised. Don't forget to call
