From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] rtlwifi: Remove addressof casts to same type
Date: Mon, 24 Mar 2014 10:46:20 -0700
Message-ID: <1395683180.13968.61.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using addressof then casting to the original type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast.cocci 
@@
type T;
T foo;
@@

-	(T *)&foo
+	&foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/pci.c          | 4 ++--
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c | 9 ++++-----
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c | 7 +++----
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c | 7 +++----
 4 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index f26f4ff..7d71170 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1509,10 +1509,10 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 
 	if (rtlpriv->use_new_trx_flow) {
 		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true,
-					    HW_DESC_OWN, (u8 *)&hw_queue);
+					    HW_DESC_OWN, &hw_queue);
 	} else {
 		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true,
-					    HW_DESC_OWN, (u8 *)&temp_one);
+					    HW_DESC_OWN, &temp_one);
 	}
 
 	if ((ring->entries - skb_queue_len(&ring->queue)) < 2 &&
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index bd2a26b..5a30e4e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -1828,7 +1828,7 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid);
 	/*customer ID*/
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 	if (rtlefuse->eeprom_oemid == 0xFF)
 		rtlefuse->eeprom_oemid = 0;
 
@@ -1845,7 +1845,7 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "dev_addr: %pM\n", rtlefuse->dev_addr);
 	/*channel plan */
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	/* set channel paln to world wide 13 */
 	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
 	/*tx power*/
@@ -1857,7 +1857,7 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 						 rtlefuse->autoload_failflag,
 						 hwinfo);
 	/*board type*/
-	rtlefuse->board_type = (((*(u8 *)&hwinfo[jj]) & 0xE0) >> 5);
+	rtlefuse->board_type = (hwinfo[jj] & 0xE0) >> 5;
 	/*Wake on wlan*/
 	rtlefuse->wowlan_enable = ((hwinfo[kk] & 0x40) >> 6);
 	/*parse xtal*/
@@ -2223,8 +2223,7 @@ void rtl88ee_update_channel_access_setting(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u16 sifs_timer;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME, &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index f4c9852..dd383b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -1628,10 +1628,10 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 	rtl8723ae_read_bt_coexist_info_from_hwpg(hw,
 			rtlefuse->autoload_failflag, hwinfo);
 
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->eeprom_version = *(u16 *)&hwinfo[EEPROM_VERSION];
 	rtlefuse->txpwr_fromeprom = true;
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
@@ -2051,8 +2051,7 @@ void rtl8723ae_update_channel_access_setting(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u16 sifs_timer;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME, &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index 7e70c71..223728d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -1783,10 +1783,10 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 						 rtlefuse->autoload_failflag,
 						 hwinfo);
 
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->eeprom_version = *(u16 *)&hwinfo[EEPROM_VERSION];
 	rtlefuse->txpwr_fromeprom = true;
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
@@ -2252,8 +2252,7 @@ void rtl8723be_update_channel_access_setting(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u16 sifs_timer;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME, &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
