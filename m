From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 04/11] amd-xgbe: Allow for a greater number of
 Rx queues
Date: Thu, 10 Nov 2016 17:10:05 -0600
Message-ID: <20161110231005.20704.26244.stgit@tlendack-t1.amdoffice.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0059.outbound.protection.outlook.com ([104.47.34.59]:33152
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935943AbcKJXKN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:10:13 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the call to netif_get_num_default_rss_queues() and replace it
with num_online_cpus() to allow for the possibility of using all of
the hardware DMA channels available.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 697483a..7655753 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -236,8 +236,7 @@ void xgbe_set_counts(struct xgbe_prv_data *pdata)
 
 	pdata->tx_q_count = pdata->tx_ring_count;
 
-	pdata->rx_ring_count = min_t(unsigned int,
-				     netif_get_num_default_rss_queues(),
+	pdata->rx_ring_count = min_t(unsigned int, num_online_cpus(),
 				     pdata->hw_feat.rx_ch_cnt);
 	pdata->rx_ring_count = min_t(unsigned int, pdata->rx_ring_count,
 				     pdata->rx_max_channel_count);
