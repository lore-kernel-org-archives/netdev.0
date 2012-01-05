From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/7] rtlwifi: Convert RT_ASSERT macro to use ##__VA_ARGS__
Date: Wed,  4 Jan 2012 19:40:43 -0800
Message-ID: <7b075dbb83c4f28138147d736d77690bff33c67f.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32822 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757803Ab2AEDmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 22:42:44 -0500
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate printks to avoid possible message interleaving
and reduce the object size.

Remove unnecessary RT_ASSERT parentheses.
Align arguments.
Coalesce formats.
Remove unnecessary __func__ use as the macro uses it.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 588901	  55333	 127216	 771450	  bc57a	drivers/net/wireless/rtlwifi/built-in.o.new
 590002	  55333	 127560	 772895	  bcb1f	drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/core.c                |    4 ++--
 drivers/net/wireless/rtlwifi/debug.h               |    7 +++----
 drivers/net/wireless/rtlwifi/pci.c                 |   15 +++++++--------
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   10 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   16 ++++++++--------
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    5 +++--
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   13 ++++++-------
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   16 ++++++++--------
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   16 ++++++++--------
 drivers/net/wireless/rtlwifi/usb.c                 |    2 +-
 21 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 186c944..ab6a406 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1026,8 +1026,8 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "set pairwise key\n");
 			if (!sta) {
-				RT_ASSERT(false, ("pairwise key withnot"
-						  "mac_addr\n"));
+				RT_ASSERT(false,
+					  "pairwise key without mac_addr\n");
 
 				err = -EOPNOTSUPP;
 				goto out_unlock;
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 8b51a82..74b6780 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -156,12 +156,11 @@ enum dbgp_flag_e {
 	DBGP_TYPE_MAX
 };
 
-#define RT_ASSERT(_exp, fmt)						\
+#define RT_ASSERT(_exp, fmt, ...)					\
 do {									\
 	if (!(_exp)) {							\
-		printk(KERN_DEBUG "%s:%s(): ",				\
-		       KBUILD_MODNAME, __func__);			\
-		printk fmt;						\
+		printk(KERN_DEBUG KBUILD_MODNAME ":%s(): " fmt,		\
+		       __func__, ##__VA_ARGS__);			\
 	}								\
 } while (0)
 
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index b52fef2..3c4ae5d 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1746,16 +1746,15 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		RT_ASSERT(false,
-			  ("%s : Cannot enable new PCI device\n",
-			   pci_name(pdev)));
+		RT_ASSERT(false, "%s : Cannot enable new PCI device\n",
+			  pci_name(pdev));
 		return err;
 	}
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
-			RT_ASSERT(false, ("Unable to obtain 32bit DMA "
-					  "for consistent allocations\n"));
+			RT_ASSERT(false,
+				  "Unable to obtain 32bit DMA for consistent allocations\n");
 			pci_disable_device(pdev);
 			return -ENOMEM;
 		}
@@ -1767,7 +1766,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 				sizeof(struct rtl_priv), &rtl_ops);
 	if (!hw) {
 		RT_ASSERT(false,
-			  ("%s : ieee80211 alloc failed\n", pci_name(pdev)));
+			  "%s : ieee80211 alloc failed\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto fail1;
 	}
@@ -1797,7 +1796,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	/* MEM map */
 	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if (err) {
-		RT_ASSERT(false, ("Can't obtain PCI resources\n"));
+		RT_ASSERT(false, "Can't obtain PCI resources\n");
 		return err;
 	}
 
