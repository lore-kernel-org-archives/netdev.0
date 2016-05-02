From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e/i40evf: fix I40E_MASK signed shift overflow warnings
Date: Sun,  1 May 2016 17:06:18 -0700
Message-ID: <1462147581-135254-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbcEBAGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:34 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

GCC 6 has a new warning which will display when you attempt to left
shift a signed value beyond the storage size of the type. I40E_MASK
generates a mask value for 32bit registers. Properly typecast the mask
value and place the values in parenthesis to prevent macro expansion
issues.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 8aa14aa..bd5f13b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -36,7 +36,7 @@
 #include "i40e_devids.h"
 
 /* I40E_MASK is a macro used on 32 bit registers */
-#define I40E_MASK(mask, shift) (mask << shift)
+#define I40E_MASK(mask, shift) ((u32)(mask) << (shift))
 
 #define I40E_MAX_VSI_QP			16
 #define I40E_MAX_VF_VSI			3
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index bfc97c2..97f96e0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -36,7 +36,7 @@
 #include "i40e_devids.h"
 
 /* I40E_MASK is a macro used on 32 bit registers */
-#define I40E_MASK(mask, shift) (mask << shift)
+#define I40E_MASK(mask, shift) ((u32)(mask) << (shift))
 
 #define I40E_MAX_VSI_QP			16
 #define I40E_MAX_VF_VSI			3
-- 
2.5.5
