From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 1/4] net: 8139cp: convert to use mc helpers
Date: Fri, 5 Feb 2010 13:47:28 +0100
Message-ID: <20100205124728.GE2650@psychotron.redhat.com>
References: <20100205124623.GD2650@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab0BEMrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 07:47:31 -0500
Content-Disposition: inline
In-Reply-To: <20100205124623.GD2650@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/8139cp.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 9d59654..60bc0b0 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -899,7 +899,7 @@ static void __cp_set_rx_mode (struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp;
 
 	/* Note: do not reorder, GCC is clever about common statements. */
@@ -909,7 +909,7 @@ static void __cp_set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -918,8 +918,7 @@ static void __cp_set_rx_mode (struct net_device *dev)
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

