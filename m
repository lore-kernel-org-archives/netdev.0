From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/11 NEXT] rtlwifi: Modify cam.{c,h} and efuse.{c,h} for new drivers
Date: Mon, 22 Sep 2014 09:39:22 -0500
Message-ID: <1411396767-20611-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:54028 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbaIVOkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:40:01 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/cam.c   |  61 +++++-----
 drivers/net/wireless/rtlwifi/cam.h   |  10 +-
 drivers/net/wireless/rtlwifi/efuse.c | 224 ++++++++++++++++++-----------------
 drivers/net/wireless/rtlwifi/efuse.h |  17 ++-
 4 files changed, 156 insertions(+), 156 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 0276153..8fe8b4c 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -26,10 +22,9 @@
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
  *****************************************************************************/
-
-#include <linux/export.h>
 #include "wifi.h"
 #include "cam.h"
+#include <linux/export.h>
 
 void rtl_cam_reset_sec_info(struct ieee80211_hw *hw)
 {
@@ -52,8 +47,8 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 	u32 target_content = 0;
 	u8 entry_i;
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "key_cont_128: %6phC\n",
-		 key_cont_128);
+	RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_DMESG, "Key content :",
+		      key_cont_128, 16);
 
 	for (entry_i = 0; entry_i < CAM_CONTENT_COUNT; entry_i++) {
 		target_command = entry_i + CAM_CONTENT_COUNT * entry_no;
@@ -68,11 +63,13 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 			rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM],
 					target_command);
 
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE %x: %x\n",
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE %x: %x\n",
 				 rtlpriv->cfg->maps[WCAMI], target_content);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
 				 "The Key ID is %d\n", entry_no);
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE %x: %x\n",
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE %x: %x\n",
 				 rtlpriv->cfg->maps[RWCAM], target_command);
 
 		} else if (entry_i == 1) {
@@ -87,10 +84,10 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 			rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM],
 					target_command);
 
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A4: %x\n",
-				 target_content);
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A0: %x\n",
-				 target_command);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE A4: %x\n", target_content);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE A0: %x\n", target_command);
 
 		} else {
 
@@ -107,15 +104,15 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 					target_command);
 			udelay(100);
 
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A4: %x\n",
-				 target_content);
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A0: %x\n",
-				 target_command);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE A4: %x\n", target_content);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+				 "WRITE A0: %x\n", target_command);
 		}
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "after set key, usconfig:%x\n",
-		 us_config);
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+		 "after set key, usconfig:%x\n", us_config);
 }
 
 u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
@@ -125,27 +122,26 @@ u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 	u32 us_config;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 		 "EntryNo:%x, ulKeyId=%x, ulEncAlg=%x, ulUseDK=%x MacAddr %pM\n",
 		 ul_entry_idx, ul_key_id, ul_enc_alg,
 		 ul_default_key, mac_addr);
 
 	if (ul_key_id == TOTAL_CAM_ENTRY) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "<=== ulKeyId exceed!\n");
+			 "ulKeyId exceed!\n");
 		return 0;
 	}
 
-	if (ul_default_key == 1) {
+	if (ul_default_key == 1)
 		us_config = CFG_VALID | ((u16) (ul_enc_alg) << 2);
-	} else {
+	else
 		us_config = CFG_VALID | ((ul_enc_alg) << 2) | ul_key_id;
-	}
 
 	rtl_cam_program_entry(hw, ul_entry_idx, mac_addr,
-			      key_content, us_config);
+			      (u8 *)key_content, us_config);
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "<===\n");
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "end\n");
 
 	return 1;
 
@@ -289,7 +285,8 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	u8 i, *addr;
 
 	if (NULL == sta_addr) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
+			 "sta_addr is NULL.\n");
 		return TOTAL_CAM_ENTRY;
 	}
 	/* Does STA already exist? */
@@ -322,7 +319,9 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	u8 i, *addr;
 
 	if (NULL == sta_addr) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
+			 "sta_addr is NULL.\n");
+		return;
 	}
 
 	if (is_zero_ether_addr(sta_addr)) {
@@ -339,8 +338,8 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 			/* Remove from HW Security CAM */
 			eth_zero_addr(rtlpriv->sec.hwsec_cam_sta_addr[i]);
 			rtlpriv->sec.hwsec_cam_bitmap &= ~(BIT(0) << i);
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 "del CAM entry %d\n", i);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+				 "&&&&&&&&&del entry %d\n", i);
 		}
 	}
 	return;
