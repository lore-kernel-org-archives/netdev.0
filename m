From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 11/26] jazzsonic: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:45 +0400
Message-ID: <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53404 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbZDOWxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:17 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so121391fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:17 -0700 (PDT)
In-Reply-To: <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/jazzsonic.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 14248cf..d12106b 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -96,6 +96,18 @@ static int jazzsonic_close(struct net_device* dev)
 	return err;
 }
 
+static const struct net_device_ops sonic_netdev_ops = {
+	.ndo_open		= jazzsonic_open,
+	.ndo_stop		= jazzsonic_close,
+	.ndo_start_xmit		= sonic_send_packet,
+	.ndo_get_stats		= sonic_get_stats,
+	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_tx_timeout		= sonic_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init sonic_probe1(struct net_device *dev)
 {
 	static unsigned version_printed;
@@ -179,12 +191,7 @@ static int __init sonic_probe1(struct net_device *dev)
 	lp->rra_laddr = lp->rda_laddr + (SIZEOF_SONIC_RD * SONIC_NUM_RDS
 	                     * SONIC_BUS_SCALE(lp->dma_bitmode));
 
-	dev->open = jazzsonic_open;
-	dev->stop = jazzsonic_close;
-	dev->hard_start_xmit = sonic_send_packet;
-	dev->get_stats = sonic_get_stats;
-	dev->set_multicast_list = &sonic_multicast_list;
-	dev->tx_timeout = sonic_tx_timeout;
+	dev->netdev_ops = &sonic_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	/*
-- 
1.6.2.3

