From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: use register for XL722 control register read/write
Date: Wed, 29 Mar 2017 03:12:05 -0700
Message-ID: <20170329101215.24513-4-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54616 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755087AbdC2KMW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:22 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

The XL722 doesn't support the AQ command to read/write the control
register so enable it to bypass the check and use the direct read/write
method.

Change-ID: Iefecc737b57207485c90845af5989d5af518bf16
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 8 ++++++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 95946f41002b..f9db95aa3a20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -4963,7 +4963,9 @@ u32 i40e_read_rx_ctl(struct i40e_hw *hw, u32 reg_addr)
 	int retry = 5;
 	u32 val = 0;
 
-	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
+	use_register = (((hw->aq.api_maj_ver == 1) &&
+			(hw->aq.api_min_ver < 5)) ||
+			(hw->mac.type == I40E_MAC_X722));
 	if (!use_register) {
 do_retry:
 		status = i40e_aq_rx_ctl_read_register(hw, reg_addr, &val, NULL);
@@ -5022,7 +5024,9 @@ void i40e_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
 	bool use_register;
 	int retry = 5;
 
-	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
+	use_register = (((hw->aq.api_maj_ver == 1) &&
+			(hw->aq.api_min_ver < 5)) ||
+			(hw->mac.type == I40E_MAC_X722));
 	if (!use_register) {
 do_retry:
 		status = i40e_aq_rx_ctl_write_register(hw, reg_addr,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 89dfdbca13db..626fbf1ead4d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -958,7 +958,9 @@ u32 i40evf_read_rx_ctl(struct i40e_hw *hw, u32 reg_addr)
 	int retry = 5;
 	u32 val = 0;
 
-	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
+	use_register = (((hw->aq.api_maj_ver == 1) &&
+			(hw->aq.api_min_ver < 5)) ||
+			(hw->mac.type == I40E_MAC_X722));
 	if (!use_register) {
 do_retry:
 		status = i40evf_aq_rx_ctl_read_register(hw, reg_addr,
@@ -1019,7 +1021,9 @@ void i40evf_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
 	bool use_register;
 	int retry = 5;
 
-	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
+	use_register = (((hw->aq.api_maj_ver == 1) &&
+			(hw->aq.api_min_ver < 5)) ||
+			(hw->mac.type == I40E_MAC_X722));
 	if (!use_register) {
 do_retry:
 		status = i40evf_aq_rx_ctl_write_register(hw, reg_addr,
-- 
2.12.0
