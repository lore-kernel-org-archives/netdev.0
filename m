From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] e1000e: Use marco instead of digit for defining e1000_rx_desc_packet_split
Date: Sun, 28 Jul 2013 04:41:08 -0700
Message-ID: <1375011676-30739-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab3G1Ll0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:26 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>

In structure e1000_rx_desc_packet_split, the size of wb.upper.length is
defined by a digit. This may introduce some problem when the length is
changed.

This patch use the macro PS_PAGE_BUFFERS for the definition. And move the
definition to hw.h.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 3 ---
 drivers/net/ethernet/intel/e1000e/hw.h    | 6 +++++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index ffbc08f..ad0edd1 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -90,9 +90,6 @@ struct e1000_info;
 
 #define E1000_MNG_VLAN_NONE		(-1)
 
-/* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
-
 #define DEFAULT_JUMBO			9234
 
 /* Time to wait before putting the device into D3 if there's no link (in ms). */
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index a6f903a..cee565d 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -227,6 +227,9 @@ union e1000_rx_desc_extended {
 };
 
 #define MAX_PS_BUFFERS 4
+
+/* Number of packet split data buffers (not including the header buffer) */
+#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
 /* Receive Descriptor - Packet Split */
 union e1000_rx_desc_packet_split {
 	struct {
@@ -251,7 +254,8 @@ union e1000_rx_desc_packet_split {
 		} middle;
 		struct {
 			__le16 header_status;
-			__le16 length[3];	/* length of buffers 1-3 */
+			/* length of buffers 1-3 */
+			__le16 length[PS_PAGE_BUFFERS];
 		} upper;
 		__le64 reserved;
 	} wb; /* writeback */
-- 
1.7.11.7
