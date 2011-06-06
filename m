From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Fix Rx pause counter for lancer
Date: Mon, 6 Jun 2011 17:57:13 +0530
Message-ID: <78aa0be5-ee8d-4d65-88aa-6ab858bb7259@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Selvin Xavier <selvin.xavier@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:16366 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755983Ab1FFM2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 08:28:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Selvin Xavier <selvin.xavier@emulex.com>

Fixed Rx pause counter for Lancer. Swapping hi and lo words.

Signed-off-by: Selvin Xavier <selvin.xavier@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 5824c95..9ba197b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -362,8 +362,8 @@ static void populate_lancer_stats(struct be_adapter *adapter)
 	drvs->rx_priority_pause_frames = 0;
 	drvs->pmem_fifo_overflow_drop = 0;
 	drvs->rx_pause_frames =
-		make_64bit_val(pport_stats->rx_pause_frames_lo,
-				 pport_stats->rx_pause_frames_hi);
+		make_64bit_val(pport_stats->rx_pause_frames_hi,
+				 pport_stats->rx_pause_frames_lo);
 	drvs->rx_crc_errors = make_64bit_val(pport_stats->rx_crc_errors_hi,
 						pport_stats->rx_crc_errors_lo);
 	drvs->rx_control_frames =
-- 
1.6.0.2