diff --git a/drivers/net/wireless/rtlwifi/cam.h b/drivers/net/wireless/rtlwifi/cam.h
index 0105e6c..3550808 100644
--- a/drivers/net/wireless/rtlwifi/cam.h
+++ b/drivers/net/wireless/rtlwifi/cam.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -36,15 +32,15 @@
 #define CFG_VALID					BIT(15)
 
 #define PAIRWISE_KEYIDX					0
-#define CAM_PAIRWISE_KEY_POSITION		4
+#define CAM_PAIRWISE_KEY_POSITION			4
 
 #define	CAM_CONFIG_USEDK				1
 #define	CAM_CONFIG_NO_USEDK				0
 
 void rtl_cam_reset_all_entry(struct ieee80211_hw *hw);
 u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
-			 u32 ul_key_id, u32 ul_entry_idx, u32 ul_enc_alg,
-			 u32 ul_default_key, u8 *key_content);
+				u32 ul_key_id, u32 ul_entry_idx, u32 ul_enc_alg,
+				u32 ul_default_key, u8 *key_content);
 int rtl_cam_delete_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 			     u32 ul_key_id);
 void rtl_cam_mark_invalid(struct ieee80211_hw *hw, u8 uc_index);
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 2ffc729..118293b 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * tmis program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * Tme full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -26,10 +22,9 @@
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
  *****************************************************************************/
-
-#include <linux/export.h>
 #include "wifi.h"
 #include "efuse.h"
+#include <linux/export.h>
 
 static const u8 MAX_PGPKT_SIZE = 9;
 static const u8 PGPKT_DATA_SIZE = 8;
@@ -63,21 +58,19 @@ static void efuse_shadow_write_2byte(struct ieee80211_hw *hw, u16 offset,
 				     u16 value);
 static void efuse_shadow_write_4byte(struct ieee80211_hw *hw, u16 offset,
 				     u32 value);
-static int efuse_one_byte_read(struct ieee80211_hw *hw, u16 addr,
-					u8 *data);
 static int efuse_one_byte_write(struct ieee80211_hw *hw, u16 addr,
-					u8 data);
+				u8 data);
 static void efuse_read_all_map(struct ieee80211_hw *hw, u8 *efuse);
 static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset,
-					u8 *data);
+				u8 *data);
 static int efuse_pg_packet_write(struct ieee80211_hw *hw, u8 offset,
 				 u8 word_en, u8 *data);
 static void efuse_word_enable_data_read(u8 word_en, u8 *sourdata,
 					u8 *targetdata);
-static u8 efuse_word_enable_data_write(struct ieee80211_hw *hw,
-				       u16 efuse_addr, u8 word_en, u8 *data);
+static u8 enable_efuse_data_write(struct ieee80211_hw *hw,
+				  u16 efuse_addr, u8 word_en, u8 *data);
 static void efuse_power_switch(struct ieee80211_hw *hw, u8 write,
-					u8 pwrstate);
+			       u8 pwrstate);
 static u16 efuse_get_current_size(struct ieee80211_hw *hw);
 static u8 efuse_calculate_word_cnts(u8 word_en);
 
@@ -413,8 +406,7 @@ bool efuse_shadow_update_chk(struct ieee80211_hw *hw)
 	efuse_used = rtlefuse->efuse_usedbytes;
 
 	if ((totalbytes + efuse_used) >=
-	    (EFUSE_MAX_SIZE -
-	     rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))
+	    (EFUSE_MAX_SIZE - rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))
 		result = false;
 
 	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
@@ -428,13 +420,14 @@ void efuse_shadow_read(struct ieee80211_hw *hw, u8 type,
 		       u16 offset, u32 *value)
 {
 	if (type == 1)
-		efuse_shadow_read_1byte(hw, offset, (u8 *) value);
+		efuse_shadow_read_1byte(hw, offset, (u8 *)value);
 	else if (type == 2)
-		efuse_shadow_read_2byte(hw, offset, (u16 *) value);
+		efuse_shadow_read_2byte(hw, offset, (u16 *)value);
 	else if (type == 4)
 		efuse_shadow_read_4byte(hw, offset, value);
 
 }
