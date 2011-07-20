From: Joe Perches <joe@perches.com>
Subject: [PATCH] rtlwifi: Convert printks to pr_<level>
Date: Wed, 20 Jul 2011 08:51:35 -0700
Message-ID: <b57f00fc1d0947443aa1830c11c288e78924af44.1311177059.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging styles.
Add pr_fmt where appropriate.
Remove now unnecessary prefixes from printks.
Convert hard coded prefix to __func__.
Add a missing "\n" to a format.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/base.c               |    9 ++-
 drivers/net/wireless/rtlwifi/cam.c                |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c       |   69 ++++++++------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |   11 ++-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c       |   10 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c      |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c       |    6 +-
 drivers/net/wireless/rtlwifi/usb.c                |   12 ++--
 11 files changed, 72 insertions(+), 71 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index bc13533..d88e405 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ip.h>
 #include "wifi.h"
 #include "rc.h"
@@ -397,8 +399,8 @@ void rtl_init_rfkill(struct ieee80211_hw *hw)
 	radio_state = rtlpriv->cfg->ops->radio_onoff_checking(hw, &valid);
 
 	if (valid) {
-		printk(KERN_INFO "rtlwifi: wireless switch is %s\n",
-				rtlpriv->rfkill.rfkill_state ? "on" : "off");
+		pr_info("wireless switch is %s\n",
+			rtlpriv->rfkill.rfkill_state ? "on" : "off");
 
 		rtlpriv->rfkill.rfkill_state = radio_state;
 
@@ -1402,8 +1404,7 @@ MODULE_DESCRIPTION("Realtek 802.11n PCI wireless core");
 static int __init rtl_core_module_init(void)
 {
 	if (rtl_rate_control_register())
-		printk(KERN_ERR "rtlwifi: Unable to register rtl_rc,"
-		       "use default RC !!\n");
+		pr_err("Unable to register rtl_rc, use default RC !!\n");
 
 	return 0;
 }
diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 7295af0..b12a668 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "wifi.h"
 #include "cam.h"
 
@@ -347,7 +349,7 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 			/* Remove from HW Security CAM */
 			memset(rtlpriv->sec.hwsec_cam_sta_addr[i], 0, ETH_ALEN);
 			rtlpriv->sec.hwsec_cam_bitmap &= ~(BIT(0) << i);
-			printk(KERN_INFO "&&&&&&&&&del entry %d\n", i);
+			pr_info("&&&&&&&&&del entry %d\n", i);
 		}
 	}
 	return;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index f9f2370..49a064b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/firmware.h>
 #include "../wifi.h"
 #include "../pci.h"
@@ -224,8 +226,7 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 	u32 fwsize;
 	enum version_8192c version = rtlhal->version;
 
-	printk(KERN_INFO "rtl8192c: Loading firmware file %s\n",
-	       rtlpriv->cfg->fw_name);
+	pr_info("Loading firmware file %s\n", rtlpriv->cfg->fw_name);
 	if (!rtlhal->pfirmware)
 		return 1;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 2b34764..814c05d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "../wifi.h"
 #include "../efuse.h"
 #include "../base.h"
@@ -337,7 +339,7 @@ static void _rtl92cu_read_board_type(struct ieee80211_hw *hw, u8 *contents)
 	rtlefuse->board_type = boardType;
 	if (IS_HIGHT_PA(rtlefuse->board_type))
 		rtlefuse->external_pa = 1;
-	printk(KERN_INFO "rtl8192cu: Board Type %x\n", rtlefuse->board_type);
+	pr_info("Board Type %x\n", rtlefuse->board_type);
 
 #ifdef CONFIG_ANTENNA_DIVERSITY
 	/* Antenna Diversity setting. */
@@ -346,8 +348,7 @@ static void _rtl92cu_read_board_type(struct ieee80211_hw *hw, u8 *contents)
 	else
 		rtl_efuse->antenna_cfg = registry_par->antdiv_cfg; /* 0:OFF, */
 
-	printk(KERN_INFO "rtl8192cu: Antenna Config %x\n",
-	       rtl_efuse->antenna_cfg);
+	pr_info("Antenna Config %x\n", rtl_efuse->antenna_cfg);
 #endif
 }
 
@@ -384,71 +385,57 @@ static void _update_bt_param(_adapter *padapter)
 	pbtpriv->bBTNonTrafficModeSet = _FALSE;
 	pbtpriv->CurrentState = 0;
 	pbtpriv->PreviousState = 0;
