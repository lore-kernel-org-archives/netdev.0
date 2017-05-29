From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 11/13] nfp: fix print format for ring pointers in ring dumps
Date: Sun, 28 May 2017 17:53:02 -0700
Message-ID: <20170529005304.20847-12-jakub.kicinski@netronome.com>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35534 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdE2Ayn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 20:54:43 -0400
Received: by mail-pf0-f177.google.com with SMTP id n23so40368460pfb.2
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 17:54:37 -0700 (PDT)
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ring pointers are unsigned.  Fix the print formats to avoid
showing users negative values.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 6cf1b234eecd..8c52c0e8379c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -62,7 +62,7 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 	fl_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_fl);
 	fl_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_fl);
 
-	seq_printf(file, "RX[%02d,%02d]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d\n",
+	seq_printf(file, "RX[%02d,%02d]: cnt=%u dma=%pad host=%p   H_RD=%u H_WR=%u FL_RD=%u FL_WR=%u\n",
 		   rx_ring->idx, rx_ring->fl_qcidx,
 		   rx_ring->cnt, &rx_ring->dma, rx_ring->rxds,
 		   rx_ring->rd_p, rx_ring->wr_p, fl_rd_p, fl_wr_p);
@@ -146,7 +146,7 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	d_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
 	d_wr_p = nfp_qcp_wr_ptr_read(tx_ring->qcp_q);
 
-	seq_printf(file, "TX[%02d,%02d%s]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d D_RD=%d D_WR=%d\n",
+	seq_printf(file, "TX[%02d,%02d%s]: cnt=%u dma=%pad host=%p   H_RD=%u H_WR=%u D_RD=%u D_WR=%u\n",
 		   tx_ring->idx, tx_ring->qcidx,
 		   tx_ring == r_vec->tx_ring ? "" : "xdp",
 		   tx_ring->cnt, &tx_ring->dma, tx_ring->txds,
-- 
2.11.0
