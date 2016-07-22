From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e: avoid null pointer dereference
Date: Fri, 22 Jul 2016 00:36:29 -0700
Message-ID: <1469172999-8969-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Heinrich Schuchardt <xypron.glpk@gmx.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37308 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbcGVHgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:48 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>

In function i40e_debug_aq parameter desc is assumed to be
possibly NULL. Do not dereference it before checking the
value.

Fixes: f905dd62be88 ("i40e/i40evf: add max buf len to aq debug print helper")
Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index e447dc4..bb63df8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -297,13 +297,15 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		   void *buffer, u16 buf_len)
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
-	u16 len = le16_to_cpu(aq_desc->datalen);
+	u16 len;
 	u8 *buf = (u8 *)buffer;
 	u16 i = 0;
 
 	if ((!(mask & hw->debug_mask)) || (desc == NULL))
 		return;
 
+	len = le16_to_cpu(aq_desc->datalen);
+
 	i40e_debug(hw, mask,
 		   "AQ CMD: opcode 0x%04X, flags 0x%04X, datalen 0x%04X, retval 0x%04X\n",
 		   le16_to_cpu(aq_desc->opcode),
-- 
2.5.5
