From: Wolfgang Steinwender <wsteinwender@pcs.com>
Subject: [PATCH net-next] net/macb: sqe_test_errors are TX errors, not RX errors
Date: Fri, 10 Apr 2015 11:42:56 +0200
Message-ID: <1428658976-28050-1-git-send-email-wsteinwender@pcs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Wolfgang Steinwender <wsteinwender@pcs.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pcs.de ([145.253.69.50]:63964 "EHLO exchange5.pcs.ditec.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751343AbbDJJtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 05:49:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics are grouped by TX and RX errors.
The SQE Test Errors Register indicates problems with TX.

Signed-off-by: Wolfgang Steinwender <wsteinwender@pcs.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 448a323..9f53872 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1956,12 +1956,12 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 			    hwstat->rx_oversize_pkts +
 			    hwstat->rx_jabbers +
 			    hwstat->rx_undersize_pkts +
-			    hwstat->sqe_test_errors +
 			    hwstat->rx_length_mismatch);
 	nstat->tx_errors = (hwstat->tx_late_cols +
 			    hwstat->tx_excessive_cols +
 			    hwstat->tx_underruns +
-			    hwstat->tx_carrier_errors);
+			    hwstat->tx_carrier_errors +
+			    hwstat->sqe_test_errors);
 	nstat->collisions = (hwstat->tx_single_cols +
 			     hwstat->tx_multiple_cols +
 			     hwstat->tx_excessive_cols);
-- 
2.1.0
