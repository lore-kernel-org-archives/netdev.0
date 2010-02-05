From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 3/4] net: dm9601: convert to use mc helpers
Date: Fri, 5 Feb 2010 13:51:24 +0100
Message-ID: <20100205125124.GA7968@psychotron.redhat.com>
References: <20100205124623.GD2650@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755748Ab0BEMv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 07:51:27 -0500
Content-Disposition: inline
In-Reply-To: <20100205124623.GD2650@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/usb/dm9601.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 3d406f9..c820fec 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -381,13 +381,13 @@ static void dm9601_set_multicast(struct net_device *net)
 
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= 0x02;
-	} else if (net->flags & IFF_ALLMULTI || net->mc_count > DM_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(net) > DM_MAX_MCAST) {
 		rx_ctl |= 0x04;
-	} else if (net->mc_count) {
-		struct dev_mc_list *mc_list = net->mc_list;
-		int i;
+	} else if (!netdev_mc_empty(net)) {
+		struct dev_mc_list *mc_list;
 
-		for (i = 0; i < net->mc_count; i++, mc_list = mc_list->next) {
+		netdev_for_each_mc_addr(mc_list, net) {
 			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
-- 
1.6.6

