From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 11/13] liquidio: ptp info
Date: Tue, 21 Jun 2016 22:53:13 -0700
Message-ID: <1466574795-4306-12-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0091.outbound.protection.outlook.com ([65.55.169.91]:52906
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbcFVGL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 02:11:27 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has minor changes for proper ptp info retreival.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 88994c5..85f5d17 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1416,23 +1416,28 @@ static int lio_get_ts_info(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 
 	info->so_timestamping =
+#ifdef PTP_HARDWARE_TIMESTAMPING
 		SOF_TIMESTAMPING_TX_HARDWARE |
-		SOF_TIMESTAMPING_TX_SOFTWARE |
 		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE |
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+#endif
 		SOF_TIMESTAMPING_RX_SOFTWARE |
-		SOF_TIMESTAMPING_SOFTWARE | SOF_TIMESTAMPING_RAW_HARDWARE;
+		SOF_TIMESTAMPING_SOFTWARE;
 
 	if (lio->ptp_clock)
 		info->phc_index = ptp_clock_index(lio->ptp_clock);
 	else
 		info->phc_index = -1;
 
+#ifdef PTP_HARDWARE_TIMESTAMPING
 	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
 
 	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
 			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
 			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
 			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
+#endif
 
 	return 0;
 }
-- 
1.8.3.1