+EXPORT_SYMBOL(efuse_shadow_read);
 
 void efuse_shadow_write(struct ieee80211_hw *hw, u8 type, u16 offset,
 				u32 value)
@@ -456,7 +449,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 	u8 word_en = 0x0F;
 	u8 first_pg = false;
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "--->\n");
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "\n");
 
 	if (!efuse_shadow_update_chk(hw)) {
 		efuse_read_all_map(hw, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0]);
@@ -465,7 +458,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 		       rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-			 "<---efuse out of capacity!!\n");
+			 "efuse out of capacity!!\n");
 		return false;
 	}
 	efuse_power_switch(hw, true, true);
@@ -477,7 +470,6 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 
 		for (i = 0; i < 8; i++) {
 			if (first_pg) {
-
 				word_en &= ~(BIT(i / 2));
 
 				rtlefuse->efuse_map[EFUSE_INIT_MAP][base + i] =
@@ -500,7 +492,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 			       &rtlefuse->efuse_map[EFUSE_MODIFY_MAP][base],
 			       8);
 			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD,
-				      "U-efuse", tmpdata, 8);
+				      "U-efuse\n", tmpdata, 8);
 
 			if (!efuse_pg_packet_write(hw, (u8) offset, word_en,
 						   tmpdata)) {
@@ -519,7 +511,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 	       &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
 	       rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "<---\n");
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "\n");
 	return true;
 }
 
@@ -529,14 +521,14 @@ void rtl_efuse_shadow_map_update(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 
 	if (rtlefuse->autoload_failflag)
-		memset(&rtlefuse->efuse_map[EFUSE_INIT_MAP][0], 0xFF,
-			rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
+		memset((&rtlefuse->efuse_map[EFUSE_INIT_MAP][0]),
+		       0xFF, rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 	else
 		efuse_read_all_map(hw, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0]);
 
 	memcpy(&rtlefuse->efuse_map[EFUSE_MODIFY_MAP][0],
-	       &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-	       rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
+			&rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
+			rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 
 }
 EXPORT_SYMBOL(rtl_efuse_shadow_map_update);
@@ -619,7 +611,7 @@ static void efuse_shadow_write_4byte(struct ieee80211_hw *hw,
 
 }
 
-static int efuse_one_byte_read(struct ieee80211_hw *hw, u16 addr, u8 *data)
+int efuse_one_byte_read(struct ieee80211_hw *hw, u16 addr, u8 *data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpidx = 0;
@@ -650,14 +642,15 @@ static int efuse_one_byte_read(struct ieee80211_hw *hw, u16 addr, u8 *data)
 	}
 	return result;
 }
+EXPORT_SYMBOL(efuse_one_byte_read);
 
 static int efuse_one_byte_write(struct ieee80211_hw *hw, u16 addr, u8 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpidx = 0;
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "Addr = %x Data=%x\n",
-		 addr, data);
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
+		 "Addr = %x Data=%x\n", addr, data);
 
 	rtl_write_byte(rtlpriv,
 		       rtlpriv->cfg->maps[EFUSE_CTRL] + 1, (u8) (addr & 0xff));
@@ -677,11 +670,10 @@ static int efuse_one_byte_write(struct ieee80211_hw *hw, u16 addr, u8 data)
 
 	if (tmpidx < 100)
 		return true;
-
 	return false;
 }
 
-static void efuse_read_all_map(struct ieee80211_hw *hw, u8 * efuse)
+static void efuse_read_all_map(struct ieee80211_hw *hw, u8 *efuse)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	efuse_power_switch(hw, false, true);
@@ -706,14 +698,14 @@ static void efuse_read_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 	if (hoffset == offset) {
 		for (tmpidx = 0; tmpidx < word_cnts * 2; tmpidx++) {
 			if (efuse_one_byte_read(hw, *efuse_addr + 1 + tmpidx,
-			    &efuse_data)) {
+						&efuse_data)) {
 				tmpdata[tmpidx] = efuse_data;
 				if (efuse_data != 0xff)
-					dataempty = true;
+					dataempty = false;
 			}
 		}
 
