From: Joe Perches <joe@perches.com>
Subject: [PATCH] realtek: Add switch variable to 'switch case not processed' messages
Date: Fri, 23 Sep 2016 11:27:19 -0700
Message-ID: <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
References: <1474654333.1849.5.camel@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474654333.1849.5.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Help along debugging by showing what switch/case variable is not
being processed in these messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/core.c          |  3 ++-
 drivers/net/wireless/realtek/rtlwifi/pci.c           |  3 ++-
 drivers/net/wireless/realtek/rtlwifi/ps.c            |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c | 10 ++++++----
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.c    |  4 ++--
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c   |  8 +++++---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c  |  7 ++++---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/phy.c |  7 ++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/phy.c |  7 ++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c | 15 +++++++--------
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c | 10 ++++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/phy.c |  5 +++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c | 10 ++++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c  | 10 +++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c | 12 +++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c  |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c  |  9 +++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/led.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c | 20 ++++++--------------
 38 files changed, 128 insertions(+), 123 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 7aee5ebb1..f95760c 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -765,7 +765,8 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 					mac->bw_40 = false;
 					mac->bw_80 = false;
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 "switch case not processed\n");
+						 "switch case %#x not processed\n",
+						 channel_type);
 					break;
 			}
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index d12586d..0dfa9ea 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -179,7 +179,8 @@ static void _rtl_pci_update_default_setting(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n",
+			 rtlpci->const_support_pciaspm);
 		break;
 	}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index 9a64f9b..18d979a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -151,7 +151,7 @@ static bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", state_toset);
 		break;
 	}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/fw.c
index 6291256..5360d53 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/fw.c
@@ -334,7 +334,7 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 		isfw_read = _rtl88e_check_fw_read_last_h2c(hw, boxnum);
@@ -405,7 +405,7 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
index 4ab6201..3285117 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
@@ -357,7 +357,7 @@ void rtl88ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -571,7 +571,8 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					 "switch case not process\n");
+					 "switch case %#x not processed\n",
+					 e_aci);
 				break;
 			}
 		}
@@ -735,7 +736,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -2352,7 +2353,7 @@ void rtl88ee_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/led.c
index b504bd0..f05c2c6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/led.c
@@ -62,7 +62,7 @@ void rtl88ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -100,7 +100,7 @@ void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
index 7498a12..fffaa92 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
@@ -1346,7 +1346,8 @@ static bool _rtl88e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -2128,7 +2129,7 @@ bool rtl88e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -2166,7 +2167,8 @@ static void rtl88e_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -2319,7 +2321,7 @@ static bool _rtl88ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
index 43fcb25..7d15246 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
@@ -352,7 +352,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 
@@ -456,7 +456,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
index 60ab2ec..27e3d5f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
@@ -910,7 +910,8 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -1567,7 +1568,7 @@ bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -1605,7 +1606,8 @@ void rtl92c_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
index 2446079..6d308f9 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
@@ -143,7 +143,7 @@ void rtl92ce_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -367,7 +367,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 "switch case not processed\n");
+						 "switch case %#x not processed\n",
+						 e_aci);
 					break;
 				}
 			}
@@ -2154,7 +2155,7 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/led.c
index 8283e9b..24e483b 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/led.c
@@ -62,7 +62,7 @@ void rtl92ce_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -97,7 +97,7 @@ void rtl92ce_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/phy.c
index 1ee5a6a..46d0d94 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/phy.c
@@ -300,12 +300,9 @@ bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		}
 		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
-		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	default:
 		break;
@@ -554,7 +551,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
index 8789752..ae8f055 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
@@ -1560,7 +1560,7 @@ void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -1931,7 +1931,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/led.c
index 75a2deb..8514ab65 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/led.c
@@ -62,7 +62,7 @@ void rtl92cu_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -95,7 +95,7 @@ void rtl92cu_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/phy.c
index c972fa5..4b29764 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/phy.c
@@ -277,12 +277,9 @@ bool rtl92cu_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		}
 		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
-		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	default:
 		break;
@@ -517,7 +514,7 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
index 62ef820..8de29cc 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
@@ -435,7 +435,7 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 		isfw_read = _rtl92d_check_fw_read_last_h2c(hw, boxnum);
@@ -512,7 +512,7 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 		bwrite_success = true;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
index 5720551..5369011 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
@@ -166,7 +166,7 @@ void rtl92de_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -361,7 +361,8 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					 "switch case not processed\n");
+					 "switch case %#x not processed\n",
+					 e_aci);
 				break;
 			}
 		}
@@ -502,7 +503,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -2171,7 +2172,7 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/led.c
index 76a57ae..811ba57 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/led.c
@@ -71,7 +71,7 @@ void rtl92de_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -106,7 +106,7 @@ void rtl92de_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
index 2a4810d..2a1edfd 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
@@ -836,12 +836,9 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		}
 		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
-		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	}
 	return true;
@@ -2850,7 +2847,8 @@ static bool _rtl92d_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 		break;
@@ -2963,7 +2961,8 @@ static void rtl92d_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -2994,7 +2993,7 @@ bool rtl92d_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -3182,7 +3181,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
index 0708eed..b3f6a9e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
@@ -344,7 +344,7 @@ static void _rtl92ee_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 
@@ -433,7 +433,7 @@ static void _rtl92ee_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
index b07af8d..47bb6d8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
@@ -340,7 +340,7 @@ void rtl92ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -566,7 +566,8 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
-					 "switch case not process\n");
+					 "switch case %#x not processed\n",
+					 e_aci);
 				break;
 			}
 		}