-	printk(KERN_INFO "rtl8192cu: BT Coexistance = %s\n",
-	       (pbtpriv->BT_Coexist == _TRUE) ? "enable" : "disable");
+	pr_info("BT Coexistance = %s\n",
+		(pbtpriv->BT_Coexist == _TRUE) ? "enable" : "disable");
 	if (pbtpriv->BT_Coexist) {
 		if (pbtpriv->BT_Ant_Num == Ant_x2)
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "Ant_Num = Antx2\n");
+			pr_info("BlueTooth BT_Ant_Num = Antx2\n");
 		else if (pbtpriv->BT_Ant_Num == Ant_x1)
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "Ant_Num = Antx1\n");
+			pr_info("BlueTooth BT_Ant_Num = Antx1\n");
 		switch (pbtpriv->BT_CoexistType) {
 		case BT_2Wire:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_2Wire\n");
+			pr_info("BlueTooth BT_CoexistType = BT_2Wire\n");
 			break;
 		case BT_ISSC_3Wire:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_ISSC_3Wire\n");
+			pr_info("BlueTooth BT_CoexistType = BT_ISSC_3Wire\n");
 			break;
 		case BT_Accel:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_Accel\n");
+			pr_info("BlueTooth BT_CoexistType = BT_Accel\n");
 			break;
 		case BT_CSR_BC4:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_CSR_BC4\n");
+			pr_info("BlueTooth BT_CoexistType = BT_CSR_BC4\n");
 			break;
 		case BT_CSR_BC8:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_CSR_BC8\n");
+			pr_info("BlueTooth BT_CoexistType = BT_CSR_BC8\n");
 			break;
 		case BT_RTL8756:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = BT_RTL8756\n");
+			pr_info("BlueTooth BT_CoexistType = BT_RTL8756\n");
 			break;
 		default:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_"
-			       "CoexistType = Unknown\n");
+			pr_info("BlueTooth BT_CoexistType = Unknown\n");
 			break;
 		}
-		printk(KERN_INFO "rtl8192cu: BlueTooth BT_Ant_isolation = %d\n",
-		       pbtpriv->BT_Ant_isolation);
+		pr_info("BlueTooth BT_Ant_isolation = %d\n",
+			pbtpriv->BT_Ant_isolation);
 		switch (pbtpriv->BT_Service) {
 		case BT_OtherAction:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_Service = "
-			       "BT_OtherAction\n");
+			pr_info("BlueTooth BT_Service = BT_OtherAction\n");
 			break;
 		case BT_SCO:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_Service = "
-			       "BT_SCO\n");
+			pr_info("BlueTooth BT_Service = BT_SCO\n");
 			break;
 		case BT_Busy:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_Service = "
-			       "BT_Busy\n");
+			pr_info("BlueTooth BT_Service = BT_Busy\n");
 			break;
 		case BT_OtherBusy:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_Service = "
-			       "BT_OtherBusy\n");
+			pr_info("BlueTooth BT_Service = BT_OtherBusy\n");
 			break;
 		default:
-			printk(KERN_INFO "rtl8192cu: BlueTooth BT_Service = "
-			       "BT_Idle\n");
+			pr_info("BlueTooth BT_Service = BT_Idle\n");
 			break;
 		}
-		printk(KERN_INFO "rtl8192cu: BT_RadioSharedType = 0x%x\n",
-		       pbtpriv->BT_RadioSharedType);
+		pr_info("BT_RadioSharedType = 0x%x\n",
+			pbtpriv->BT_RadioSharedType);
 	}
 }
 
@@ -526,7 +513,7 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 		usvalue = *(u16 *)&hwinfo[EEPROM_MAC_ADDR + i];
 		*((u16 *) (&rtlefuse->dev_addr[i])) = usvalue;
 	}
-	printk(KERN_INFO "rtl8192cu: MAC address: %pM\n", rtlefuse->dev_addr);
+	pr_info("MAC address: %pM\n", rtlefuse->dev_addr);
 	_rtl92cu_read_txpower_info_from_hwpg(hw,
 					   rtlefuse->autoload_failflag, hwinfo);
 	rtlefuse->eeprom_vid = *(u16 *)&hwinfo[EEPROM_VID];
