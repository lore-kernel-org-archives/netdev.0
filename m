From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Fix potential out of bound array access
Date: Tue, 20 Jun 2017 18:17:54 -0700
Message-ID: <20170621011802.81768-8-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7623 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753017AbdFUBSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:16 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

This is a fix for the static code analysis issue where dcbcfg->numapps
could be greater than size of array (i.e dcbcfg->app[I40E_DCBX_MAX_APPS]).
The fix makes sure that the array is not accessed past the size of
of the array (i.e. I40E_DCBX_MAX_APPS).

Copyright updated to 2017.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 0fab3a9b51d9..bf1d67e184f7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -390,6 +390,8 @@ static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
 
 	if (!dcbcfg->numapps)
 		return;
+	if (dcbcfg->numapps > I40E_DCBX_MAX_APPS)
+		dcbcfg->numapps = I40E_DCBX_MAX_APPS;
 
 	for (i = 0; i < dcbcfg->numapps; i++) {
 		u8 up, selector;
-- 
2.12.2
