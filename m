From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 4/5] nfp: fix free list buffer size reporting
Date: Fri, 21 Apr 2017 12:23:09 -0700
Message-ID: <20170421192310.193875-5-jakub.kicinski@netronome.com>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:33117 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424897AbdDUTXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:25 -0400
Received: by mail-yb0-f170.google.com with SMTP id 81so48984915ybp.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:25 -0700 (PDT)
In-Reply-To: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP headroom should not be included in free list buffer size.

Fixes: 6fe0c3b43804 ("nfp: add support for xdp_adjust_head()")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7b70944573fa..ea0efa54916f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2166,7 +2166,7 @@ nfp_net_tx_ring_hw_cfg_write(struct nfp_net *nn,
  */
 static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 {
-	u32 new_ctrl, update = 0;
+	u32 bufsz, new_ctrl, update = 0;
 	unsigned int r;
 	int err;
 
@@ -2200,8 +2200,9 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nfp_net_write_mac_addr(nn);
 
 	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.netdev->mtu);
-	nn_writel(nn, NFP_NET_CFG_FLBUFSZ,
-		  nn->dp.fl_bufsz - NFP_NET_RX_BUF_NON_DATA);
+
+	bufsz = nn->dp.fl_bufsz - nn->dp.rx_dma_off - NFP_NET_RX_BUF_NON_DATA;
+	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, bufsz);
 
 	/* Enable device */
 	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
-- 
2.11.0
