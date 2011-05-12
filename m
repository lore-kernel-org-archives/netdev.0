From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 1/9] iwlegacy: Silence DEBUG_STRICT_USER_COPY_CHECKS=y warning
Date: Thu, 12 May 2011 16:50:04 -0700
Message-ID: <1305244212-19183-2-git-send-email-sboyd@codeaurora.org>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:51853 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758896Ab1ELXuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:50:16 -0400
In-Reply-To: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
warning:

In file included from arch/x86/include/asm/uaccess.h:573,
                 from include/net/checksum.h:25,
                 from include/linux/skbuff.h:28,
                 from drivers/net/wireless/iwlegacy/iwl-4965-rs.c:28:
In function 'copy_from_user',
    inlined from 'iwl4965_rs_sta_dbgfs_scale_table_write' at
    drivers/net/wireless/iwlegacy/iwl-4965-rs.c:2616:
arch/x86/include/asm/uaccess_64.h:65:
warning: call to 'copy_from_user_overflow' declared with
attribute warning: copy_from_user() buffer size is not provably
correct

presumably due to buf_size being signed causing GCC to fail to
see that buf_size can't become negative.

Cc: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
index 31ac672..cc4751c 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
@@ -2604,7 +2604,7 @@ static ssize_t iwl4965_rs_sta_dbgfs_scale_table_write(struct file *file,
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

