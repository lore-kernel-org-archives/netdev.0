From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH] iwlwifi: Demote messages about fw flags size to info
Date: Fri, 21 Jul 2017 07:51:47 -0700
Message-ID: <20170721145147.7572-1-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux@endlessm.com,
        =?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These messages are not reporting a real error, just the fact that the
firmware knows about more flags then the driver.

Currently these messages are presented to the user during boot if there
is no bootsplash covering the console, sometimes even if the boot splash
is enabled but has not started yet by the time this message is shown.

Demoting it to the info level helps having a clean boot process.

Signed-off-by: João Paulo Rechi Vita <jprvita@endlessm.com>
---
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
index 6fdb5921e17f..557acd43d705 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
@@ -487,9 +487,9 @@ static int iwl_set_ucode_api_flags(struct iwl_drv *drv, const u8 *data,
 	int i;
 
 	if (api_index >= DIV_ROUND_UP(NUM_IWL_UCODE_TLV_API, 32)) {
-		IWL_ERR(drv,
-			"api flags index %d larger than supported by driver\n",
-			api_index);
+		IWL_INFO(drv,
+			 "api flags index %d larger than supported by driver\n",
+			 api_index);
 		/* don't return an error so we can load FW that has more bits */
 		return 0;
 	}
@@ -511,9 +511,9 @@ static int iwl_set_ucode_capabilities(struct iwl_drv *drv, const u8 *data,
 	int i;
 
 	if (api_index >= DIV_ROUND_UP(NUM_IWL_UCODE_TLV_CAPA, 32)) {
-		IWL_ERR(drv,
-			"capa flags index %d larger than supported by driver\n",
-			api_index);
+		IWL_INFO(drv,
+			 "capa flags index %d larger than supported by driver\n",
+			 api_index);
 		/* don't return an error so we can load FW that has more bits */
 		return 0;
 	}
-- 
2.13.2
