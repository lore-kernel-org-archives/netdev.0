From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] fm10k: simplify reading PFVFLRE register
Date: Mon,  2 Oct 2017 08:42:32 -0700
Message-ID: <20171002154236.84043-10-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751587AbdJBPm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:59 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We're doing a really convoluted bitshift and read for the PFVFLRE
register. Just reading the PFVFLRE(1), shifting it by 32, then reading
PFVFLRE(0) should be sufficient.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index d8356c494f06..dfc88a463735 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -1,5 +1,5 @@
 /* Intel(R) Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2016 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -67,10 +67,8 @@ s32 fm10k_iov_event(struct fm10k_intfc *interface)
 
 	/* read VFLRE to determine if any VFs have been reset */
 	do {
-		vflre = fm10k_read_reg(hw, FM10K_PFVFLRE(0));
+		vflre = fm10k_read_reg(hw, FM10K_PFVFLRE(1));
 		vflre <<= 32;
-		vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(1));
-		vflre = (vflre << 32) | (vflre >> 32);
 		vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(0));
 
 		i = iov_data->num_vfs;
-- 
2.14.2
