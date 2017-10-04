From: =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
Subject: [PATCH 1/3] wireless: iwlwifi: use bool instead of int
Date: Wed,  4 Oct 2017 17:56:58 +0200
Message-ID: <20171004155700.18048-2-christoph@boehmwalder.at>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-1-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change a usage of int in a boolean context to use the bool type instead, as it
makes the intent of the function clearer and helps clarify its semantics.

Also eliminate the if/else and just return the boolean result directly,
making the code more readable.

Signed-off-by: Christoph Böhmwalder <christoph@boehmwalder.at>
---
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
index b7cd813ba70f..0eb815ae97e8 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
@@ -267,14 +267,12 @@ int iwl_phy_db_set_section(struct iwl_phy_db *phy_db,
 }
 IWL_EXPORT_SYMBOL(iwl_phy_db_set_section);
 
-static int is_valid_channel(u16 ch_id)
+static bool is_valid_channel(u16 ch_id)
 {
-	if (ch_id <= 14 ||
-	    (36 <= ch_id && ch_id <= 64 && ch_id % 4 == 0) ||
-	    (100 <= ch_id && ch_id <= 140 && ch_id % 4 == 0) ||
-	    (145 <= ch_id && ch_id <= 165 && ch_id % 4 == 1))
-		return 1;
-	return 0;
+	return (ch_id <= 14 ||
+	       (36 <= ch_id && ch_id <= 64 && ch_id % 4 == 0) ||
+	       (100 <= ch_id && ch_id <= 140 && ch_id % 4 == 0) ||
+	       (145 <= ch_id && ch_id <= 165 && ch_id % 4 == 1));
 }
 
 static u8 ch_id_to_ch_index(u16 ch_id)
-- 
2.13.5
