From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 2/5] atarilance: convert to net_device_ops
Date: Wed, 15 Apr 2009 08:30:22 +0400
Message-ID: <1239769825-12413-2-git-send-email-a.beregalov@gmail.com>
References: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:55985 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbZDOEai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:30:38 -0400
Received: by bwz17 with SMTP id 17so2712599bwz.37
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 21:30:36 -0700 (PDT)
In-Reply-To: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/atarilance.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 2d81f6a..5425ab0 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -453,6 +453,16 @@ static noinline int __init addr_accessible(volatile void *regp, int wordflag,
 	return( ret );
 }
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open		= lance_open,
+	.ndo_stop		= lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_mac_address	= lance_set_mac_address,
+	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
 
 static unsigned long __init lance_probe1( struct net_device *dev,
 					   struct lance_addr *init_rec )
@@ -623,15 +633,9 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	if (did_version++ == 0)
 		DPRINTK( 1, ( version ));
 
-	/* The LANCE-specific entries in the device structure. */
-	dev->open = &lance_open;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->stop = &lance_close;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->set_mac_address = &lance_set_mac_address;
+	dev->netdev_ops = &lance_netdev_ops;
 
 	/* XXX MSch */
-	dev->tx_timeout = lance_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return( 1 );
-- 
1.6.2.3