-		if (dataempty) {
+		if (!dataempty) {
 			*readstate = PG_STATE_DATA;
 		} else {
 			*efuse_addr = *efuse_addr + (word_cnts * 2) + 1;
@@ -729,7 +721,9 @@ static void efuse_read_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 {
 	u8 readstate = PG_STATE_HEADER;
+
 	bool continual = true;
+
 	u8 efuse_data, word_cnts = 0;
 	u16 efuse_addr = 0;
 	u8 tmpdata[8];
@@ -747,9 +741,8 @@ static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 			if (efuse_one_byte_read(hw, efuse_addr, &efuse_data)
 			    && (efuse_data != 0xFF))
 				efuse_read_data_case1(hw, &efuse_addr,
-						      efuse_data,
-						      offset, tmpdata,
-						      &readstate);
+						      efuse_data, offset,
+						      tmpdata, &readstate);
 			else
 				continual = false;
 		} else if (readstate & PG_STATE_DATA) {
@@ -771,13 +764,14 @@ static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 }
 
 static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
-			u8 efuse_data, u8 offset, int *continual,
-			u8 *write_state, struct pgpkt_struct *target_pkt,
-			int *repeat_times, int *result, u8 word_en)
+				   u8 efuse_data, u8 offset,
+				   int *continual, u8 *write_state,
+				   struct pgpkt_struct *target_pkt,
+				   int *repeat_times, int *result, u8 word_en)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct pgpkt_struct tmp_pkt;
-	bool dataempty = true;
+	int dataempty = true;
 	u8 originaldata[8 * sizeof(u8)];
 	u8 badworden = 0x0F;
 	u8 match_word_en, tmp_word_en;
@@ -794,9 +788,10 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 		*write_state = PG_STATE_HEADER;
 	} else {
 		for (tmpindex = 0; tmpindex < (tmp_word_cnts * 2); tmpindex++) {
-			u16 address = *efuse_addr + 1 + tmpindex;
-			if (efuse_one_byte_read(hw, address,
-			     &efuse_data) && (efuse_data != 0xFF))
+			if (efuse_one_byte_read(hw,
+						(*efuse_addr + 1 + tmpindex),
+						&efuse_data) &&
+			    (efuse_data != 0xFF))
 				dataempty = false;
 		}
 
@@ -806,33 +801,34 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 		} else {
 			match_word_en = 0x0F;
 			if (!((target_pkt->word_en & BIT(0)) |
-			     (tmp_pkt.word_en & BIT(0))))
+			    (tmp_pkt.word_en & BIT(0))))
 				match_word_en &= (~BIT(0));
 
 			if (!((target_pkt->word_en & BIT(1)) |
-			     (tmp_pkt.word_en & BIT(1))))
+			    (tmp_pkt.word_en & BIT(1))))
 				match_word_en &= (~BIT(1));
 
 			if (!((target_pkt->word_en & BIT(2)) |
-			     (tmp_pkt.word_en & BIT(2))))
+			    (tmp_pkt.word_en & BIT(2))))
 				match_word_en &= (~BIT(2));
 
 			if (!((target_pkt->word_en & BIT(3)) |
-			     (tmp_pkt.word_en & BIT(3))))
+			    (tmp_pkt.word_en & BIT(3))))
 				match_word_en &= (~BIT(3));
 
 			if ((match_word_en & 0x0F) != 0x0F) {
-				badworden = efuse_word_enable_data_write(
-							    hw, *efuse_addr + 1,
-							    tmp_pkt.word_en,
-							    target_pkt->data);
+				badworden =
+				  enable_efuse_data_write(hw,
+							  *efuse_addr + 1,
+							  tmp_pkt.word_en,
+							  target_pkt->data);
 
-				if (0x0F != (badworden & 0x0F)) {
+				if (0x0F != (badworden & 0x0F))	{
 					u8 reorg_offset = offset;
 					u8 reorg_worden = badworden;
 					efuse_pg_packet_write(hw, reorg_offset,
-							       reorg_worden,
-							       originaldata);
+							      reorg_worden,
+							      originaldata);
 				}
 
 				tmp_word_en = 0x0F;
@@ -845,11 +841,11 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 					tmp_word_en &= (~BIT(1));
 
 				if ((target_pkt->word_en & BIT(2)) ^
-				     (match_word_en & BIT(2)))
+				    (match_word_en & BIT(2)))
 					tmp_word_en &= (~BIT(2));
 
 				if ((target_pkt->word_en & BIT(3)) ^
-				     (match_word_en & BIT(3)))
+				    (match_word_en & BIT(3)))
 					tmp_word_en &= (~BIT(3));
 
 				if ((tmp_word_en & 0x0F) != 0x0F) {
@@ -873,7 +869,7 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 			}
 		}
 	}