@@ -1810,7 +1809,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 			(unsigned long)pci_iomap(pdev,
 			rtlpriv->cfg->bar_id, pmem_len);
 	if (rtlpriv->io.pci_mem_start == 0) {
-		RT_ASSERT(false, ("Can't map PCI mem\n"));
+		RT_ASSERT(false, "Can't map PCI mem\n");
 		goto fail2;
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 12c025b..1eae3ba 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -519,8 +519,8 @@ void rtl92c_fill_h2c_cmd(struct ieee80211_hw *hw,
 	u32 tmp_cmdbuf[2];
 
 	if (rtlhal->fw_ready == false) {
-		RT_ASSERT(false, ("return H2C cmd because of Fw "
-				  "download fail!!!\n"));
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
 		return;
 	}
 
@@ -544,7 +544,7 @@ void rtl92c_firmware_selfreset(struct ieee80211_hw *hw)
 	while (u1b_tmp & BIT(2)) {
 		delay--;
 		if (delay == 0) {
-			RT_ASSERT(false, ("8051 reset fail.\n"));
+			RT_ASSERT(false, "8051 reset fail\n");
 			break;
 		}
 		udelay(50);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 8ab93a6..25bde96 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -85,7 +85,7 @@ EXPORT_SYMBOL(rtl92c_phy_set_bb_reg);
 u32 _rtl92c_phy_fw_rf_serial_read(struct ieee80211_hw *hw,
 				  enum radio_path rfpath, u32 offset)
 {
-	RT_ASSERT(false, ("deprecated!\n"));
+	RT_ASSERT(false, "deprecated!\n");
 	return 0;
 
 }
@@ -95,7 +95,7 @@ void _rtl92c_phy_fw_rf_serial_write(struct ieee80211_hw *hw,
 				    enum radio_path rfpath, u32 offset,
 				    u32 data)
 {
-	RT_ASSERT(false, ("deprecated!\n"));
+	RT_ASSERT(false, "deprecated!\n");
 }
 EXPORT_SYMBOL(_rtl92c_phy_fw_rf_serial_write);
 
@@ -776,7 +776,7 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (rtlphy->set_bwmode_inprogress)
 		return 0;
 	RT_ASSERT((rtlphy->current_channel <= 14),
-		  ("WIRELESS_MODE_G but channel>14"));
+		  "WIRELESS_MODE_G but channel>14\n");
 	rtlphy->sw_chnl_inprogress = true;
 	rtlphy->sw_chnl_stage = 0;
 	rtlphy->sw_chnl_step = 0;
@@ -802,7 +802,7 @@ static bool _rtl92c_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
 	struct swchnlcmd *pcmd;
 
 	if (cmdtable == NULL) {
-		RT_ASSERT(false, ("cmdtable cannot be NULL.\n"));
+		RT_ASSERT(false, "cmdtable cannot be NULL\n");
 		return false;
 	}
 
@@ -848,7 +848,7 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 	rfdependcmdcnt = 0;
 
 	RT_ASSERT((channel >= 1 && channel <= 14),
-		  ("illegal channel for Zebra: %d\n", channel));
+		  "invalid channel for Zebra: %d\n", channel);
 
 	_rtl92c_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
 					 MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 2d01673..18f615c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1166,7 +1166,7 @@ void rtl92ce_set_qos(struct ieee80211_hw *hw, int aci)
 		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, 0x2f3222);
 		break;
 	default:
-		RT_ASSERT(false, ("invalid aci: %d !\n", aci));
+		RT_ASSERT(false, "invalid aci: %d !\n", aci);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index cab1c1f..8a7351a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -405,7 +405,7 @@ static int __init rtl92ce_module_init(void)
 
 	ret = pci_register_driver(&rtl92ce_driver);
 	if (ret)
-		RT_ASSERT(false, (": No device found\n"));
+		RT_ASSERT(false, "No device found\n");
 
 	return ret;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 9f6fac4..46892cc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -836,8 +836,8 @@ void rtl92ce_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *) val);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d"
-					  " not process\n", desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -856,8 +856,8 @@ void rtl92ce_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_RX_DESC_EOR(pdesc, 1);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
@@ -876,8 +876,8 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(p_desc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -890,8 +890,8 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index de1542f..ae38bc5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1984,8 +1984,9 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						u4b_ac_param);
 				break;
 			default:
