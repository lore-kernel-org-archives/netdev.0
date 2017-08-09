From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] igbvf: convert msleep to mdelay in atomic context
Date: Wed,  9 Aug 2017 14:47:45 -0700
Message-ID: <20170809214746.28139-12-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Greg Edwards <gedwards@ddn.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31102 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752247AbdHIVr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:58 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Edwards <gedwards@ddn.com>

This fixes a "scheduling while atomic" splat seen with
CONFIG_DEBUG_ATOMIC_SLEEP enabled.

Signed-off-by: Greg Edwards <gedwards@ddn.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/vf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 1d3aa9adcaa8..9577ccf4b26a 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -149,7 +149,7 @@ static s32 e1000_reset_hw_vf(struct e1000_hw *hw)
 		msgbuf[0] = E1000_VF_RESET;
 		mbx->ops.write_posted(hw, msgbuf, 1);
 
-		msleep(10);
+		mdelay(10);
 
 		/* set our "perm_addr" based on info provided by PF */
 		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
-- 
2.13.3
