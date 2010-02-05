From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 2/4] net: 8139too: convert to use mc helpers
Date: Fri, 5 Feb 2010 13:48:11 +0100
Message-ID: <20100205124810.GF2650@psychotron.redhat.com>
References: <20100205124623.GD2650@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019Ab0BEMsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 07:48:13 -0500
Content-Disposition: inline
In-Reply-To: <20100205124623.GD2650@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/8139too.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 321e73a..c7d6f09 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2509,7 +2509,7 @@ static void __set_rx_mode (struct net_device *dev)
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp;
 
 	pr_debug("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n",
@@ -2521,7 +2521,7 @@ static void __set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -2530,8 +2530,7 @@ static void __set_rx_mode (struct net_device *dev)
 		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-- 
1.6.6

