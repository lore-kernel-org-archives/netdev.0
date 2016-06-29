From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/3] nfp: remove unused parameter from nfp_net_write_mac_addr()
Date: Wed, 29 Jun 2016 21:55:54 +0100
Message-ID: <1467233755-14334-3-git-send-email-jakub.kicinski@netronome.com>
References: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37992 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbcF2VEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:04:10 -0400
Received: by mail-wm0-f53.google.com with SMTP id r201so90992387wme.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:04:09 -0700 (PDT)
In-Reply-To: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_write_mac_addr() always writes to the BAR the current
device address taken from netdev struct.  The address given
as parameter is actually ignored.  Since all callers pass
netdev->dev_addr simply remove the parameter.  

While at it improve the function's kdoc a bit.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2195ed3053da..df29cea0ad01 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1845,13 +1845,14 @@ void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
 }
 
 /**
- * nfp_net_write_mac_addr() - Write mac address to device registers
+ * nfp_net_write_mac_addr() - Write mac address to the device control BAR
  * @nn:      NFP Net device to reconfigure
- * @mac:     Six-byte MAC address to be written
  *
- * We do a bit of byte swapping dance because firmware is LE.
+ * Writes the MAC address from the netdev to the device control BAR.  Does not
+ * perform the required reconfig.  We do a bit of byte swapping dance because
+ * firmware is LE.
  */
-static void nfp_net_write_mac_addr(struct nfp_net *nn, const u8 *mac)
+static void nfp_net_write_mac_addr(struct nfp_net *nn)
 {
 	nn_writel(nn, NFP_NET_CFG_MACADDR + 0,
 		  get_unaligned_be32(nn->netdev->dev_addr));
@@ -1952,7 +1953,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->num_rx_rings == 64 ?
 		  0xffffffffffffffffULL : ((u64)1 << nn->num_rx_rings) - 1);
 
-	nfp_net_write_mac_addr(nn, nn->netdev->dev_addr);
+	nfp_net_write_mac_addr(nn);
 
 	nn_writel(nn, NFP_NET_CFG_MTU, nn->netdev->mtu);
 	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, nn->fl_bufsz);
@@ -2739,7 +2740,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
 	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
 
-	nfp_net_write_mac_addr(nn, nn->netdev->dev_addr);
+	nfp_net_write_mac_addr(nn);
 
 	/* Set default MTU and Freelist buffer size */
 	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
-- 
1.9.1
