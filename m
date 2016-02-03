From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 05/19] nfp: don't trust netif_running() in debug code
Date: Wed,  3 Feb 2016 11:45:11 +0000
Message-ID: <1454499925-16359-6-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35045 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbcBCLpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:41 -0500
Received: by mail-wm0-f41.google.com with SMTP id r129so160907924wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:41 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since change_mtu() can fail and leave us with netif_running()
returning true even though all rings were freed - we should
look at NFP_NET_CFG_CTRL_ENABLE flag to determine if device
is really opened.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 4c97c713121c..7af404d492cc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -52,7 +52,7 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 	if (!rx_ring->r_vec || !rx_ring->r_vec->nfp_net)
 		goto out;
 	nn = rx_ring->r_vec->nfp_net;
-	if (!netif_running(nn->netdev))
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE))
 		goto out;
 
 	rxd_cnt = rx_ring->cnt;
@@ -127,7 +127,7 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	if (!tx_ring->r_vec || !tx_ring->r_vec->nfp_net)
 		goto out;
 	nn = tx_ring->r_vec->nfp_net;
-	if (!netif_running(nn->netdev))
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE))
 		goto out;
 
 	txd_cnt = tx_ring->cnt;
-- 
1.9.1