-	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,  "efuse PG_STATE_HEADER-1\n");
+	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG, "efuse PG_STATE_HEADER-1\n");
 }
 
 static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
@@ -908,12 +904,13 @@ static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
 
 		tmp_word_cnts = efuse_calculate_word_cnts(tmp_pkt.word_en);
 
-		memset(originaldata, 0xff, 8 * sizeof(u8));
+		memset(originaldata, 0xff,  8 * sizeof(u8));
 
 		if (efuse_pg_packet_read(hw, tmp_pkt.offset, originaldata)) {
-			badworden = efuse_word_enable_data_write(hw,
-				    *efuse_addr + 1, tmp_pkt.word_en,
-				    originaldata);
+			badworden = enable_efuse_data_write(hw,
+							    *efuse_addr + 1,
+							    tmp_pkt.word_en,
+							    originaldata);
 
 			if (0x0F != (badworden & 0x0F)) {
 				u8 reorg_offset = tmp_pkt.offset;
@@ -923,8 +920,8 @@ static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
 						      originaldata);
 				*efuse_addr = efuse_get_current_size(hw);
 			} else {
-				*efuse_addr = *efuse_addr + (tmp_word_cnts * 2)
-					      + 1;
+				*efuse_addr = *efuse_addr +
+					      (tmp_word_cnts * 2) + 1;
 			}
 		} else {
 			*efuse_addr = *efuse_addr + (tmp_word_cnts * 2) + 1;
@@ -948,7 +945,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct pgpkt_struct target_pkt;
 	u8 write_state = PG_STATE_HEADER;
-	int continual = true, result = true;
+	int continual = true, dataempty = true, result = true;
 	u16 efuse_addr = 0;
 	u8 efuse_data;
 	u8 target_word_cnts = 0;
@@ -956,7 +953,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	static int repeat_times;
 
 	if (efuse_get_current_size(hw) >= (EFUSE_MAX_SIZE -
-	    rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
+		rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
 			"efuse_pg_packet_write error\n");
 		return false;
@@ -965,17 +962,18 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	target_pkt.offset = offset;
 	target_pkt.word_en = word_en;
 
-	memset(target_pkt.data, 0xFF, 8 * sizeof(u8));
+	memset(target_pkt.data, 0xFF,  8 * sizeof(u8));
 
 	efuse_word_enable_data_read(word_en, data, target_pkt.data);
 	target_word_cnts = efuse_calculate_word_cnts(target_pkt.word_en);
 
-	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,  "efuse Power ON\n");
+	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG, "efuse Power ON\n");
 
 	while (continual && (efuse_addr < (EFUSE_MAX_SIZE -
-	       rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))) {
+		rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN]))) {
 
 		if (write_state == PG_STATE_HEADER) {
+			dataempty = true;
 			badworden = 0x0F;
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
 				"efuse PG_STATE_HEADER\n");
@@ -985,7 +983,8 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 				efuse_write_data_case1(hw, &efuse_addr,
 						       efuse_data, offset,
 						       &continual,
-						       &write_state, &target_pkt,
+						       &write_state,
+						       &target_pkt,
 						       &repeat_times, &result,
 						       word_en);
 			else
@@ -999,15 +998,17 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 		} else if (write_state == PG_STATE_DATA) {
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
 				"efuse PG_STATE_DATA\n");
+			badworden = 0x0f;
 			badworden =