@@ -665,7 +652,7 @@ static int _rtl92cu_init_power_on(struct ieee80211_hw *hw)
 	rtl_write_word(rtlpriv, REG_APS_FSMCO, value16);
 	do {
 		if (!(rtl_read_word(rtlpriv, REG_APS_FSMCO) & APFM_ONMAC)) {
-			printk(KERN_INFO "rtl8192cu: MAC auto ON okay!\n");
+			pr_info("MAC auto ON okay!\n");
 			break;
 		}
 		if (pollingCount++ > 100) {
@@ -819,7 +806,7 @@ static void _rtl92cu_init_chipN_one_out_ep_priority(struct ieee80211_hw *hw,
 	}
 	_rtl92c_init_chipN_reg_priority(hw, value, value, value, value,
 					value, value);
-	printk(KERN_INFO "rtl8192cu: Tx queue select: 0x%02x\n", queue_sel);
+	pr_info("Tx queue select: 0x%02x\n", queue_sel);
 }
 
 static void _rtl92cu_init_chipN_two_out_ep_priority(struct ieee80211_hw *hw,
@@ -863,7 +850,7 @@ static void _rtl92cu_init_chipN_two_out_ep_priority(struct ieee80211_hw *hw,
 		hiQ = valueHi;
 	}
 	_rtl92c_init_chipN_reg_priority(hw, beQ, bkQ, viQ, voQ, mgtQ, hiQ);
-	printk(KERN_INFO "rtl8192cu: Tx queue select: 0x%02x\n", queue_sel);
+	pr_info("Tx queue select: 0x%02x\n", queue_sel);
 }
 
 static void _rtl92cu_init_chipN_three_out_ep_priority(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index a90c09b..194fc69 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -26,6 +26,9 @@
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
 ****************************************************************************/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 
 #include "../wifi.h"
@@ -213,14 +216,14 @@ bool rtl92c_init_llt_table(struct ieee80211_hw *hw, u32 boundary)
 	for (i = 0; i < (boundary - 1); i++) {
 		rst = rtl92c_llt_write(hw, i , i + 1);
 		if (true != rst) {
-			printk(KERN_ERR "===> %s #1 fail\n", __func__);
+			pr_err("===> %s #1 fail\n", __func__);
 			return rst;
 		}
 	}
 	/* end of list */
 	rst = rtl92c_llt_write(hw, (boundary - 1), 0xFF);
 	if (true != rst) {
-		printk(KERN_ERR "===> %s #2 fail\n", __func__);
+		pr_err("===> %s #2 fail\n", __func__);
 		return rst;
 	}
 	/* Make the other pages as ring buffer
@@ -231,14 +234,14 @@ bool rtl92c_init_llt_table(struct ieee80211_hw *hw, u32 boundary)
 	for (i = boundary; i < LLT_LAST_ENTRY_OF_TX_PKT_BUFFER; i++) {
 		rst = rtl92c_llt_write(hw, i, (i + 1));
 		if (true != rst) {
-			printk(KERN_ERR "===> %s #3 fail\n", __func__);
+			pr_err("===> %s #3 fail\n", __func__);
 			return rst;
 		}
 	}
 	/* Let last entry point to the start entry of ring buffer */
 	rst = rtl92c_llt_write(hw, LLT_LAST_ENTRY_OF_TX_PKT_BUFFER, boundary);
 	if (true != rst) {
-		printk(KERN_ERR "===> %s #4 fail\n", __func__);
+		pr_err("===> %s #4 fail\n", __func__);
 		return rst;
 	}
 	return rst;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index 0883774..351765d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/vmalloc.h>
 
 #include "../wifi.h"
@@ -170,10 +172,8 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	}
 
 	if (!header_print) {
-		printk(KERN_INFO "rtl8192de: Driver for Realtek RTL8192DE"
-		       " WLAN interface");
-		printk(KERN_INFO "rtl8192de: Loading firmware file %s\n",
-		       rtlpriv->cfg->fw_name);
+		pr_info("Driver for Realtek RTL8192DE WLAN interface\n");
+		pr_info("Loading firmware file %s\n", rtlpriv->cfg->fw_name);
 		header_print++;
 	}
 	/* request fw */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index b1d0213..73142a9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "../wifi.h"
 #include "../efuse.h"
 #include "../base.h"
@@ -465,8 +467,7 @@ static u8 _rtl92ce_halset_sysclk(struct ieee80211_hw *hw, u8 data)
 			if ((tmpvalue & BIT(6)))
 				break;
 
-			printk(KERN_ERR "wait for BIT(6) return value %x\n",
-			       tmpvalue);
+			pr_err("wait for BIT(6) return value %x\n", tmpvalue);
 			if (waitcount == 0)
 				break;
 
@@ -1255,8 +1256,7 @@ static u8 _rtl92s_set_sysclk(struct ieee80211_hw *hw, u8 data)
 			if ((tmp & BIT(6)))
 				break;
 
-			printk(KERN_ERR "wait for BIT(6) return value %x\n",
-			       tmp);
+			pr_err("wait for BIT(6) return value %x\n", tmp);
 
 			if (waitcnt == 0)
 				break;
@@ -1315,7 +1315,7 @@ static void _rtl92s_phy_set_rfhalt(struct ieee80211_hw *hw)
 	if (u1btmp & BIT(7)) {
 		u1btmp &= ~(BIT(6) | BIT(7));
 		if (!_rtl92s_set_sysclk(hw, u1btmp)) {
-			printk(KERN_ERR "Switch ctrl path fail\n");
+			pr_err("Switch ctrl path fail\n");
 			return;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 81a5aa4..f27171a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "../wifi.h"
 #include "../pci.h"
 #include "../ps.h"
@@ -1016,8 +1018,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 	rtstatus = _rtl92s_phy_config_bb(hw, BASEBAND_CONFIG_AGC_TAB);
 
 	if (rtstatus != true) {
-		printk(KERN_ERR  "_rtl92s_phy_bb_config_parafile(): "
-		       "AGC Table Fail\n");
+		pr_err("%s(): AGC Table Fail\n", __func__);
 		goto phy_BB8190_Config_ParaFile_Fail;
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
index c6e3a4c..0ad50fe 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "../wifi.h"
 #include "reg.h"
 #include "def.h"
@@ -507,7 +509,7 @@ bool rtl92s_phy_rf6052_config(struct ieee80211_hw *hw)
 		}
 
 		if (rtstatus != true) {
-			printk(KERN_ERR "Radio[%d] Fail!!", rfpath);
+			pr_err("Radio[%d] Fail!!\n", rfpath);
 			goto fail;
 		}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 1c6cb1d..3876078 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/vmalloc.h>
 
 #include "../wifi.h"
@@ -183,8 +185,8 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 		return 1;
 	}
 
-	printk(KERN_INFO "rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE\n"
-	       "           Loading firmware %s\n", rtlpriv->cfg->fw_name);
+	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
+		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
 	/* request fw */
 	err = request_firmware(&firmware, rtlpriv->cfg->fw_name,
 			rtlpriv->io.dev);
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index a9367eb..8b1cef0 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -24,6 +24,9 @@
  * Hsinchu 300, Taiwan.
  *
  *****************************************************************************/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/usb.h>
 #include "core.h"
 #include "wifi.h"
@@ -104,9 +107,8 @@ static int _usbctrl_vendorreq_sync_read(struct usb_device *udev, u8 request,
 				 pdata, len, 0); /* max. timeout */
 
 	if (status < 0)
-		printk(KERN_ERR "reg 0x%x, usbctrl_vendorreq TimeOut! "
-		       "status:0x%x value=0x%x\n", value, status,
-		       *(u32 *)pdata);
+		pr_err("reg 0x%x, usbctrl_vendorreq TimeOut! status:0x%x value=0x%x\n",
+		       value, status, *(u32 *)pdata);
 	return status;
 }
 
@@ -316,7 +318,7 @@ static int _rtl_usb_init_rx(struct ieee80211_hw *hw)
 	rtlusb->usb_rx_segregate_hdl =
 		rtlpriv->cfg->usb_interface_cfg->usb_rx_segregate_hdl;
 
-	printk(KERN_INFO "rtl8192cu: rx_max_size %d, rx_urb_num %d, in_ep %d\n",
+	pr_info("rx_max_size %d, rx_urb_num %d, in_ep %d\n",
 		rtlusb->rx_max_size, rtlusb->rx_urb_num, rtlusb->in_ep);
 	init_usb_anchor(&rtlusb->rx_submitted);
 	return 0;
@@ -580,7 +582,7 @@ static void _rtl_rx_completed(struct urb *_urb)
 		} else{
 			/* TO DO */
 			_rtl_rx_pre_process(hw, skb);
-			printk(KERN_ERR "rtlwifi: rx agg not supported\n");
+			pr_err("rx agg not supported\n");
 		}
 		goto resubmit;
 	}
-- 
1.7.6.131.g99019
