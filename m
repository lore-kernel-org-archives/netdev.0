From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] ixgbe: add/update descriptor maps in comments
Date: Tue, 30 Oct 2012 00:04:24 -0700
Message-ID: <1351580670-8292-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25412 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270Ab2J3HEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:36 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

Adds/updates ASCII descriptor maps for 82598 and 82599 Tx/Rx descriptors.
Current descriptor maps were out of date for 82598 and incorrect for
82599.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 61 ++++++++++++++++++++++++---
 1 file changed, 55 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a34ee7d..6035674 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -355,13 +355,37 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 
 	/* Transmit Descriptor Formats
 	 *
-	 * Advanced Transmit Descriptor
+	 * 82598 Advanced Transmit Descriptor
 	 *   +--------------------------------------------------------------+
 	 * 0 |         Buffer Address [63:0]                                |
 	 *   +--------------------------------------------------------------+
-	 * 8 |  PAYLEN  | PORTS  | IDX | STA | DCMD  |DTYP |  RSV |  DTALEN |
+	 * 8 |  PAYLEN  | POPTS  | IDX | STA | DCMD  |DTYP |  RSV |  DTALEN |
 	 *   +--------------------------------------------------------------+
 	 *   63       46 45    40 39 36 35 32 31   24 23 20 19              0
+	 *
+	 * 82598 Advanced Transmit Descriptor (Write-Back Format)
+	 *   +--------------------------------------------------------------+
+	 * 0 |                          RSV [63:0]                          |
+	 *   +--------------------------------------------------------------+
+	 * 8 |            RSV           |  STA  |          NXTSEQ           |
+	 *   +--------------------------------------------------------------+
+	 *   63                       36 35   32 31                         0
+	 *
+	 * 82599+ Advanced Transmit Descriptor
+	 *   +--------------------------------------------------------------+
+	 * 0 |         Buffer Address [63:0]                                |
+	 *   +--------------------------------------------------------------+
+	 * 8 |PAYLEN  |POPTS|CC|IDX  |STA  |DCMD  |DTYP |MAC  |RSV  |DTALEN |
+	 *   +--------------------------------------------------------------+
+	 *   63     46 45 40 39 38 36 35 32 31  24 23 20 19 18 17 16 15     0
+	 *
+	 * 82599+ Advanced Transmit Descriptor (Write-Back Format)
+	 *   +--------------------------------------------------------------+
+	 * 0 |                          RSV [63:0]                          |
+	 *   +--------------------------------------------------------------+
+	 * 8 |            RSV           |  STA  |           RSV             |
+	 *   +--------------------------------------------------------------+
+	 *   63                       36 35   32 31                         0
 	 */
 
 	for (n = 0; n < adapter->num_tx_queues; n++) {
@@ -422,7 +446,9 @@ rx_ring_summary:
 
 	dev_info(&adapter->pdev->dev, "RX Rings Dump\n");
 
-	/* Advanced Receive Descriptor (Read) Format
+	/* Receive Descriptor Formats
+	 *
+	 * 82598 Advanced Receive Descriptor (Read) Format
 	 *    63                                           1        0
 	 *    +-----------------------------------------------------+
 	 *  0 |       Packet Buffer Address [63:1]           |A0/NSE|
@@ -431,17 +457,40 @@ rx_ring_summary:
 	 *    +-----------------------------------------------------+
 	 *
 	 *
-	 * Advanced Receive Descriptor (Write-Back) Format
+	 * 82598 Advanced Receive Descriptor (Write-Back) Format
 	 *
 	 *   63       48 47    32 31  30      21 20 16 15   4 3     0
 	 *   +------------------------------------------------------+
-	 * 0 | Packet     IP     |SPH| HDR_LEN   | RSV|Packet|  RSS |
-	 *   | Checksum   Ident  |   |           |    | Type | Type |
+	 * 0 |       RSS Hash /  |SPH| HDR_LEN  | RSV |Packet|  RSS |
+	 *   | Packet   | IP     |   |          |     | Type | Type |
+	 *   | Checksum | Ident  |   |          |     |      |      |
 	 *   +------------------------------------------------------+
 	 * 8 | VLAN Tag | Length | Extended Error | Extended Status |
 	 *   +------------------------------------------------------+
 	 *   63       48 47    32 31            20 19               0
+	 *
+	 * 82599+ Advanced Receive Descriptor (Read) Format
+	 *    63                                           1        0
+	 *    +-----------------------------------------------------+
+	 *  0 |       Packet Buffer Address [63:1]           |A0/NSE|
+	 *    +----------------------------------------------+------+
+	 *  8 |       Header Buffer Address [63:1]           |  DD  |
+	 *    +-----------------------------------------------------+
+	 *
+	 *
+	 * 82599+ Advanced Receive Descriptor (Write-Back) Format
+	 *
+	 *   63       48 47    32 31  30      21 20 17 16   4 3     0
+	 *   +------------------------------------------------------+
+	 * 0 |RSS / Frag Checksum|SPH| HDR_LEN  |RSC- |Packet|  RSS |
+	 *   |/ RTT / PCoE_PARAM |   |          | CNT | Type | Type |
+	 *   |/ Flow Dir Flt ID  |   |          |     |      |      |
+	 *   +------------------------------------------------------+
+	 * 8 | VLAN Tag | Length |Extended Error| Xtnd Status/NEXTP |
+	 *   +------------------------------------------------------+
+	 *   63       48 47    32 31          20 19                 0
 	 */
+
 	for (n = 0; n < adapter->num_rx_queues; n++) {
 		rx_ring = adapter->rx_ring[n];
 		pr_info("------------------------------------\n");
-- 
1.7.11.7
