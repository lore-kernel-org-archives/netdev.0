From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] adm8211: Use ieee80211_generic_get_stats
Date: Wed, 22 Nov 2006 03:16:13 +0000 (GMT)
Message-ID: <20061122031613.52BA77B40A0@zog.reactivated.net>
Cc: flamingice@sourmilk.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:30429 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S967021AbWKVDQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 22:16:17 -0500
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adm8211 can also benefit from the generic get_stats implementation in my 
previous mail. I am sending the adm8211 patch separately because adm8211 is
not in Linus' tree.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/adm8211/adm8211_hw.c
===================================================================
--- linux.orig/drivers/net/wireless/adm8211/adm8211_hw.c
+++ linux/drivers/net/wireless/adm8211/adm8211_hw.c
@@ -363,12 +363,6 @@ static void adm8211_clear_sram(struct ne
 	ADM8211_CSR_WRITE(WEPCTL, reg);
 }
 
-static struct net_device_stats *adm8211_get_stats(struct net_device *dev)
-{
-	struct ieee80211_device *ieee = netdev_priv(dev);
-	return &ieee->stats;
-}
-
 static void adm8211_set_rx_mode(struct net_device *dev)
 {
 	struct adm8211_priv *priv = ieee80211_priv(dev);
@@ -2531,7 +2525,6 @@ static int __devinit adm8211_probe(struc
 	dev->features |= NETIF_F_LLTX;
 	dev->open = adm8211_open;
 	dev->stop = adm8211_stop;
-	dev->get_stats = adm8211_get_stats;
 	dev->set_multicast_list = adm8211_set_rx_mode;
 	dev->set_mac_address = adm8211_set_mac_address;
 
