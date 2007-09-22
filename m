From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc6-mm1: Build failures on ppc64_defconfig
Date: Sat, 22 Sep 2007 12:55:50 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709221248390.22517@enigma.security.iitk.ac.in>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
 <20070920132512.GF24105@skynet.ie>
 <alpine.LFD.0.999.0709201903180.17093@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Jeff Garzik <jeff@garzik.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>
To: Mel Gorman <mel@skynet.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37075 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030AbXIVHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 03:22:55 -0400
In-Reply-To: <alpine.LFD.0.999.0709201903180.17093@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 20 Sep 2007, Satyam Sharma wrote:
> 
> BTW ppc64_defconfig didn't quite like 2.6.23-rc6-mm1 either ...
> IIRC I got build failures in:

> drivers/net/spider_net.c

Fixing the above showed up another problem in another file of the
same driver (drivers/net/spider_net_ethtool.c)


[PATCH -mm] spider_net_ethtool: Keep up with recent netdev stats changes

Unbreak the following:

drivers/net/spider_net_ethtool.c: In function 'spider_net_get_ethtool_stats':
drivers/net/spider_net_ethtool.c:160: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:161: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:162: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:163: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:164: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:165: error: structure has no member named 'netdev_stats'
drivers/net/spider_net_ethtool.c:166: error: structure has no member named 'netdev_stats'
make[2]: *** [drivers/net/spider_net_ethtool.o] Error 1

Also do another ARRAY_SIZE() cleanup while at it.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/spider_net_ethtool.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff -ruNp a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
--- a/drivers/net/spider_net_ethtool.c	2007-09-22 06:26:39.000000000 +0530
+++ b/drivers/net/spider_net_ethtool.c	2007-09-22 12:43:51.000000000 +0530
@@ -28,8 +28,6 @@
 #include "spider_net.h"
 
 
-#define SPIDER_NET_NUM_STATS 13
-
 static struct {
 	const char str[ETH_GSTRING_LEN];
 } ethtool_stats_keys[] = {
@@ -149,7 +147,7 @@ spider_net_ethtool_get_ringparam(struct 
 
 static int spider_net_get_stats_count(struct net_device *netdev)
 {
-	return SPIDER_NET_NUM_STATS;
+	return ARRAY_SIZE(ethtool_stats_keys);
 }
 
 static void spider_net_get_ethtool_stats(struct net_device *netdev,
@@ -157,13 +155,13 @@ static void spider_net_get_ethtool_stats
 {
 	struct spider_net_card *card = netdev->priv;
 
-	data[0] = card->netdev_stats.tx_packets;
-	data[1] = card->netdev_stats.tx_bytes;
-	data[2] = card->netdev_stats.rx_packets;
-	data[3] = card->netdev_stats.rx_bytes;
-	data[4] = card->netdev_stats.tx_errors;
-	data[5] = card->netdev_stats.tx_dropped;
-	data[6] = card->netdev_stats.rx_dropped;
+	data[0] = netdev->stats.tx_packets;
+	data[1] = netdev->stats.tx_bytes;
+	data[2] = netdev->stats.rx_packets;
+	data[3] = netdev->stats.rx_bytes;
+	data[4] = netdev->stats.tx_errors;
+	data[5] = netdev->stats.tx_dropped;
+	data[6] = netdev->stats.rx_dropped;
 	data[7] = card->spider_stats.rx_desc_error;
 	data[8] = card->spider_stats.tx_timeouts;
 	data[9] = card->spider_stats.alloc_rx_skb_error;