-			    efuse_word_enable_data_write(hw, efuse_addr + 1,
-							 target_pkt.word_en,
-							 target_pkt.data);
+			    enable_efuse_data_write(hw, efuse_addr + 1,
+						    target_pkt.word_en,
+						    target_pkt.data);
 
 			if ((badworden & 0x0F) == 0x0F) {
 				continual = false;
 			} else {
-				efuse_addr += (2 * target_word_cnts) + 1;
+				efuse_addr =
+				    efuse_addr + (2 * target_word_cnts) + 1;
 
 				target_pkt.offset = offset;
 				target_pkt.word_en = badworden;
@@ -1027,7 +1028,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	}
 
 	if (efuse_addr >= (EFUSE_MAX_SIZE -
-	    rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
+		rtlpriv->cfg->maps[EFUSE_OOB_PROTECT_BYTES_LEN])) {
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
 			 "efuse_addr(%#x) Out of size!!\n", efuse_addr);
 	}
@@ -1035,8 +1036,8 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	return true;
 }
 
-static void efuse_word_enable_data_read(u8 word_en,
-					u8 *sourdata, u8 *targetdata)
+static void efuse_word_enable_data_read(u8 word_en, u8 *sourdata,
+					u8 *targetdata)
 {
 	if (!(word_en & BIT(0))) {
 		targetdata[0] = sourdata[0];
@@ -1059,8 +1060,8 @@ static void efuse_word_enable_data_read(u8 word_en,
 	}
 }
 
-static u8 efuse_word_enable_data_write(struct ieee80211_hw *hw,
-				       u16 efuse_addr, u8 word_en, u8 *data)
+static u8 enable_efuse_data_write(struct ieee80211_hw *hw,
+				  u16 efuse_addr, u8 word_en, u8 *data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 tmpaddr;
@@ -1069,8 +1070,8 @@ static u8 efuse_word_enable_data_write(struct ieee80211_hw *hw,
 	u8 tmpdata[8];
 
 	memset(tmpdata, 0xff, PGPKT_DATA_SIZE);
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "word_en = %x efuse_addr=%x\n",
-		 word_en, efuse_addr);
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
+		 "word_en = %x efuse_addr=%x\n", word_en, efuse_addr);
 
 	if (!(word_en & BIT(0))) {
 		tmpaddr = start_addr;
@@ -1127,19 +1128,22 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 	u16 tmpV16;
 
 	if (pwrstate && (rtlhal->hw_type != HARDWARE_TYPE_RTL8192SE)) {
-		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE)
-			rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[EFUSE_ACCESS],
-				       0x69);
 
-		tmpV16 = rtl_read_word(rtlpriv,
-				       rtlpriv->cfg->maps[SYS_ISO_CTRL]);
-		if (!(tmpV16 & rtlpriv->cfg->maps[EFUSE_PWC_EV12V])) {
-			tmpV16 |= rtlpriv->cfg->maps[EFUSE_PWC_EV12V];
-			rtl_write_word(rtlpriv,
-				       rtlpriv->cfg->maps[SYS_ISO_CTRL],
-				       tmpV16);
+		if (rtlhal->hw_type != HARDWARE_TYPE_RTL8192CE &&
+		    rtlhal->hw_type != HARDWARE_TYPE_RTL8192DE) {
+			rtl_write_byte(rtlpriv,
+				       rtlpriv->cfg->maps[EFUSE_ACCESS], 0x69);
+		} else {
+			tmpV16 =
+			  rtl_read_word(rtlpriv,
+					rtlpriv->cfg->maps[SYS_ISO_CTRL]);
+			if (!(tmpV16 & rtlpriv->cfg->maps[EFUSE_PWC_EV12V])) {
+				tmpV16 |= rtlpriv->cfg->maps[EFUSE_PWC_EV12V];
+				rtl_write_word(rtlpriv,
+					       rtlpriv->cfg->maps[SYS_ISO_CTRL],
+					       tmpV16);
+			}
 		}
-
 		tmpV16 = rtl_read_word(rtlpriv,
 				       rtlpriv->cfg->maps[SYS_FUNC_EN]);
 		if (!(tmpV16 & rtlpriv->cfg->maps[EFUSE_FEN_ELDR])) {
@@ -1164,7 +1168,10 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 						rtlpriv->cfg->maps[EFUSE_TEST] +
 						3);
 
-			if (rtlhal->hw_type != HARDWARE_TYPE_RTL8192SE) {
+			if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+				tempval &= ~(BIT(3) | BIT(4) | BIT(5) | BIT(6));
+				tempval |= (VOLTAGE_V25 << 3);
+			} else if (rtlhal->hw_type != HARDWARE_TYPE_RTL8192SE) {
 				tempval &= 0x0F;
 				tempval |= (VOLTAGE_V25 << 4);
 			}
@@ -1176,11 +1183,11 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 
 		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192SE) {
 			rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[EFUSE_CLK],
-						0x03);
+				       0x03);
 		}
