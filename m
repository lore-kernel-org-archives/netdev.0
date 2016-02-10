From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] iwlwifi: fix erroneous return value
Date: Wed, 10 Feb 2016 12:08:33 -0500
Message-ID: <1455124113-27024-1-git-send-email-a.s.protopopov@gmail.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anton Protopopov <a.s.protopopov@gmail.com>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eran Harary <eran.harary@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iwl_trans_pcie_start_fw() function may return the positive value EIO
instead of -EIO in case of error.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/trans.c b/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
index d60a467..920ea9d 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
@@ -1034,7 +1034,7 @@ static int iwl_trans_pcie_start_fw(struct iwl_trans *trans,
 	if (trans_pcie->is_down) {
 		IWL_WARN(trans,
 			 "Can't start_fw since the HW hasn't been started\n");
-		ret = EIO;
+		ret = -EIO;
 		goto out;
 	}
 
-- 
2.6.5