@@ -685,7 +686,7 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -2463,7 +2464,7 @@ void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/led.c
index 8388e37..47da05d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/led.c
@@ -61,7 +61,7 @@ void rtl92ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -91,7 +91,7 @@ void rtl92ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
index beafc9a..5ad7e75 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
@@ -1927,7 +1927,8 @@ static bool _rtl92ee_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -3001,7 +3002,7 @@ bool rtl92ee_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -3041,7 +3042,8 @@ static void rtl92ee_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -3187,7 +3189,7 @@ static bool _rtl92ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
index ddfa0ae..5bad9c9 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
@@ -79,7 +79,7 @@ void rtl92se_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default: {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 			break;
 		}
 	}
@@ -297,7 +297,8 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 "switch case not processed\n");
+						 "switch case %#x not processed\n",
+						 e_aci);
 					break;
 				}
 			}
@@ -433,7 +434,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 
@@ -2465,7 +2466,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/led.c
index 44949b5..9849cb9 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/led.c
@@ -68,7 +68,7 @@ void rtl92se_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -104,7 +104,7 @@ void rtl92se_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/phy.c
index 881821f..4bb7558 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/phy.c
@@ -442,7 +442,8 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -648,7 +649,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
index b7c0d38..1186755 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
@@ -124,7 +124,7 @@ static void _rtl8723e_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 
@@ -230,7 +230,7 @@ static void _rtl8723e_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index ba30efc..2bf603b 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -143,7 +143,7 @@ void rtl8723e_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -366,7 +366,8 @@ void rtl8723e_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-						 "switch case not process\n");
+						 "switch case %#x not processed\n",
+						 e_aci);
 					break;
 				}
 			}
@@ -546,7 +547,7 @@ void rtl8723e_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -2225,7 +2226,7 @@ void rtl8723e_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/led.c
index 1317335..c7be934 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/led.c
@@ -63,7 +63,7 @@ void rtl8723e_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -105,7 +105,7 @@ void rtl8723e_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
index 601b78e..17b58cb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
@@ -1023,7 +1023,8 @@ static bool _rtl8723e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -1499,7 +1500,7 @@ bool rtl8723e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -1536,7 +1537,8 @@ static void rtl8723e_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -1682,7 +1684,7 @@ static bool _rtl8723e_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
index d5da0f3..8c5c27c 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
@@ -122,7 +122,7 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 
@@ -195,7 +195,7 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 82e4476..999c1ac 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -350,7 +350,7 @@ void rtl8723be_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -607,7 +607,8 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-					 "switch case not process\n");
+					 "switch case %#x not processed\n",
+					 e_aci);
 				break;
 			}
 		}
@@ -723,8 +724,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process %x\n",
-			 variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -2565,7 +2565,7 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/led.c
index 4196efb..497913e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/led.c
@@ -58,7 +58,7 @@ void rtl8723be_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -100,7 +100,7 @@ void rtl8723be_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
index 285818d..3cc2232 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
@@ -837,7 +837,7 @@ bool rtl8723be_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	}
 	return true;
@@ -1507,7 +1507,8 @@ static bool _rtl8723be_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n",
+				 currentcmd->cmdid);
 			break;
 		}
 
@@ -2515,7 +2516,7 @@ bool rtl8723be_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -2553,7 +2554,8 @@ static void rtl8723be_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -2705,7 +2707,7 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
index a4fc70e..b665446 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
@@ -392,7 +392,7 @@ static void _rtl8821ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", boxnum);
 			break;
 		}
 
@@ -481,7 +481,7 @@ static void _rtl8821ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", cmd_len);
 			break;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 0cddf1a..1281ebe 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -480,7 +480,7 @@ void rtl8821ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -671,7 +671,8 @@ void rtl8821ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-					 "switch case not process\n");
+					 "switch case %#x not processed\n",
+					 e_aci);
 				break;
 			}
 		}
@@ -800,7 +801,7 @@ void rtl8821ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process %x\n", variable);
+			 "switch case %#x not processed\n", variable);
 		break;
 	}
 }
@@ -3934,7 +3935,7 @@ void rtl8821ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", enc_algo);
 			enc_algo = CAM_TKIP;
 			break;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/led.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/led.c
index ba1946a..fcb3b28 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/led.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/led.c
@@ -60,7 +60,7 @@ void rtl8821ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = true;
@@ -133,7 +133,7 @@ void rtl8821ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", pled->ledpin);
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
index a71bfe3..5dad402 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
@@ -2063,12 +2063,9 @@ bool rtl8812ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		}
 		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	}
 	return true;
@@ -2133,16 +2130,10 @@ bool rtl8821ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		break;
 
 	case RF90_PATH_B:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpath);
 		break;
 	}
 	return true;
@@ -4670,7 +4661,7 @@ bool rtl8821ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not process\n");
+				 "switch case %#x not processed\n", iotype);
 			break;
 		}
 	} while (false);
@@ -4714,7 +4705,8 @@ static void rtl8821ae_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n",
+			 rtlphy->current_io_type);
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
@@ -4820,7 +4812,7 @@ static bool _rtl8821ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
+			 "switch case %#x not processed\n", rfpwr_state);
 		bresult = false;
 		break;
 	}
-- 
2.10.0.rc2.1.g053435c
