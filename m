From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 3/6] [6LoWPAN] set proper netdev flags
Date: Wed,  2 Nov 2011 19:34:48 +0300
Message-ID: <1320251688-2859-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34899 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932731Ab1KBQeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 12:34:12 -0400
Received: by mail-wy0-f174.google.com with SMTP id 15so329878wyh.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 09:34:11 -0700 (PDT)
In-Reply-To: <20111102162520.GA2669@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes settings for device initialization which makes possible to
use NDISC and TCP.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index e5709fa..c4aae4e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -967,13 +967,12 @@ static void lowpan_setup(struct net_device *dev)
 	dev->addr_len		= IEEE802154_ADDR_LEN;
 	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
 	dev->type		= ARPHRD_IEEE802154;
-	dev->features		= NETIF_F_NO_CSUM;
 	/* Frame Control + Sequence Number + Address fields + Security Header */
 	dev->hard_header_len	= 2 + 1 + 20 + 14;
 	dev->needed_tailroom	= 2; /* FCS */
 	dev->mtu		= 1281;
 	dev->tx_queue_len	= 0;
-	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
 	dev->watchdog_timeo	= 0;
 
 	dev->netdev_ops		= &lowpan_netdev_ops;
-- 
1.7.2.5
