From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH v3] iwlwifi: Demote messages about fw flags size to info
Date: Thu,  3 Aug 2017 07:47:28 -0700
Message-ID: <20170803144728.32305-1-jprvita@endlessm.com>
References: <063D6719AE5E284EB5DD2968C1650D6DD004A3CC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux@endlessm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        =?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD004A3CC@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These messages are not reporting a real error, just the fact that the
firmware knows about more flags than the driver.

Currently these messages are presented to the user during boot if there
is no bootsplash covering the console, even when booting the kernel with
"quiet".

Demoting it to the warn level helps having a clean boot process.

Signed-off-by: João Paulo Rechi Vita <jprvita@endlessm.com>
---

v2 changes:
 - Set to warn level instead of info

v3 changes:
 - Fix commit message typo

 drivers/net/wireless/intel/iwlwifi/iwl-drv.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
index be466a074c1d..c98a254bbd4d 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
@@ -461,9 +461,9 @@ static int iwl_set_ucode_api_flags(struct iwl_drv *drv, const u8 *data,
 	int i;
 
 	if (api_index >= DIV_ROUND_UP(NUM_IWL_UCODE_TLV_API, 32)) {
-		IWL_ERR(drv,
-			"api flags index %d larger than supported by driver\n",
-			api_index);
+		IWL_WARN(drv,
+			 "api flags index %d larger than supported by driver\n",
+			 api_index);
 		/* don't return an error so we can load FW that has more bits */
 		return 0;
 	}
@@ -485,9 +485,9 @@ static int iwl_set_ucode_capabilities(struct iwl_drv *drv, const u8 *data,
 	int i;
 
 	if (api_index >= DIV_ROUND_UP(NUM_IWL_UCODE_TLV_CAPA, 32)) {
-		IWL_ERR(drv,
-			"capa flags index %d larger than supported by driver\n",
-			api_index);
+		IWL_WARN(drv,
+			 "capa flags index %d larger than supported by driver\n",
+			 api_index);
 		/* don't return an error so we can load FW that has more bits */
 		return 0;
 	}
-- 
2.13.2