-				RT_ASSERT(false, ("SetHwReg8185(): invalid"
-					  " aci: %d !\n", e_aci));
+				RT_ASSERT(false,
+					  "SetHwReg8185(): invalid aci: %d !\n",
+					  e_aci);
 				break;
 			}
 			if (rtlusb->acm_method != eAcmWay2_SW)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 9f09844..943f3d4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -428,7 +428,7 @@ void rtl92c_set_qos(struct ieee80211_hw *hw, int aci)
 		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, u4b_ac_param);
 		break;
 	default:
-		RT_ASSERT(false, ("invalid aci: %d !\n", aci));
+		RT_ASSERT(false, "invalid aci: %d !\n", aci);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index b875af7..aca0fd5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -244,8 +244,8 @@ u16 rtl8192cu_mq_to_hwq(__le16 fc, u16 mac80211_queue_index)
 		break;
 	default:
 		hw_queue_index = RTL_TXQ_BE;
-		RT_ASSERT(false, ("QSLT_BE queue, skb_queue:%d\n",
-			  mac80211_queue_index));
+		RT_ASSERT(false, "QSLT_BE queue, skb_queue:%d\n",
+			  mac80211_queue_index);
 		break;
 	}
 out:
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index b84f10d..94f5b7d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -186,7 +186,7 @@ void rtl92d_firmware_selfreset(struct ieee80211_hw *hw)
 		udelay(50);
 		u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
 	}
-	RT_ASSERT((delay > 0), ("8051 reset failed!\n"));
+	RT_ASSERT((delay > 0), "8051 reset failed!\n");
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 		 "=====> 8051 reset success (%d)\n", delay);
 }
@@ -536,8 +536,8 @@ void rtl92d_fill_h2c_cmd(struct ieee80211_hw *hw,
 	u32 tmp_cmdbuf[2];
 
 	if (rtlhal->fw_ready == false) {
-		RT_ASSERT(false, ("return H2C cmd because of Fw "
-				  "download fail!!!\n"));
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
 		return;
 	}
 	memset(tmp_cmdbuf, 0, 8);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 5eecf40..d94ce37 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1213,7 +1213,7 @@ void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
 		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, 0x2f3222);
 		break;
 	default:
-		RT_ASSERT(false, ("invalid aci: %d !\n", aci));
+		RT_ASSERT(false, "invalid aci: %d !\n", aci);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index c736b93..f27acc7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -2928,7 +2928,7 @@ static bool _rtl92d_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
 	struct swchnlcmd *pcmd;
 
 	if (cmdtable == NULL) {
-		RT_ASSERT(false, ("cmdtable cannot be NULL.\n"));
+		RT_ASSERT(false, "cmdtable cannot be NULL\n");
 		return false;
 	}
 	if (cmdtableidx >= cmdtablesz)
@@ -3120,19 +3120,18 @@ u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw)
 		 * 5G and 2.4G band. */
 		if (channel <= 14)
 			return 0;
-		RT_ASSERT((channel > 14), ("5G but channel<=14"));
+		RT_ASSERT((channel > 14), "5G but channel<=14\n");
 		break;
 	case BAND_ON_2_4G:
 		/* Get first channel error when change between
 		 * 5G and 2.4G band. */
 		if (channel > 14)
 			return 0;
-		RT_ASSERT((channel <= 14), ("2G but channel>14"));
+		RT_ASSERT((channel <= 14), "2G but channel>14\n");
 		break;
 	default:
-		RT_ASSERT(false,
-			  ("Invalid WirelessMode(%#x)!!\n",
-			   rtlpriv->mac80211.mode));
+		RT_ASSERT(false, "Invalid WirelessMode(%#x)!!\n",
+			  rtlpriv->mac80211.mode);
 		break;
 	}
 	rtlphy->sw_chnl_inprogress = true;
