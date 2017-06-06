From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/16] nfp: prepare config and enable for working without netdevs
Date: Mon,  5 Jun 2017 17:01:49 -0700
Message-ID: <20170606000157.17556-9-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33471 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdFFACV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:21 -0400
Received: by mail-pg0-f47.google.com with SMTP id f185so27037814pgc.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:21 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Out of the three stages of ifup/ifdown (allocate, configure, start)
- this commit prepares the configuration stage for working with
control vNICs.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1cc7425ffd27..c47705861a81 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2236,9 +2236,10 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->dp.num_rx_rings == 64 ?
 		  0xffffffffffffffffULL : ((u64)1 << nn->dp.num_rx_rings) - 1);
 
-	nfp_net_write_mac_addr(nn, nn->dp.netdev->dev_addr);
+	if (nn->dp.netdev)
+		nfp_net_write_mac_addr(nn, nn->dp.netdev->dev_addr);
 
-	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.netdev->mtu);
+	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.mtu);
 
 	bufsz = nn->dp.fl_bufsz - nn->dp.rx_dma_off - NFP_NET_RX_BUF_NON_DATA;
 	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, bufsz);
-- 
2.11.0