-
 	} else {
-		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE)
+		if (rtlhal->hw_type != HARDWARE_TYPE_RTL8192CE &&
+		    rtlhal->hw_type != HARDWARE_TYPE_RTL8192DE)
 			rtl_write_byte(rtlpriv,
 				       rtlpriv->cfg->maps[EFUSE_ACCESS], 0);
 
@@ -1195,27 +1202,28 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 
 		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192SE) {
 			rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[EFUSE_CLK],
-						0x02);
+				       0x02);
 		}
-
 	}
-
 }
 
 static u16 efuse_get_current_size(struct ieee80211_hw *hw)
 {
+	int continual = true;
 	u16 efuse_addr = 0;
-	u8 hworden;
+	u8 hoffset, hworden;
 	u8 efuse_data, word_cnts;
 
-	while (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
-	       efuse_addr < EFUSE_MAX_SIZE) {
-		if (efuse_data == 0xFF)
-			break;
-
-		hworden = efuse_data & 0x0F;
-		word_cnts = efuse_calculate_word_cnts(hworden);
-		efuse_addr = efuse_addr + (word_cnts * 2) + 1;
+	while (continual && efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
+	       (efuse_addr < EFUSE_MAX_SIZE)) {
+		if (efuse_data != 0xFF) {
+			hoffset = (efuse_data >> 4) & 0x0F;
+			hworden = efuse_data & 0x0F;
+			word_cnts = efuse_calculate_word_cnts(hworden);
+			efuse_addr = efuse_addr + (word_cnts * 2) + 1;
+		} else {
+			continual = false;
+		}
 	}
 
 	return efuse_addr;
diff --git a/drivers/net/wireless/rtlwifi/efuse.h b/drivers/net/wireless/rtlwifi/efuse.h
index 1663b3a..fdab824 100644
--- a/drivers/net/wireless/rtlwifi/efuse.h
+++ b/drivers/net/wireless/rtlwifi/efuse.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -32,7 +28,6 @@
 
 #define EFUSE_IC_ID_OFFSET		506
 
-#define EFUSE_MAP_LEN			128
 #define EFUSE_MAX_WORD_UNIT		4
 
 #define EFUSE_INIT_MAP			0
@@ -107,12 +102,14 @@ struct efuse_priv {
 void read_efuse_byte(struct ieee80211_hw *hw, u16 _offset, u8 *pbuf);
 void efuse_initialize(struct ieee80211_hw *hw);
 u8 efuse_read_1byte(struct ieee80211_hw *hw, u16 address);
+int efuse_one_byte_read(struct ieee80211_hw *hw, u16 addr, u8 *data);
 void efuse_write_1byte(struct ieee80211_hw *hw, u16 address, u8 value);
-void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf);
-void efuse_shadow_read(struct ieee80211_hw *hw, u8 type, u16 offset,
-		       u32 *value);
-void efuse_shadow_write(struct ieee80211_hw *hw, u8 type, u16 offset,
-			u32 value);
+void read_efuse(struct ieee80211_hw *hw, u16 _offset,
+		u16 _size_byte, u8 *pbuf);
+void efuse_shadow_read(struct ieee80211_hw *hw, u8 type,
+		       u16 offset, u32 *value);
+void efuse_shadow_write(struct ieee80211_hw *hw, u8 type,
+			u16 offset, u32 value);
 bool efuse_shadow_update(struct ieee80211_hw *hw);
 bool efuse_shadow_update_chk(struct ieee80211_hw *hw);
 void rtl_efuse_shadow_map_update(struct ieee80211_hw *hw);
-- 
1.8.4.5