@@ -3563,7 +3562,7 @@ void rtl92d_phy_set_poweron(struct ieee80211_hw *hw)
 			}
 		}
 		if (i == 200)
-			RT_ASSERT(false, ("Another mac power off over time\n"));
+			RT_ASSERT(false, "Another mac power off over time\n");
 	}
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index db75796..022f065 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -424,7 +424,7 @@ static int __init rtl92de_module_init(void)
 
 	ret = pci_register_driver(&rtl92de_driver);
 	if (ret)
-		RT_ASSERT(false, (": No device found\n"));
+		RT_ASSERT(false, "No device found\n");
 	return ret;
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index f6ec0a1..e7c985b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -793,8 +793,8 @@ void rtl92de_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *) val);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d"
-					  " not process\n", desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -813,8 +813,8 @@ void rtl92de_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_RX_DESC_EOR(pdesc, 1);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
@@ -833,8 +833,8 @@ u32 rtl92de_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(p_desc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -847,8 +847,8 @@ u32 rtl92de_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d "
-					  "not process\n", desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index acab878..b03001b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1200,7 +1200,7 @@ void rtl92se_set_qos(struct ieee80211_hw *hw, int aci)
 		rtl_write_dword(rtlpriv, EDCAPARA_VO, 0x2f3222);
 		break;
 	default:
-		RT_ASSERT(false, ("invalid aci: %d !\n", aci));
+		RT_ASSERT(false, "invalid aci: %d !\n", aci);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index ec5520e..e24dbb3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -335,7 +335,7 @@ static bool _rtl92s_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
 	struct swchnlcmd *pcmd;
 
 	if (cmdtable == NULL) {
-		RT_ASSERT(false, ("cmdtable cannot be NULL.\n"));
+		RT_ASSERT(false, "cmdtable cannot be NULL\n");
 		return false;
 	}
 
@@ -380,7 +380,7 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 	rfdependcmdcnt = 0;
 
 	RT_ASSERT((channel >= 1 && channel <= 14),
-		  ("illegal channel for Zebra: %d\n", channel));
+		  "invalid channel for Zebra: %d\n", channel);
 
 	_rtl92s_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
 					 MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index bc4b6fa..a933aef 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -426,7 +426,7 @@ static int __init rtl92se_module_init(void)
 
 	ret = pci_register_driver(&rtl92se_driver);
 	if (ret)
-		RT_ASSERT(false, (": No device found\n"));
+		RT_ASSERT(false, "No device found\n");
 
 	return ret;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 1f266d1d..216a3e1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -823,8 +823,8 @@ void rtl92se_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *) val);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d not process\n",
-				  desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -843,8 +843,8 @@ void rtl92se_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
 			SET_RX_STATUS_DESC_EOR(pdesc, 1);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d not process\n",
-				  desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
@@ -863,8 +863,8 @@ u32 rtl92se_get_desc(u8 *desc, bool istx, u8 desc_name)
 			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(desc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR txdesc :%d not process\n",
-				  desc_name));
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	} else {
@@ -876,8 +876,8 @@ u32 rtl92se_get_desc(u8 *desc, bool istx, u8 desc_name)
 			ret = GET_RX_STATUS_DESC_PKT_LEN(desc);
 			break;
 		default:
-			RT_ASSERT(false, ("ERR rxdesc :%d not process\n",
-				  desc_name));
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
 			break;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index d670e68..6ae1b21 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -946,7 +946,7 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 	hw = ieee80211_alloc_hw(sizeof(struct rtl_priv) +
 				sizeof(struct rtl_usb_priv), &rtl_ops);
 	if (!hw) {
-		RT_ASSERT(false, ("%s : ieee80211 alloc failed\n", __func__));
+		RT_ASSERT(false, "ieee80211 alloc failed\n");
 		return -ENOMEM;
 	}
 	rtlpriv = hw->priv;
-- 
1.7.8.111.gad25c.dirty
