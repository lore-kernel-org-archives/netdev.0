From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] e1000: Silence sparse warnings by correcting type
Date: Fri,  4 May 2012 04:05:04 -0700
Message-ID: <1336129504-29919-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andrei Emeltchenko <andrei.emeltchenko@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11785 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab2EDLFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 07:05:08 -0400
In-Reply-To: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@intel.com>

Silence sparse warnings shown below:
...
drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
	cast to restricted __le64
drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
	cast to restricted __le64
...

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 4348b6f..37caa88 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3380,7 +3380,7 @@ static void e1000_dump(struct e1000_adapter *adapter)
 	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
 		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
 		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
-		struct my_u { u64 a; u64 b; };
+		struct my_u { __le64 a; __le64 b; };
 		struct my_u *u = (struct my_u *)tx_desc;
 		const char *type;
 
@@ -3424,7 +3424,7 @@ rx_ring_summary:
 	for (i = 0; rx_ring->desc && (i < rx_ring->count); i++) {
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rx_ring, i);
 		struct e1000_buffer *buffer_info = &rx_ring->buffer_info[i];
-		struct my_u { u64 a; u64 b; };
+		struct my_u { __le64 a; __le64 b; };
 		struct my_u *u = (struct my_u *)rx_desc;
 		const char *type;
 
-- 
1.7.7.6
