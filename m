From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: prevent snprintf format specifier truncation
Date: Sun, 27 Aug 2017 17:15:51 -0700
Message-ID: <20170828001603.75876-4-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47467 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751646AbdH1AQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:18 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Increase the size of the prefix buffer so that it can hold enough
characters for every possible input. Although 20 is enough for all
expected inputs, it is possible for the values to be larger than
expected, resulting in a possibly truncated string. Additionally, lets
use sizeof(prefix) in order to ensure we use the correct size if we need
to change the array length in the future.

New versions of GCC starting at 7 now include warnings to prevent
truncation unless you handle the return code. At most 27 bytes can be
written here, so lets just increase the buffer size even if for all
expected hw->bus.* values we only needed 20.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 5c36a18a31be..111426ba5fbc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -328,9 +328,9 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			len = buf_len;
 		/* write the full 16-byte chunks */
 		if (hw->debug_mask & mask) {
-			char prefix[20];
+			char prefix[27];
 
-			snprintf(prefix, 20,
+			snprintf(prefix, sizeof(prefix),
 				 "i40e %02x:%02x.%x: \t0x",
 				 hw->bus.bus_id,
 				 hw->bus.device,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index d69c2e44cd1a..8d3a2bfe186a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -333,9 +333,9 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			len = buf_len;
 		/* write the full 16-byte chunks */
 		if (hw->debug_mask & mask) {
-			char prefix[20];
+			char prefix[27];
 
-			snprintf(prefix, 20,
+			snprintf(prefix, sizeof(prefix),
 				 "i40evf %02x:%02x.%x: \t0x",
 				 hw->bus.bus_id,
 				 hw->bus.device,
-- 
2.14.1
