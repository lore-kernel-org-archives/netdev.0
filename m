From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 2/9] iwlwifi: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
Date: Thu, 12 May 2011 16:50:05 -0700
Message-ID: <1305244212-19183-3-git-send-email-sboyd@codeaurora.org>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
warning:

In file included from arch/x86/include/asm/uaccess.h:573,
                 from include/net/checksum.h:25,
                 from include/linux/skbuff.h:28,
                 from drivers/net/wireless/iwlwifi/iwl-agn-rs.c:28:
In function 'copy_from_user',
    inlined from 'rs_sta_dbgfs_scale_table_write' at
    drivers/net/wireless/iwlwifi/iwl-agn-rs.c:3099:
arch/x86/include/asm/uaccess_64.h:65:
warning: call to 'copy_from_user_overflow' declared with
attribute warning: copy_from_user() buffer size is not provably
correct

presumably due to buf_size being signed causing GCC to fail to
see that buf_size can't become negative.

Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index d03b473..abcc9f2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -3087,7 +3087,7 @@ static ssize_t rs_sta_dbgfs_scale_table_write(struct file *file,
 	struct iwl_lq_sta *lq_sta = file->private_data;
 	struct iwl_priv *priv;
 	char buf[64];
-	int buf_size;
+	size_t buf_size;
 	u32 parsed_rate;
 	struct iwl_station_priv *sta_priv =
 		container_of(lq_sta, struct iwl_station_priv, lq_sta);
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
