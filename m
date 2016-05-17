From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: i40e: avoid null pointer dereference
Date: Tue, 17 May 2016 22:41:33 +0200
Message-ID: <1463517693-10333-1-git-send-email-xypron.glpk@gmx.de>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function i40e_debug_aq parameter desc is assumed to be
possibly NULL. Do not dereference it before checking the
value.

Fixes: f905dd62be88 ("i40e/i40evf: add max buf len to aq debug print helper")
Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 422b41d..d5cb570 100644
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
2.1.4
