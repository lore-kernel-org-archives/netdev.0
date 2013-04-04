From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] ixgbe: don't do arithmetic operations on bitmasks
Date: Thu,  4 Apr 2013 04:37:49 -0700
Message-ID: <1365075480-20183-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758845Ab3DDLiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:22 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Make the calculation of eerd consistent between the read and write functions
by using | instead of + for IXGBE_EEPROM_RW_REG_START

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 99e472e..f8d3dec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1125,7 +1125,7 @@ s32 ixgbe_read_eerd_buffer_generic(struct ixgbe_hw *hw, u16 offset,
 	}
 
 	for (i = 0; i < words; i++) {
-		eerd = ((offset + i) << IXGBE_EEPROM_RW_ADDR_SHIFT) +
+		eerd = ((offset + i) << IXGBE_EEPROM_RW_ADDR_SHIFT) |
 		       IXGBE_EEPROM_RW_REG_START;
 
 		IXGBE_WRITE_REG(hw, IXGBE_EERD, eerd);
-- 
1.7.11.7
