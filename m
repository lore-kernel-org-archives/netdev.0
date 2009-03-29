From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 7/10] Staging: rt3070: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:29:18 +0400
Message-ID: <20090329152918.GG11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:56629 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932AbZC2P3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:29:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove unused variable.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/rt3070/rt_main_dev.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/rt3070/rt_main_dev.c b/drivers/staging/rt3070/rt_main_dev.c
index c000646..81f769c 100644
--- a/drivers/staging/rt3070/rt_main_dev.c
+++ b/drivers/staging/rt3070/rt_main_dev.c
@@ -436,7 +436,6 @@ static int rt28xx_init(IN struct net_device *net_dev)
 //    OID_SET_HT_PHYMODE		SetHT;
 //	WPDMA_GLO_CFG_STRUC     GloCfg;
 	UINT32 		MacCsr0 = 0;
-	UINT32		MacValue = 0;
 
 #ifdef RT2870
 #ifdef INF_AMAZON_SE
@@ -849,6 +848,20 @@ err:
 	return (-1);
 } /* End of rt28xx_open */
 
+static const struct net_device_ops rt3070_netdev_ops = {
+	.ndo_open		= MainVirtualIF_open,
+	.ndo_stop		= MainVirtualIF_close,
+	.ndo_do_ioctl		= rt28xx_ioctl,
+	.ndo_get_stats		= RT28xx_get_ether_stats,
+	.ndo_validate_addr	= NULL,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef IKANOS_VX_1X0
+	.ndo_start_xmit		= IKANOS_DataFramesTx,
+#else
+	.ndo_start_xmit		= rt28xx_send_packets,
+#endif
+};
 
 /* Must not be called for mdev and apdev */
 static NDIS_STATUS rt_ieee80211_if_setup(struct net_device *dev, PRTMP_ADAPTER pAd)
@@ -860,12 +873,6 @@ static NDIS_STATUS rt_ieee80211_if_setup(struct net_device *dev, PRTMP_ADAPTER p
 
 
 	//ether_setup(dev);
-	dev->hard_start_xmit = rt28xx_send_packets;
-
-#ifdef IKANOS_VX_1X0
-	dev->hard_start_xmit = IKANOS_DataFramesTx;
-#endif // IKANOS_VX_1X0 //
-
 //	dev->set_multicast_list = ieee80211_set_multicast_list;
 //	dev->change_mtu = ieee80211_change_mtu;
 #ifdef CONFIG_STA_SUPPORT
@@ -889,16 +896,10 @@ static NDIS_STATUS rt_ieee80211_if_setup(struct net_device *dev, PRTMP_ADAPTER p
 #if WIRELESS_EXT < 21
 		dev->get_wireless_stats = rt28xx_get_wireless_stats;
 #endif
-	dev->get_stats = RT28xx_get_ether_stats;
-	dev->open = MainVirtualIF_open; //rt28xx_open;
-	dev->stop = MainVirtualIF_close; //rt28xx_close;
 //	dev->uninit = ieee80211_if_reinit;
 //	dev->destructor = ieee80211_if_free;
 	dev->priv_flags = INT_MAIN;
-	dev->do_ioctl = rt28xx_ioctl;
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,24)
-    dev->validate_addr = NULL;
-#endif
+	dev->netdev_ops = &rt3070_netdev_ops;
 	// find available device name
 	for (i = 0; i < 8; i++)
 	{
