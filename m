From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg
Date: Thu, 17 Mar 2016 21:54:17 -0500
Message-ID: <56EB6DD9.3000300@lwfinger.net>
References: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35759 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbcCRCyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 22:54:23 -0400
In-Reply-To: <4672f9efb37df545ae504d51ca626bf34237fa63.1458258337.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2016 07:00 PM, Joe Perches wrote:
> Use a more common logging style.
>
> Miscellanea:
>
> o Add specific logging macros for ALGORITHM and INTERFACE types
> o Output the messages at KERN_DEBUG
> o Coalesce formats
> o Align arguments
> o Whitespace style adjustments for only these changes
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>
> Not sure these btcoexist files are going to be used, but perhaps
> these files should be a bit more kernel style consistent.
>
>   .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    | 847 ++++++++++----------
>   .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    | 611 ++++++++-------
>   .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    | 854 +++++++++------------
>   .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    | 652 ++++++++--------
>   .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 851 ++++++++++----------
>   .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |   4 +-
>   .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |  17 +-
>   7 files changed, 1851 insertions(+), 1985 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
> index 4514568..a30af6c 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
> @@ -70,83 +70,83 @@ static u8 halbtc8192e2ant_btrssi_state(u8 level_num, u8 rssi_thresh,
>   	if (level_num == 2) {
>   		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
>   		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "BT Rssi pre state = LOW\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "BT Rssi pre state = LOW\n");
>   			if (btrssi >= (rssi_thresh +
>   				       BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				btrssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to High\n");
>   			} else {
>   				btrssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state stay at Low\n");
>   			}
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "BT Rssi pre state = HIGH\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "BT Rssi pre state = HIGH\n");
>   			if (btrssi < rssi_thresh) {
>   				btrssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to Low\n");
>   			} else {
>   				btrssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "BT Rssi thresh error!!\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "BT Rssi thresh error!!\n");
>   			return coex_sta->pre_bt_rssi_state;
>   		}
>
>   		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
>   		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "BT Rssi pre state = LOW\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "BT Rssi pre state = LOW\n");
>   			if (btrssi >= (rssi_thresh +
>   				      BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				btrssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to Medium\n");
>   			} else {
>   				btrssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_bt_rssi_state ==
>   			    BTC_RSSI_STATE_MEDIUM) ||
>   			   (coex_sta->pre_bt_rssi_state ==
>   			    BTC_RSSI_STATE_STAY_MEDIUM)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "[BTCoex], BT Rssi pre state = MEDIUM\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "[BTCoex], BT Rssi pre state = MEDIUM\n");
>   			if (btrssi >= (rssi_thresh1 +
>   				       BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				btrssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to High\n");
>   			} else if (btrssi < rssi_thresh) {
>   				btrssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to Low\n");
>   			} else {
>   				btrssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state stay at Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state stay at Medium\n");
>   			}
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "BT Rssi pre state = HIGH\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "BT Rssi pre state = HIGH\n");
>   			if (btrssi < rssi_thresh1) {
>   				btrssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state switch to Medium\n");
>   			} else {
>   				btrssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "BT Rssi state stay at High\n");
>   			}
>   		}
>   	}
> @@ -173,32 +173,28 @@ static u8 halbtc8192e2ant_wifirssi_state(struct btc_coexist *btcoexist,
>   			if (wifirssi >= (rssi_thresh +
>   					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				wifirssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to High\n");
>   			} else {
>   				wifirssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state stay at Low\n");
>   			}
>   		} else {
>   			if (wifirssi < rssi_thresh) {
>   				wifirssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to Low\n");
>   			} else {
>   				wifirssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
> -				  "wifi RSSI thresh error!!\n");
> +			btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +				    "wifi RSSI thresh error!!\n");
>   			return coex_sta->pre_wifi_rssi_state[index];
>   		}
>
> @@ -209,14 +205,12 @@ static u8 halbtc8192e2ant_wifirssi_state(struct btc_coexist *btcoexist,
>   			if (wifirssi >= (rssi_thresh +
>   					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				wifirssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifirssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
>   			    BTC_RSSI_STATE_MEDIUM) ||
> @@ -225,31 +219,26 @@ static u8 halbtc8192e2ant_wifirssi_state(struct btc_coexist *btcoexist,
>   			if (wifirssi >= (rssi_thresh1 +
>   					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
>   				wifirssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to High\n");
>   			} else if (wifirssi < rssi_thresh) {
>   				wifirssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to Low\n");
>   			} else {
>   				wifirssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state stay at Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state stay at Medium\n");
>   			}
>   		} else {
>   			if (wifirssi < rssi_thresh1) {
>   				wifirssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifirssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "wifi RSSI state stay at High\n");
>   			}
>   		}
>   	}
> @@ -284,26 +273,26 @@ static void btc8192e2ant_monitor_bt_enable_dis(struct btc_coexist *btcoexist)
>   		bt_disabled = false;
>   		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   				   &bt_disabled);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is enabled !!\n");
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is enabled !!\n");
>   	} else {
>   		bt_disable_cnt++;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], bt all counters = 0, %d times!!\n",
> -			  bt_disable_cnt);
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], bt all counters = 0, %d times!!\n",
> +			    bt_disable_cnt);
>   		if (bt_disable_cnt >= 2) {
>   			bt_disabled = true;
>   			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   					   &bt_disabled);
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -				  "[BTCoex], BT is disabled !!\n");
> +			btc_alg_dbg(ALGO_BT_MONITOR,
> +				    "[BTCoex], BT is disabled !!\n");
>   		}
>   	}
>   	if (pre_bt_disabled != bt_disabled) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is from %s to %s!!\n",
> -			  (pre_bt_disabled ? "disabled" : "enabled"),
> -			  (bt_disabled ? "disabled" : "enabled"));
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is from %s to %s!!\n",
> +			    (pre_bt_disabled ? "disabled" : "enabled"),
> +			    (bt_disabled ? "disabled" : "enabled"));
>   		pre_bt_disabled = bt_disabled;
>   	}
>   }
> @@ -499,12 +488,12 @@ static void halbtc8192e2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
>   	coex_sta->low_priority_tx = reg_lp_tx;
>   	coex_sta->low_priority_rx = reg_lp_rx;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex] High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> -		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex] Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> -		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex] High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> +		    reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex] Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> +		    reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
>
>   	/* reset counter */
>   	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
> @@ -518,9 +507,9 @@ static void halbtc8192e2ant_querybt_info(struct btc_coexist *btcoexist)
>
>   	h2c_parameter[0] |= BIT0;	/* trigger */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
>   }
> @@ -592,8 +581,8 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
>
>   	if (!bt_link_info->bt_link_exist) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "No BT link exists!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "No BT link exists!!!\n");
>   		return algorithm;
>   	}
>
> @@ -608,27 +597,27 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>
>   	if (numdiffprofile == 1) {
>   		if (bt_link_info->sco_exist) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "SCO only\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "SCO only\n");
>   			algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
>   		} else {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "HID only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "HID only\n");
>   				algorithm = BT_8192E_2ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "A2DP only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "A2DP only\n");
>   				algorithm = BT_8192E_2ANT_COEX_ALGO_A2DP;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "PAN(HS) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "PAN(HS) only\n");
>   					algorithm =
>   						BT_8192E_2ANT_COEX_ALGO_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "PAN(EDR) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "PAN(EDR) only\n");
>   					algorithm =
>   						BT_8192E_2ANT_COEX_ALGO_PANEDR;
>   				}
> @@ -637,21 +626,21 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   	} else if (numdiffprofile == 2) {
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "SCO + HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "SCO + HID\n");
>   				algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "SCO + A2DP ==> SCO\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "SCO + A2DP ==> SCO\n");
>   				algorithm = BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + PAN(HS)\n");
>   					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + PAN(EDR)\n");
>   					algorithm =
>   						BT_8192E_2ANT_COEX_ALGO_SCO_PAN;
>   				}
> @@ -660,38 +649,38 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (stack_info->num_of_hid >= 2) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID*2 + A2DP\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID*2 + A2DP\n");
>   					algorithm =
>   					BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID + A2DP\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID + A2DP\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_HID_A2DP;
>   				}
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID + PAN(HS)\n");
>   					algorithm = BT_8192E_2ANT_COEX_ALGO_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_A2DP_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "A2DP + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_PANEDR_A2DP;
>   				}
> @@ -701,30 +690,30 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "SCO + HID + A2DP ==> HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "SCO + HID + A2DP ==> HID\n");
>   				algorithm = BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + HID + PAN(HS)\n");
>   					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + HID + PAN(EDR)\n");
>   					algorithm =
>   						BT_8192E_2ANT_COEX_ALGO_SCO_PAN;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + A2DP + PAN(HS)\n");
>   					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO + A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO + A2DP + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -734,13 +723,13 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID + A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "HID + A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "HID + A2DP + PAN(EDR)\n");
>   					algorithm =
>   					BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				}
> @@ -752,12 +741,12 @@ static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hson) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "ErrorSCO+HID+A2DP+PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "ErrorSCO+HID+A2DP+PAN(HS)\n");
>
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "SCO+HID+A2DP+PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "SCO+HID+A2DP+PAN(EDR)\n");
>   					algorithm =
>   					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -778,10 +767,10 @@ static void halbtc8192e2ant_setfw_dac_swinglevel(struct btc_coexist *btcoexist,
>   	 */
>   	h2c_parameter[0] = dac_swinglvl;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swinglvl);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swinglvl);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
>   }
> @@ -793,9 +782,9 @@ static void halbtc8192e2ant_set_fwdec_btpwr(struct btc_coexist *btcoexist,
>
>   	h2c_parameter[0] = dec_btpwr_lvl;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex] decrease Bt Power level = %d, FW write 0x62 = 0x%x\n",
> -		  dec_btpwr_lvl, h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex] decrease Bt Power level = %d, FW write 0x62 = 0x%x\n",
> +		    dec_btpwr_lvl, h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
>   }
> @@ -803,15 +792,15 @@ static void halbtc8192e2ant_set_fwdec_btpwr(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_dec_btpwr(struct btc_coexist *btcoexist,
>   				      bool force_exec, u8 dec_btpwr_lvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s Dec BT power level = %d\n",
> -		  (force_exec ? "force to" : ""), dec_btpwr_lvl);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s Dec BT power level = %d\n",
> +		    (force_exec ? "force to" : ""), dec_btpwr_lvl);
>   	coex_dm->cur_dec_bt_pwr = dec_btpwr_lvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], preBtDecPwrLvl=%d, curBtDecPwrLvl=%d\n",
> -			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], preBtDecPwrLvl=%d, curBtDecPwrLvl=%d\n",
> +			    coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
>   	}
>   	halbtc8192e2ant_set_fwdec_btpwr(btcoexist, coex_dm->cur_dec_bt_pwr);
>
> @@ -828,10 +817,10 @@ static void halbtc8192e2ant_set_bt_autoreport(struct btc_coexist *btcoexist,
>   	if (enable_autoreport)
>   		h2c_parameter[0] |= BIT0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> -		  (enable_autoreport ? "Enabled!!" : "Disabled!!"),
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> +		    (enable_autoreport ? "Enabled!!" : "Disabled!!"),
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
>   }
> @@ -840,17 +829,17 @@ static void halbtc8192e2ant_bt_autoreport(struct btc_coexist *btcoexist,
>   					  bool force_exec,
>   					  bool enable_autoreport)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s BT Auto report = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((enable_autoreport) ? "Enabled" : "Disabled"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s BT Auto report = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((enable_autoreport) ? "Enabled" : "Disabled"));
>   	coex_dm->cur_bt_auto_report = enable_autoreport;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex] bPreBtAutoReport=%d, bCurBtAutoReport=%d\n",
> -			  coex_dm->pre_bt_auto_report,
> -			  coex_dm->cur_bt_auto_report);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex] bPreBtAutoReport=%d, bCurBtAutoReport=%d\n",
> +			    coex_dm->pre_bt_auto_report,
> +			    coex_dm->cur_bt_auto_report);
>
>   		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
>   			return;
> @@ -864,16 +853,16 @@ static void halbtc8192e2ant_bt_autoreport(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_fw_dac_swinglvl(struct btc_coexist *btcoexist,
>   					    bool force_exec, u8 fw_dac_swinglvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s set FW Dac Swing level = %d\n",
> -		  (force_exec ? "force to" : ""), fw_dac_swinglvl);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s set FW Dac Swing level = %d\n",
> +		    (force_exec ? "force to" : ""), fw_dac_swinglvl);
>   	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swinglvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex] preFwDacSwingLvl=%d, curFwDacSwingLvl=%d\n",
> -			  coex_dm->pre_fw_dac_swing_lvl,
> -			  coex_dm->cur_fw_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex] preFwDacSwingLvl=%d, curFwDacSwingLvl=%d\n",
> +			    coex_dm->pre_fw_dac_swing_lvl,
> +			    coex_dm->cur_fw_dac_swing_lvl);
>
>   		if (coex_dm->pre_fw_dac_swing_lvl ==
>   		    coex_dm->cur_fw_dac_swing_lvl)
> @@ -891,8 +880,8 @@ static void btc8192e2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   {
>   	if (rx_rf_shrink_on) {
>   		/* Shrink RF Rx LPF corner */
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Shrink RF Rx LPF corner!!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
>   					  0xfffff, 0xffffc);
>   	} else {
> @@ -900,8 +889,8 @@ static void btc8192e2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   		 * After initialized, we can use coex_dm->btRf0x1eBackup
>   		 */
>   		if (btcoexist->initilized) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -				  "[BTCoex], Resume RF Rx LPF corner!!\n");
> +			btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +				    "[BTCoex], Resume RF Rx LPF corner!!\n");
>   			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
>   						  0xfffff,
>   						  coex_dm->bt_rf0x1e_backup);
> @@ -912,17 +901,17 @@ static void btc8192e2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_rf_shrink(struct btc_coexist *btcoexist,
>   				      bool force_exec, bool rx_rf_shrink_on)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((rx_rf_shrink_on) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn Rx RF Shrink = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((rx_rf_shrink_on) ? "ON" : "OFF"));
>   	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex]bPreRfRxLpfShrink=%d,bCurRfRxLpfShrink=%d\n",
> -			  coex_dm->pre_rf_rx_lpf_shrink,
> -			  coex_dm->cur_rf_rx_lpf_shrink);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex]bPreRfRxLpfShrink=%d,bCurRfRxLpfShrink=%d\n",
> +			    coex_dm->pre_rf_rx_lpf_shrink,
> +			    coex_dm->cur_rf_rx_lpf_shrink);
>
>   		if (coex_dm->pre_rf_rx_lpf_shrink ==
>   		    coex_dm->cur_rf_rx_lpf_shrink)
> @@ -939,8 +928,8 @@ static void halbtc8192e2ant_set_dac_swingreg(struct btc_coexist *btcoexist,
>   {
>   	u8 val = (u8)level;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], Write SwDacSwing = 0x%x\n", level);
>   	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x883, 0x3e, val);
>   }
>
> @@ -958,22 +947,22 @@ static void halbtc8192e2ant_DacSwing(struct btc_coexist *btcoexist,
>   				     bool force_exec, bool dac_swingon,
>   				     u32 dac_swinglvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn DacSwing=%s, dac_swinglvl = 0x%x\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((dac_swingon) ? "ON" : "OFF"), dac_swinglvl);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn DacSwing=%s, dac_swinglvl = 0x%x\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((dac_swingon) ? "ON" : "OFF"), dac_swinglvl);
>   	coex_dm->cur_dac_swing_on = dac_swingon;
>   	coex_dm->cur_dac_swing_lvl = dac_swinglvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreDacSwingOn=%d, preDacSwingLvl = 0x%x, ",
> -			  coex_dm->pre_dac_swing_on,
> -			  coex_dm->pre_dac_swing_lvl);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "bCurDacSwingOn=%d, curDacSwingLvl = 0x%x\n",
> -			  coex_dm->cur_dac_swing_on,
> -			  coex_dm->cur_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreDacSwingOn=%d, preDacSwingLvl = 0x%x, ",
> +			    coex_dm->pre_dac_swing_on,
> +			    coex_dm->pre_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "bCurDacSwingOn=%d, curDacSwingLvl = 0x%x\n",
> +			    coex_dm->cur_dac_swing_on,
> +			    coex_dm->cur_dac_swing_lvl);
>
>   		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
>   		    (coex_dm->pre_dac_swing_lvl == coex_dm->cur_dac_swing_lvl))
> @@ -991,8 +980,8 @@ static void halbtc8192e2ant_set_agc_table(struct btc_coexist *btcoexist,
>   {
>   	/* BB AGC Gain Table */
>   	if (agc_table_en) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB Agc Table On!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB Agc Table On!\n");
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x0a1A0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x091B0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x081C0001);
> @@ -1000,8 +989,8 @@ static void halbtc8192e2ant_set_agc_table(struct btc_coexist *btcoexist,
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x061E0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x051F0001);
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB Agc Table Off!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB Agc Table Off!\n");
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xaa1A0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa91B0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa81C0001);
> @@ -1014,16 +1003,17 @@ static void halbtc8192e2ant_set_agc_table(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_AgcTable(struct btc_coexist *btcoexist,
>   				     bool force_exec, bool agc_table_en)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s %s Agc Table\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((agc_table_en) ? "Enable" : "Disable"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s %s Agc Table\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((agc_table_en) ? "Enable" : "Disable"));
>   	coex_dm->cur_agc_table_en = agc_table_en;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreAgcTableEn=%d, bCurAgcTableEn=%d\n",
> -			  coex_dm->pre_agc_table_en, coex_dm->cur_agc_table_en);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreAgcTableEn=%d, bCurAgcTableEn=%d\n",
> +			    coex_dm->pre_agc_table_en,
> +			    coex_dm->cur_agc_table_en);
>
>   		if (coex_dm->pre_agc_table_en == coex_dm->cur_agc_table_en)
>   			return;
> @@ -1037,20 +1027,20 @@ static void halbtc8192e2ant_set_coex_table(struct btc_coexist *btcoexist,
>   					   u32 val0x6c0, u32 val0x6c4,
>   					   u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
>   	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
>   }
>
> @@ -1059,30 +1049,30 @@ static void halbtc8192e2ant_coex_table(struct btc_coexist *btcoexist,
>   				       u32 val0x6c0, u32 val0x6c4,
>   				       u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, ",
> -		  (force_exec ? "force to" : ""), val0x6c0);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> -		  val0x6c4, val0x6c8, val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, ",
> +		    (force_exec ? "force to" : ""), val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> +		    val0x6c4, val0x6c8, val0x6cc);
>   	coex_dm->cur_val0x6c0 = val0x6c0;
>   	coex_dm->cur_val0x6c4 = val0x6c4;
>   	coex_dm->cur_val0x6c8 = val0x6c8;
>   	coex_dm->cur_val0x6cc = val0x6cc;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], preVal0x6c0 = 0x%x, preVal0x6c4 = 0x%x, ",
> -			  coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "preVal0x6c8 = 0x%x, preVal0x6cc = 0x%x !!\n",
> -			  coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], curVal0x6c0 = 0x%x, curVal0x6c4 = 0x%x,\n",
> -			  coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "curVal0x6c8 = 0x%x, curVal0x6cc = 0x%x !!\n",
> -			  coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], preVal0x6c0 = 0x%x, preVal0x6c4 = 0x%x, ",
> +			    coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "preVal0x6c8 = 0x%x, preVal0x6cc = 0x%x !!\n",
> +			    coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], curVal0x6c0 = 0x%x, curVal0x6c4 = 0x%x\n",
> +			    coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "curVal0x6c8 = 0x%x, curVal0x6cc = 0x%x !!\n",
> +			    coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
>
>   		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
>   		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
> @@ -1136,9 +1126,9 @@ static void halbtc8192e2ant_set_fw_ignore_wlanact(struct btc_coexist *btcoexist,
>   	if (enable)
>   		h2c_parameter[0] |= BIT0; /* function enable */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex]set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex]set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
>   }
> @@ -1146,18 +1136,18 @@ static void halbtc8192e2ant_set_fw_ignore_wlanact(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_IgnoreWlanAct(struct btc_coexist *btcoexist,
>   					  bool force_exec, bool enable)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn Ignore WlanAct %s\n",
> -		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn Ignore WlanAct %s\n",
> +		    (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
>   	coex_dm->cur_ignore_wlan_act = enable;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPreIgnoreWlanAct = %d ",
> -			  coex_dm->pre_ignore_wlan_act);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "bCurIgnoreWlanAct = %d!!\n",
> -			  coex_dm->cur_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPreIgnoreWlanAct = %d ",
> +			    coex_dm->pre_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "bCurIgnoreWlanAct = %d!!\n",
> +			    coex_dm->cur_ignore_wlan_act);
>
>   		if (coex_dm->pre_ignore_wlan_act ==
>   		    coex_dm->cur_ignore_wlan_act)
> @@ -1185,11 +1175,11 @@ static void halbtc8192e2ant_SetFwPstdma(struct btc_coexist *btcoexist, u8 byte1,
>   	coex_dm->ps_tdma_para[3] = byte4;
>   	coex_dm->ps_tdma_para[4] = byte5;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
> -		  h2c_parameter[0],
> -		  h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
> -		  h2c_parameter[3] << 8 | h2c_parameter[4]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
> +		    h2c_parameter[0],
> +		    h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
> +		    h2c_parameter[3] << 8 | h2c_parameter[4]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
>   }
> @@ -1213,20 +1203,20 @@ static void btc8192e2ant_sw_mec2(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_ps_tdma(struct btc_coexist *btcoexist,
>   				    bool force_exec, bool turn_on, u8 type)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn %s PS TDMA, type=%d\n",
> -		  (force_exec ? "force to" : ""),
> -		  (turn_on ? "ON" : "OFF"), type);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn %s PS TDMA, type=%d\n",
> +		    (force_exec ? "force to" : ""),
> +		    (turn_on ? "ON" : "OFF"), type);
>   	coex_dm->cur_ps_tdma_on = turn_on;
>   	coex_dm->cur_ps_tdma = type;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
> -			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
> -			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
> +			    coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
> +			    coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
>
>   		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
>   		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
> @@ -1353,8 +1343,8 @@ static void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
>   	u8 mimops = BTC_MIMO_PS_DYNAMIC;
>   	u32 disra_mask = 0x0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], REAL set SS Type = %d\n", sstype);
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], REAL set SS Type = %d\n", sstype);
>
>   	disra_mask = halbtc8192e2ant_decidera_mask(btcoexist, sstype,
>   						   coex_dm->curra_masktype);
> @@ -1386,9 +1376,9 @@ static void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
>   static void halbtc8192e2ant_switch_sstype(struct btc_coexist *btcoexist,
>   					  bool force_exec, u8 new_sstype)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], %s Switch SS Type = %d\n",
> -		  (force_exec ? "force to" : ""), new_sstype);
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], %s Switch SS Type = %d\n",
> +		    (force_exec ? "force to" : ""), new_sstype);
>   	coex_dm->cur_sstype = new_sstype;
>
>   	if (!force_exec) {
> @@ -1469,8 +1459,8 @@ static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
>   		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
>   				   &low_pwr_disable);
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non-connected idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non-connected idle!!\n");
>
>   		if ((BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE ==
>   		     coex_dm->bt_status) ||
> @@ -1506,8 +1496,8 @@ static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
>   					   BTC_SET_ACT_DISABLE_LOW_POWER,
>   					   &low_pwr_disable);
>
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Wifi connected + BT non connected-idle!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Wifi connected + BT non connected-idle!!\n");
>
>   			halbtc8192e2ant_switch_sstype(btcoexist,
>   						      NORMAL_EXEC, 2);
> @@ -1534,8 +1524,8 @@ static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
>
>   			if (bt_hson)
>   				return false;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Wifi connected + BT connected-idle!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Wifi connected + BT connected-idle!!\n");
>
>   			halbtc8192e2ant_switch_sstype(btcoexist,
>   						      NORMAL_EXEC, 2);
> @@ -1560,12 +1550,12 @@ static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
>   					   &low_pwr_disable);
>
>   			if (wifi_busy) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "Wifi Connected-Busy + BT Busy!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "Wifi Connected-Busy + BT Busy!!\n");
>   				common = false;
>   			} else {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "Wifi Connected-Idle + BT Busy!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "Wifi Connected-Idle + BT Busy!!\n");
>
>   				halbtc8192e2ant_switch_sstype(btcoexist,
>   							      NORMAL_EXEC, 1);
> @@ -1592,9 +1582,8 @@ static void btc8192e_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   			  int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>
>   		if (coex_dm->cur_ps_tdma == 71) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
> @@ -1689,9 +1678,8 @@ static void btc8192e_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 71);
> @@ -1795,9 +1783,8 @@ static void btc8192e_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   			  int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 6);
> @@ -1886,9 +1873,8 @@ static void btc8192e_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 2);
> @@ -1983,9 +1969,8 @@ static void btc8192e_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   			  int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 7);
> @@ -2074,9 +2059,8 @@ static void btc8192e_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 3);
> @@ -2178,13 +2162,13 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	int result;
>   	u8 retry_cnt = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], TdmaDurationAdjust()\n");
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], TdmaDurationAdjust()\n");
>
>   	if (!coex_dm->auto_tdma_adjust) {
>   		coex_dm->auto_tdma_adjust = true;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], first run TdmaDurationAdjust()!!\n");
>   		if (sco_hid) {
>   			if (tx_pause) {
>   				if (max_interval == 1) {
> @@ -2288,11 +2272,11 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	} else {
>   		/* accquire the BT TRx retry count from BT_Info byte2 */
>   		retry_cnt = coex_sta->bt_retry_cnt;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], retry_cnt = %d\n", retry_cnt);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], up=%d, dn=%d, m=%d, n=%d, wait_cnt=%d\n",
> -			  up, dn, m, n, wait_cnt);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], retry_cnt = %d\n", retry_cnt);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], up=%d, dn=%d, m=%d, n=%d, wait_cnt=%d\n",
> +			    up, dn, m, n, wait_cnt);
>   		result = 0;
>   		wait_cnt++;
>   		/* no retry in the last 2-second duration */
> @@ -2309,9 +2293,8 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   				up = 0;
>   				dn = 0;
>   				result = 1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex]Increase wifi duration!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex]Increase wifi duration!!\n");
>   			}
>   		} else if (retry_cnt <= 3) {
>   			up--;
> @@ -2334,9 +2317,8 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   				dn = 0;
>   				wait_cnt = 0;
>   				result = -1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "Reduce wifi duration for retry<3\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "Reduce wifi duration for retry<3\n");
>   			}
>   		} else {
>   			if (wait_cnt == 1)
> @@ -2352,12 +2334,12 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   			dn = 0;
>   			wait_cnt = 0;
>   			result = -1;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "Decrease wifi duration for retryCounter>3!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "Decrease wifi duration for retryCounter>3!!\n");
>   		}
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], max Interval = %d\n", max_interval);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], max Interval = %d\n", max_interval);
>   		if (max_interval == 1)
>   			btc8192e_int1(btcoexist, tx_pause, result);
>   		else if (max_interval == 2)
> @@ -2373,11 +2355,11 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	if (coex_dm->cur_ps_tdma != coex_dm->tdma_adj_type) {
>   		bool scan = false, link = false, roam = false;
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], PsTdma type dismatch!!!, ");
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "curPsTdma=%d, recordPsTdma=%d\n",
> -			  coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], PsTdma type dismatch!!!, ");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "curPsTdma=%d, recordPsTdma=%d\n",
> +			    coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
> @@ -2388,9 +2370,8 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   						true,
>   						coex_dm->tdma_adj_type);
>   		else
> -			BTC_PRINT(BTC_MSG_ALGORITHM,
> -				  ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
>   	}
>   }
>
> @@ -2594,8 +2575,8 @@ static void halbtc8192e2ant_action_a2dp(struct btc_coexist *btcoexist)
>   	     btrssi_state == BTC_RSSI_STATE_STAY_LOW) &&
>   	    (wifirssi_state == BTC_RSSI_STATE_LOW ||
>   	     wifirssi_state == BTC_RSSI_STATE_STAY_LOW)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], A2dp, wifi/bt rssi both LOW!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], A2dp, wifi/bt rssi both LOW!!\n");
>   		long_dist = true;
>   	}
>   	if (long_dist) {
> @@ -3100,105 +3081,105 @@ static void halbtc8192e2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   {
>   	u8 algorithm = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], RunCoexistMechanism()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], RunCoexistMechanism()===>\n");
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], return for Manual CTRL <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], return for Manual CTRL <===\n");
>   		return;
>   	}
>
>   	if (coex_sta->under_ips) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is under IPS !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is under IPS !!!\n");
>   		return;
>   	}
>
>   	algorithm = halbtc8192e2ant_action_algorithm(btcoexist);
>   	if (coex_sta->c2h_bt_inquiry_page &&
>   	    (BT_8192E_2ANT_COEX_ALGO_PANHS != algorithm)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BT is under inquiry/page scan !!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BT is under inquiry/page scan !!\n");
>   		halbtc8192e2ant_action_bt_inquiry(btcoexist);
>   		return;
>   	}
>
>   	coex_dm->cur_algorithm = algorithm;
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
>
>   	if (halbtc8192e2ant_is_common_action(btcoexist)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Action 2-Ant common.\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Action 2-Ant common\n");
>   		coex_dm->auto_tdma_adjust = false;
>   	} else {
>   		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex] preAlgorithm=%d, curAlgorithm=%d\n",
> -				  coex_dm->pre_algorithm,
> -				  coex_dm->cur_algorithm);
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex] preAlgorithm=%d, curAlgorithm=%d\n",
> +				    coex_dm->pre_algorithm,
> +				    coex_dm->cur_algorithm);
>   			coex_dm->auto_tdma_adjust = false;
>   		}
>   		switch (coex_dm->cur_algorithm) {
>   		case BT_8192E_2ANT_COEX_ALGO_SCO:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = SCO.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = SCO\n");
>   			halbtc8192e2ant_action_sco(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_SCO_PAN:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = SCO+PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = SCO+PAN(EDR)\n");
>   			halbtc8192e2ant_action_sco_pan(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = HID\n");
>   			halbtc8192e2ant_action_hid(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = A2DP\n");
>   			halbtc8192e2ant_action_a2dp(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_A2DP_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = A2DP+PAN(HS).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = A2DP+PAN(HS)\n");
>   			halbtc8192e2ant_action_a2dp_pan_hs(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = PAN(EDR)\n");
>   			halbtc8192e2ant_action_pan_edr(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = HS mode.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = HS mode\n");
>   			halbtc8192e2ant_action_pan_hs(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_PANEDR_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = PAN+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = PAN+A2DP\n");
>   			halbtc8192e2ant_action_pan_edr_a2dp(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_PANEDR_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = PAN(EDR)+HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = PAN(EDR)+HID\n");
>   			halbtc8192e2ant_action_pan_edr_hid(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = HID+A2DP+PAN.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = HID+A2DP+PAN\n");
>   			btc8192e2ant_action_hid_a2dp_pan_edr(btcoexist);
>   			break;
>   		case BT_8192E_2ANT_COEX_ALGO_HID_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = HID+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = HID+A2DP\n");
>   			halbtc8192e2ant_action_hid_a2dp(btcoexist);
>   			break;
>   		default:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "Action 2-Ant, algorithm = unknown!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "Action 2-Ant, algorithm = unknown!!\n");
>   			/* halbtc8192e2ant_coex_alloff(btcoexist); */
>   			break;
>   		}
> @@ -3212,8 +3193,8 @@ static void halbtc8192e2ant_init_hwconfig(struct btc_coexist *btcoexist,
>   	u16 u16tmp = 0;
>   	u8 u8tmp = 0;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], 2Ant Init HW Config!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], 2Ant Init HW Config!!\n");
>
>   	if (backup) {
>   		/* backup rf 0x1e value */
> @@ -3296,8 +3277,8 @@ void ex_halbtc8192e2ant_init_hwconfig(struct btc_coexist *btcoexist)
>
>   void ex_halbtc8192e2ant_init_coex_dm(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], Coex Mechanism Init!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], Coex Mechanism Init!!\n");
>   	halbtc8192e2ant_init_coex_dm(btcoexist);
>   }
>
> @@ -3525,13 +3506,13 @@ void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist)
>   void ex_halbtc8192e2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_IPS_ENTER == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS ENTER notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS ENTER notify\n");
>   		coex_sta->under_ips = true;
>   		halbtc8192e2ant_coex_alloff(btcoexist);
>   	} else if (BTC_IPS_LEAVE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS LEAVE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS LEAVE notify\n");
>   		coex_sta->under_ips = false;
>   	}
>   }
> @@ -3539,12 +3520,12 @@ void ex_halbtc8192e2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_halbtc8192e2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_LPS_ENABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS ENABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS ENABLE notify\n");
>   		coex_sta->under_lps = true;
>   	} else if (BTC_LPS_DISABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS DISABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS DISABLE notify\n");
>   		coex_sta->under_lps = false;
>   	}
>   }
> @@ -3552,21 +3533,21 @@ void ex_halbtc8192e2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_halbtc8192e2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_SCAN_START == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN START notify\n");
>   	else if (BTC_SCAN_FINISH == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN FINISH notify\n");
>   }
>
>   void ex_halbtc8192e2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_ASSOCIATE_START == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT START notify\n");
>   	else if (BTC_ASSOCIATE_FINISH == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT FINISH notify\n");
>   }
>
>   void ex_halbtc8192e2ant_media_status_notify(struct btc_coexist *btcoexist,
> @@ -3582,11 +3563,11 @@ void ex_halbtc8192e2ant_media_status_notify(struct btc_coexist *btcoexist,
>   		return;
>
>   	if (BTC_MEDIA_CONNECT == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA connect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA connect notify\n");
>   	else
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA disconnect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA disconnect notify\n");
>
>   	/* only 2.4G we need to inform bt the chnl mask */
>   	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
> @@ -3606,10 +3587,10 @@ void ex_halbtc8192e2ant_media_status_notify(struct btc_coexist *btcoexist,
>   	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
>   	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x66 = 0x%x\n",
> -		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> -		  h2c_parameter[2]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x66 = 0x%x\n",
> +		    h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> +		    h2c_parameter[2]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>   }
> @@ -3618,8 +3599,8 @@ void ex_halbtc8192e2ant_special_packet_notify(struct btc_coexist *btcoexist,
>   					      u8 type)
>   {
>   	if (type == BTC_PACKET_DHCP)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], DHCP Packet notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], DHCP Packet notify\n");
>   }
>
>   void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
> @@ -3637,19 +3618,19 @@ void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		rsp_source = BT_INFO_SRC_8192E_2ANT_WIFI_FW;
>   	coex_sta->bt_info_c2h_cnt[rsp_source]++;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Bt info[%d], length=%d, hex data = [",
> -		  rsp_source, length);
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Bt info[%d], length=%d, hex data = [",
> +		      rsp_source, length);
>   	for (i = 0; i < length; i++) {
>   		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
>   		if (i == 1)
>   			bt_info = tmp_buf[i];
>   		if (i == length-1)
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x]\n", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x]\n", tmp_buf[i]);
>   		else
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x, ", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x, ", tmp_buf[i]);
>   	}
>
>   	if (BT_INFO_SRC_8192E_2ANT_WIFI_FW != rsp_source) {
> @@ -3666,8 +3647,8 @@ void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		 * because bt is reset and loss of the info.
>   		 */
>   		if ((coex_sta->bt_info_ext & BIT1)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "bit1, send wifi BW&Chnl to BT!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "bit1, send wifi BW&Chnl to BT!!\n");
>   			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
>   					   &wifi_connected);
>   			if (wifi_connected)
> @@ -3683,8 +3664,8 @@ void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		if ((coex_sta->bt_info_ext & BIT3)) {
>   			if (!btcoexist->manual_control &&
>   			    !btcoexist->stop_coex_dm) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "bit3, BT NOT ignore Wlan active!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "bit3, BT NOT ignore Wlan active!\n");
>   				halbtc8192e2ant_IgnoreWlanAct(btcoexist,
>   							      FORCE_EXEC,
>   							      false);
> @@ -3742,25 +3723,25 @@ void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   	if (!(bt_info&BT_INFO_8192E_2ANT_B_CONNECTION)) {
>   		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BT Non-Connected idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BT Non-Connected idle!!!\n");
>   	} else if (bt_info == BT_INFO_8192E_2ANT_B_CONNECTION) {
>   		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], bt_infoNotify(), BT Connected-idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], bt_infoNotify(), BT Connected-idle!!!\n");
>   	} else if ((bt_info&BT_INFO_8192E_2ANT_B_SCO_ESCO) ||
>   		   (bt_info&BT_INFO_8192E_2ANT_B_SCO_BUSY)) {
>   		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_SCO_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], bt_infoNotify(), BT SCO busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], bt_infoNotify(), BT SCO busy!!!\n");
>   	} else if (bt_info&BT_INFO_8192E_2ANT_B_ACL_BUSY) {
>   		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_ACL_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], bt_infoNotify(), BT ACL busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], bt_infoNotify(), BT ACL busy!!!\n");
>   	} else {
>   		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_MAX;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex]bt_infoNotify(), BT Non-Defined state!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex]bt_infoNotify(), BT Non-Defined state!!!\n");
>   	}
>
>   	if ((BT_8192E_2ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
> @@ -3788,7 +3769,7 @@ void ex_halbtc8192e2ant_stack_operation_notify(struct btc_coexist *btcoexist,
>
>   void ex_halbtc8192e2ant_halt_notify(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
> +	btc_iface_dbg(INTF_NOTIFY, "[BTCoex], Halt notify\n");
>
>   	halbtc8192e2ant_IgnoreWlanAct(btcoexist, FORCE_EXEC, true);
>   	ex_halbtc8192e2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
> @@ -3801,29 +3782,29 @@ void ex_halbtc8192e2ant_periodical(struct btc_coexist *btcoexist)
>   	struct btc_board_info *board_info = &btcoexist->board_info;
>   	struct btc_stack_info *stack_info = &btcoexist->stack_info;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "=======================Periodical=======================\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "=======================Periodical=======================\n");
>   	if (dis_ver_info_cnt <= 5) {
>   		dis_ver_info_cnt += 1;
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "************************************************\n");
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> -			  board_info->pg_ant_num, board_info->btdm_ant_num,
> -			  board_info->btdm_ant_pos);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "BT stack/ hci ext ver = %s / %d\n",
> -			  ((stack_info->profile_notified) ? "Yes" : "No"),
> -			  stack_info->hci_version);
> +		btc_iface_dbg(INTF_INIT,
> +			      "************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> +			      board_info->pg_ant_num, board_info->btdm_ant_num,
> +			      board_info->btdm_ant_pos);
> +		btc_iface_dbg(INTF_INIT,
> +			      "BT stack/ hci ext ver = %s / %d\n",
> +			      ((stack_info->profile_notified) ? "Yes" : "No"),
> +			      stack_info->hci_version);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>   				   &bt_patch_ver);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> -			  glcoex_ver_date_8192e_2ant, glcoex_ver_8192e_2ant,
> -			  fw_ver, bt_patch_ver, bt_patch_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> +			      glcoex_ver_date_8192e_2ant, glcoex_ver_8192e_2ant,
> +			      fw_ver, bt_patch_ver, bt_patch_ver);
> +		btc_iface_dbg(INTF_INIT,
> +			      "************************************************\n");
>   	}
>
>   #if (BT_AUTO_REPORT_ONLY_8192E_2ANT == 0)
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
> index 7e239d3..16add42 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
> @@ -74,28 +74,28 @@ static u8 halbtc8723b1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "[BTCoex], BT Rssi thresh error!!\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "[BTCoex], BT Rssi thresh error!!\n");
>   			return coex_sta->pre_bt_rssi_state;
>   		}
>
> @@ -104,12 +104,12 @@ static u8 halbtc8723b1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_bt_rssi_state ==
>   					BTC_RSSI_STATE_MEDIUM) ||
> @@ -118,26 +118,26 @@ static u8 halbtc8723b1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh1 +
>   					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Medium\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh1) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	}
> @@ -165,32 +165,28 @@ static u8 halbtc8723b1ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
> -				  "[BTCoex], wifi RSSI thresh error!!\n");
> +			btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +				    "[BTCoex], wifi RSSI thresh error!!\n");
>   			return coex_sta->pre_wifi_rssi_state[index];
>   		}
>
> @@ -201,14 +197,12 @@ static u8 halbtc8723b1ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh +
>   					 BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
>   						BTC_RSSI_STATE_MEDIUM) ||
> @@ -217,31 +211,26 @@ static u8 halbtc8723b1ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh1 +
>   					 BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Medium\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh1) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	}
> @@ -435,9 +424,9 @@ static void halbtc8723b1ant_query_bt_info(struct btc_coexist *btcoexist)
>
>   	h2c_parameter[0] |= BIT0;	/* trigger*/
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
>   }
> @@ -532,8 +521,8 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>
>   	if (!bt_link_info->bt_link_exist) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], No BT link exists!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], No BT link exists!!!\n");
>   		return algorithm;
>   	}
>
> @@ -548,27 +537,27 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>
>   	if (numdiffprofile == 1) {
>   		if (bt_link_info->sco_exist) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT Profile = SCO only\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT Profile = SCO only\n");
>   			algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
>   		} else {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = HID only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = HID only\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = A2DP only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = A2DP only\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_A2DP;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = PAN(HS) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = PAN(HS) only\n");
>   					algorithm =
>   						BT_8723B_1ANT_COEX_ALGO_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = PAN(EDR) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = PAN(EDR) only\n");
>   					algorithm =
>   						BT_8723B_1ANT_COEX_ALGO_PANEDR;
>   				}
> @@ -577,21 +566,21 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   	} else if (numdiffprofile == 2) {
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + HID\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + PAN(HS)\n");
>   					algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -599,32 +588,32 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   		} else {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = HID + A2DP\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = HID + A2DP\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_A2DP_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_A2DP;
>   				}
> @@ -634,31 +623,31 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
>   				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
>   					algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -668,13 +657,13 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				}
> @@ -686,11 +675,11 @@ static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
>   					algorithm =
>   					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -717,9 +706,9 @@ static void btc8723b1ant_set_sw_pen_tx_rate_adapt(struct btc_coexist *btcoexist,
>   		h2c_parameter[5] = 0xf9;  /*MCS5 or OFDM36 */
>   	}
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
> -		  (low_penalty_ra ? "ON!!" : "OFF!!"));
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set WiFi Low-Penalty Retry: %s",
> +		    (low_penalty_ra ? "ON!!" : "OFF!!"));
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
>   }
> @@ -743,20 +732,20 @@ static void halbtc8723b1ant_set_coex_table(struct btc_coexist *btcoexist,
>   					   u32 val0x6c0, u32 val0x6c4,
>   					   u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
>   	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
>   }
>
> @@ -765,10 +754,10 @@ static void halbtc8723b1ant_coex_table(struct btc_coexist *btcoexist,
>   				       u32 val0x6c4, u32 val0x6c8,
>   				       u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6cc = 0x%x\n",
> -		  (force_exec ? "force to" : ""),
> -		  val0x6c0, val0x6c4, val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6cc = 0x%x\n",
> +		    (force_exec ? "force to" : ""),
> +		    val0x6c0, val0x6c4, val0x6cc);
>   	coex_dm->cur_val0x6c0 = val0x6c0;
>   	coex_dm->cur_val0x6c4 = val0x6c4;
>   	coex_dm->cur_val0x6c8 = val0x6c8;
> @@ -839,9 +828,9 @@ static void halbtc8723b1ant_SetFwIgnoreWlanAct(struct btc_coexist *btcoexist,
>   	if (enable)
>   		h2c_parameter[0] |= BIT0;	/* function enable */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
>   }
> @@ -849,16 +838,16 @@ static void halbtc8723b1ant_SetFwIgnoreWlanAct(struct btc_coexist *btcoexist,
>   static void halbtc8723b1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
>   					    bool force_exec, bool enable)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn Ignore WlanAct %s\n",
> -		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn Ignore WlanAct %s\n",
> +		    (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
>   	coex_dm->cur_ignore_wlan_act = enable;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPreIgnoreWlanAct = %d, bCurIgnoreWlanAct = %d!!\n",
> -			  coex_dm->pre_ignore_wlan_act,
> -			  coex_dm->cur_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPreIgnoreWlanAct = %d, bCurIgnoreWlanAct = %d!!\n",
> +			    coex_dm->pre_ignore_wlan_act,
> +			    coex_dm->cur_ignore_wlan_act);
>
>   		if (coex_dm->pre_ignore_wlan_act ==
>   		    coex_dm->cur_ignore_wlan_act)
> @@ -882,8 +871,8 @@ static void halbtc8723b1ant_set_fw_ps_tdma(struct btc_coexist *btcoexist,
>
>   	if (ap_enable) {
>   		if ((byte1 & BIT4) && !(byte1 & BIT5)) {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "[BTCoex], FW for 1Ant AP mode\n");
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "[BTCoex], FW for 1Ant AP mode\n");
>   			real_byte1 &= ~BIT4;
>   			real_byte1 |= BIT5;
>
> @@ -904,13 +893,13 @@ static void halbtc8723b1ant_set_fw_ps_tdma(struct btc_coexist *btcoexist,
>   	coex_dm->ps_tdma_para[3] = byte4;
>   	coex_dm->ps_tdma_para[4] = real_byte5;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], PS-TDMA H2C cmd =0x%x%08x\n",
> -		  h2c_parameter[0],
> -		  h2c_parameter[1] << 24 |
> -		  h2c_parameter[2] << 16 |
> -		  h2c_parameter[3] << 8 |
> -		  h2c_parameter[4]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], PS-TDMA H2C cmd =0x%x%08x\n",
> +		    h2c_parameter[0],
> +		    h2c_parameter[1] << 24 |
> +		    h2c_parameter[2] << 16 |
> +		    h2c_parameter[3] << 8 |
> +		    h2c_parameter[4]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
>   }
> @@ -929,22 +918,22 @@ static void halbtc8723b1ant_LpsRpwm(struct btc_coexist *btcoexist,
>   				    bool force_exec,
>   				    u8 lps_val, u8 rpwm_val)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
> -		  (force_exec ? "force to" : ""), lps_val, rpwm_val);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
> +		    (force_exec ? "force to" : ""), lps_val, rpwm_val);
>   	coex_dm->cur_lps = lps_val;
>   	coex_dm->cur_rpwm = rpwm_val;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], LPS-RxBeaconMode = 0x%x , LPS-RPWM = 0x%x!!\n",
> -			  coex_dm->cur_lps, coex_dm->cur_rpwm);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], LPS-RxBeaconMode = 0x%x , LPS-RPWM = 0x%x!!\n",
> +			    coex_dm->cur_lps, coex_dm->cur_rpwm);
>
>   		if ((coex_dm->pre_lps == coex_dm->cur_lps) &&
>   		    (coex_dm->pre_rpwm == coex_dm->cur_rpwm)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], LPS-RPWM_Last = 0x%x , LPS-RPWM_Now = 0x%x!!\n",
> -				  coex_dm->pre_rpwm, coex_dm->cur_rpwm);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], LPS-RPWM_Last = 0x%x , LPS-RPWM_Now = 0x%x!!\n",
> +				    coex_dm->pre_rpwm, coex_dm->cur_rpwm);
>
>   			return;
>   		}
> @@ -958,8 +947,8 @@ static void halbtc8723b1ant_LpsRpwm(struct btc_coexist *btcoexist,
>   static void halbtc8723b1ant_sw_mechanism(struct btc_coexist *btcoexist,
>   					 bool low_penalty_ra)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
>
>   	halbtc8723b1ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
>   }
> @@ -1174,13 +1163,13 @@ static void halbtc8723b1ant_ps_tdma(struct btc_coexist *btcoexist,
>
>   	if (!force_exec) {
>   		if (coex_dm->cur_ps_tdma_on)
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], ******** TDMA(on, %d) *********\n",
> -				  coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], ******** TDMA(on, %d) *********\n",
> +				    coex_dm->cur_ps_tdma);
>   		else
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], ******** TDMA(off, %d) ********\n",
> -				  coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], ******** TDMA(off, %d) ********\n",
> +				    coex_dm->cur_ps_tdma);
>
>   		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
>   		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
> @@ -1394,45 +1383,45 @@ static bool halbtc8723b1ant_is_common_action(struct btc_coexist *btcoexist)
>
>   	if (!wifi_connected &&
>   	    BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE == coex_dm->bt_status) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
>   		halbtc8723b1ant_sw_mechanism(btcoexist, false);
>   		commom = true;
>   	} else if (wifi_connected &&
>   		   (BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi connected + BT non connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi connected + BT non connected-idle!!\n");
>   		halbtc8723b1ant_sw_mechanism(btcoexist, false);
>   		commom = true;
>   	} else if (!wifi_connected &&
>   		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE ==
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
>   		halbtc8723b1ant_sw_mechanism(btcoexist, false);
>   		commom = true;
>   	} else if (wifi_connected &&
>   		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE ==
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi connected + BT connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi connected + BT connected-idle!!\n");
>   		halbtc8723b1ant_sw_mechanism(btcoexist, false);
>   		commom = true;
>   	} else if (!wifi_connected &&
>   		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE !=
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  ("[BTCoex], Wifi non connected-idle + BT Busy!!\n"));
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT Busy!!\n");
>   		halbtc8723b1ant_sw_mechanism(btcoexist, false);
>   		commom = true;
>   	} else {
>   		if (wifi_busy)
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
>   		else
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
>
>   		commom = false;
>   	}
> @@ -1451,8 +1440,8 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>   	u8 retry_count = 0, bt_info_ext;
>   	bool wifi_busy = false;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], TdmaDurationAdjustForAcl()\n");
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], TdmaDurationAdjustForAcl()\n");
>
>   	if (BT_8723B_1ANT_WIFI_STATUS_CONNECTED_BUSY == wifi_status)
>   		wifi_busy = true;
> @@ -1481,8 +1470,8 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>
>   	if (!coex_dm->auto_tdma_adjust) {
>   		coex_dm->auto_tdma_adjust = true;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], first run TdmaDurationAdjust()!!\n");
>
>   		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
>   		coex_dm->tdma_adj_type = 2;
> @@ -1513,9 +1502,8 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>   				up = 0;
>   				dn = 0;
>   				result = 1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Increase wifi duration!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Increase wifi duration!!\n");
>   			}
>   		} else if (retry_count <= 3) {
>   			up--;
> @@ -1538,9 +1526,8 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>   				dn = 0;
>   				wait_count = 0;
>   				result = -1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
>   			}
>   		} else {
>   			if (wait_count == 1)
> @@ -1556,8 +1543,8 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>   			dn = 0;
>   			wait_count = 0;
>   			result = -1;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
>   		}
>
>   		if (result == -1) {
> @@ -1602,9 +1589,9 @@ static void btc8723b1ant_tdma_dur_adj_for_acl(struct btc_coexist *btcoexist,
>   			}
>   		} else {	  /*no change */
>   			/*if busy / idle change */
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex],********* TDMA(on, %d) ********\n",
> -				  coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex],********* TDMA(on, %d) ********\n",
> +				    coex_dm->cur_ps_tdma);
>   		}
>
>   		if (coex_dm->cur_ps_tdma != 1 && coex_dm->cur_ps_tdma != 2 &&
> @@ -2010,15 +1997,15 @@ static void halbtc8723b1ant_action_wifi_connected(struct btc_coexist *btcoexist)
>   	bool scan = false, link = false, roam = false;
>   	bool under_4way = false, ap_enable = false;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], CoexForWifiConnect()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], CoexForWifiConnect()===>\n");
>
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_4_WAY_PROGRESS,
>   			   &under_4way);
>   	if (under_4way) {
>   		halbtc8723b1ant_action_wifi_connected_special_packet(btcoexist);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
>   		return;
>   	}
>
> @@ -2032,8 +2019,8 @@ static void halbtc8723b1ant_action_wifi_connected(struct btc_coexist *btcoexist)
>   		else
>   			halbtc8723b1ant_action_wifi_connected_special_packet(
>   								     btcoexist);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
>   		return;
>   	}
>
> @@ -2102,58 +2089,58 @@ static void btc8723b1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
>   	if (!halbtc8723b1ant_is_common_action(btcoexist)) {
>   		switch (coex_dm->cur_algorithm) {
>   		case BT_8723B_1ANT_COEX_ALGO_SCO:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = SCO.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = SCO\n");
>   			halbtc8723b1ant_action_sco(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID\n");
>   			halbtc8723b1ant_action_hid(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = A2DP\n");
>   			halbtc8723b1ant_action_a2dp(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_A2DP_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = A2DP+PAN(HS).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = A2DP+PAN(HS)\n");
>   			halbtc8723b1ant_action_a2dp_pan_hs(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN(EDR)\n");
>   			halbtc8723b1ant_action_pan_edr(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HS mode.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HS mode\n");
>   			halbtc8723b1ant_action_pan_hs(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_PANEDR_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN+A2DP\n");
>   			halbtc8723b1ant_action_pan_edr_a2dp(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_PANEDR_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN(EDR)+HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN(EDR)+HID\n");
>   			halbtc8723b1ant_action_pan_edr_hid(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_HID_A2DP_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID+A2DP+PAN.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID+A2DP+PAN\n");
>   			btc8723b1ant_action_hid_a2dp_pan_edr(btcoexist);
>   			break;
>   		case BT_8723B_1ANT_COEX_ALGO_HID_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID+A2DP\n");
>   			halbtc8723b1ant_action_hid_a2dp(btcoexist);
>   			break;
>   		default:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = coexist All Off!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = coexist All Off!!\n");
>   			break;
>   		}
>   		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
> @@ -2171,24 +2158,24 @@ static void halbtc8723b1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	u32 wifi_link_status = 0;
>   	u32 num_of_wifi_link = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], RunCoexistMechanism()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], RunCoexistMechanism()===>\n");
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
>   		return;
>   	}
>
>   	if (btcoexist->stop_coex_dm) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
>   		return;
>   	}
>
>   	if (coex_sta->under_ips) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is under IPS !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is under IPS !!!\n");
>   		return;
>   	}
>
> @@ -2267,8 +2254,8 @@ static void halbtc8723b1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	if (!wifi_connected) {
>   		bool scan = false, link = false, roam = false;
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is non connected-idle !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is non connected-idle !!!\n");
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
> @@ -2305,8 +2292,8 @@ static void halbtc8723b1ant_init_hw_config(struct btc_coexist *btcoexist,
>   	u8 u8tmp = 0;
>   	u32 cnt_bt_cal_chk = 0;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], 1Ant Init HW Config!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], 1Ant Init HW Config!!\n");
>
>   	if (backup) {/* backup rf 0x1e value */
>   		coex_dm->backup_arfr_cnt1 =
> @@ -2333,14 +2320,14 @@ static void halbtc8723b1ant_init_hw_config(struct btc_coexist *btcoexist,
>   		u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x49d);
>   		cnt_bt_cal_chk++;
>   		if (u32tmp & BIT0) {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -				  "[BTCoex], ########### BT calibration(cnt=%d) ###########\n",
> -				  cnt_bt_cal_chk);
> +			btc_iface_dbg(INTF_INIT,
> +				      "[BTCoex], ########### BT calibration(cnt=%d) ###########\n",
> +				      cnt_bt_cal_chk);
>   			mdelay(50);
>   		} else {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -				  "[BTCoex], ********** BT NOT calibration (cnt=%d)**********\n",
> -				  cnt_bt_cal_chk);
> +			btc_iface_dbg(INTF_INIT,
> +				      "[BTCoex], ********** BT NOT calibration (cnt=%d)**********\n",
> +				      cnt_bt_cal_chk);
>   			break;
>   		}
>   	}
> @@ -2383,8 +2370,8 @@ void ex_halbtc8723b1ant_init_hwconfig(struct btc_coexist *btcoexist)
>
>   void ex_halbtc8723b1ant_init_coex_dm(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], Coex Mechanism Init!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], Coex Mechanism Init!!\n");
>
>   	btcoexist->stop_coex_dm = false;
>
> @@ -2677,8 +2664,8 @@ void ex_halbtc8723b1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   		return;
>
>   	if (BTC_IPS_ENTER == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS ENTER notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS ENTER notify\n");
>   		coex_sta->under_ips = true;
>
>   		halbtc8723b1ant_SetAntPath(btcoexist, BTC_ANT_PATH_BT,
> @@ -2689,8 +2676,8 @@ void ex_halbtc8723b1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   						     NORMAL_EXEC, 0);
>   		halbtc8723b1ant_wifi_off_hw_cfg(btcoexist);
>   	} else if (BTC_IPS_LEAVE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS LEAVE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS LEAVE notify\n");
>   		coex_sta->under_ips = false;
>
>   		halbtc8723b1ant_init_hw_config(btcoexist, false);
> @@ -2705,12 +2692,12 @@ void ex_halbtc8723b1ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   		return;
>
>   	if (BTC_LPS_ENABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS ENABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS ENABLE notify\n");
>   		coex_sta->under_lps = true;
>   	} else if (BTC_LPS_DISABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS DISABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS DISABLE notify\n");
>   		coex_sta->under_lps = false;
>   	}
>   }
> @@ -2753,15 +2740,15 @@ void ex_halbtc8723b1ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   	}
>
>   	if (BTC_SCAN_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN START notify\n");
>   		if (!wifi_connected)	/* non-connected scan */
>   			btc8723b1ant_action_wifi_not_conn_scan(btcoexist);
>   		else	/* wifi is connected */
>   			btc8723b1ant_action_wifi_conn_scan(btcoexist);
>   	} else if (BTC_SCAN_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN FINISH notify\n");
>   		if (!wifi_connected)	/* non-connected scan */
>   			btc8723b1ant_action_wifi_not_conn(btcoexist);
>   		else
> @@ -2802,12 +2789,12 @@ void ex_halbtc8723b1ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
>   	}
>
>   	if (BTC_ASSOCIATE_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT START notify\n");
>   		btc8723b1ant_act_wifi_not_conn_asso_auth(btcoexist);
>   	} else if (BTC_ASSOCIATE_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT FINISH notify\n");
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
>   				   &wifi_connected);
> @@ -2830,11 +2817,11 @@ void ex_halbtc8723b1ant_media_status_notify(struct btc_coexist *btcoexist,
>   		return;
>
>   	if (BTC_MEDIA_CONNECT == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA connect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA connect notify\n");
>   	else
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA disconnect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA disconnect notify\n");
>
>   	/* only 2.4G we need to inform bt the chnl mask */
>   	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
> @@ -2855,10 +2842,10 @@ void ex_halbtc8723b1ant_media_status_notify(struct btc_coexist *btcoexist,
>   	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
>   	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x66 = 0x%x\n",
> -		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> -		  h2c_parameter[2]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x66 = 0x%x\n",
> +		    h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> +		    h2c_parameter[2]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>   }
> @@ -2900,8 +2887,8 @@ void ex_halbtc8723b1ant_special_packet_notify(struct btc_coexist *btcoexist,
>
>   	if (BTC_PACKET_DHCP == type ||
>   	    BTC_PACKET_EAPOL == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], special Packet(%d) notify\n", type);
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], special Packet(%d) notify\n", type);
>   		halbtc8723b1ant_action_wifi_connected_special_packet(btcoexist);
>   	}
>   }
> @@ -2921,19 +2908,19 @@ void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		rsp_source = BT_INFO_SRC_8723B_1ANT_WIFI_FW;
>   	coex_sta->bt_info_c2h_cnt[rsp_source]++;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Bt info[%d], length=%d, hex data = [",
> -		  rsp_source, length);
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Bt info[%d], length=%d, hex data = [",
> +		      rsp_source, length);
>   	for (i = 0; i < length; i++) {
>   		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
>   		if (i == 1)
>   			bt_info = tmp_buf[i];
>   		if (i == length - 1)
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x]\n", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x]\n", tmp_buf[i]);
>   		else
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x, ", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x, ", tmp_buf[i]);
>   	}
>
>   	if (BT_INFO_SRC_8723B_1ANT_WIFI_FW != rsp_source) {
> @@ -2950,8 +2937,8 @@ void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		 * because bt is reset and loss of the info.
>   		 */
>   		if (coex_sta->bt_info_ext & BIT1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
>   			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
>   					   &wifi_connected);
>   			if (wifi_connected)
> @@ -2965,8 +2952,8 @@ void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		if (coex_sta->bt_info_ext & BIT3) {
>   			if (!btcoexist->manual_control &&
>   			    !btcoexist->stop_coex_dm) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT ext info bit3 check, set BT NOT ignore Wlan active!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT ext info bit3 check, set BT NOT ignore Wlan active!!\n");
>   				halbtc8723b1ant_ignore_wlan_act(btcoexist,
>   								FORCE_EXEC,
>   								false);
> @@ -3021,30 +3008,30 @@ void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   	if (!(bt_info&BT_INFO_8723B_1ANT_B_CONNECTION)) {
>   		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Non-Connected idle!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Connected idle!\n");
>   	/* connection exists but no busy */
>   	} else if (bt_info == BT_INFO_8723B_1ANT_B_CONNECTION) {
>   		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
>   	} else if ((bt_info & BT_INFO_8723B_1ANT_B_SCO_ESCO) ||
>   		(bt_info & BT_INFO_8723B_1ANT_B_SCO_BUSY)) {
>   		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_SCO_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
>   	} else if (bt_info & BT_INFO_8723B_1ANT_B_ACL_BUSY) {
>   		if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY != coex_dm->bt_status)
>   			coex_dm->auto_tdma_adjust = false;
>
>   		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_ACL_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
>   	} else {
>   		coex_dm->bt_status =
>   			BT_8723B_1ANT_BT_STATUS_MAX;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Non-Defined state!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Defined state!!\n");
>   	}
>
>   	if ((BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
> @@ -3060,7 +3047,7 @@ void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   void ex_halbtc8723b1ant_halt_notify(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
> +	btc_iface_dbg(INTF_NOTIFY, "[BTCoex], Halt notify\n");
>
>   	btcoexist->stop_coex_dm = true;
>
> @@ -3078,11 +3065,11 @@ void ex_halbtc8723b1ant_halt_notify(struct btc_coexist *btcoexist)
>
>   void ex_halbtc8723b1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Pnp notify\n");
> +	btc_iface_dbg(INTF_NOTIFY, "[BTCoex], Pnp notify\n");
>
>   	if (BTC_WIFI_PNP_SLEEP == pnp_state) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], Pnp notify to SLEEP\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], Pnp notify to SLEEP\n");
>   		btcoexist->stop_coex_dm = true;
>   		halbtc8723b1ant_SetAntPath(btcoexist, BTC_ANT_PATH_BT, false,
>   					   true);
> @@ -3092,8 +3079,8 @@ void ex_halbtc8723b1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
>   		halbtc8723b1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
>   		halbtc8723b1ant_wifi_off_hw_cfg(btcoexist);
>   	} else if (BTC_WIFI_PNP_WAKE_UP == pnp_state) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], Pnp notify to WAKE UP\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], Pnp notify to WAKE UP\n");
>   		btcoexist->stop_coex_dm = false;
>   		halbtc8723b1ant_init_hw_config(btcoexist, false);
>   		halbtc8723b1ant_init_coex_dm(btcoexist);
> @@ -3103,8 +3090,8 @@ void ex_halbtc8723b1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
>
>   void ex_halbtc8723b1ant_coex_dm_reset(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], *****************Coex DM Reset****************\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], *****************Coex DM Reset****************\n");
>
>   	halbtc8723b1ant_init_hw_config(btcoexist, false);
>   	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
> @@ -3119,31 +3106,31 @@ void ex_halbtc8723b1ant_periodical(struct btc_coexist *btcoexist)
>   	static u8 dis_ver_info_cnt;
>   	u32 fw_ver = 0, bt_patch_ver = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], ==========================Periodical===========================\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], ==========================Periodical===========================\n");
>
>   	if (dis_ver_info_cnt <= 5) {
>   		dis_ver_info_cnt += 1;
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> -			  board_info->pg_ant_num, board_info->btdm_ant_num,
> -			  board_info->btdm_ant_pos);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> -			  ((stack_info->profile_notified) ? "Yes" : "No"),
> -			  stack_info->hci_version);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> +			      board_info->pg_ant_num, board_info->btdm_ant_num,
> +			      board_info->btdm_ant_pos);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> +			      stack_info->profile_notified ? "Yes" : "No",
> +			      stack_info->hci_version);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>   				   &bt_patch_ver);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> -			  glcoex_ver_date_8723b_1ant,
> -			  glcoex_ver_8723b_1ant, fw_ver,
> -			  bt_patch_ver, bt_patch_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> +			      glcoex_ver_date_8723b_1ant,
> +			      glcoex_ver_8723b_1ant, fw_ver,
> +			      bt_patch_ver, bt_patch_ver);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
>   	}
>
>   #if (BT_AUTO_REPORT_ONLY_8723B_1ANT == 0)
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
> index c43ab59..6e944ca 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
> @@ -72,32 +72,28 @@ static u8 btc8723b2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh +
>   				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "[BTCoex], BT Rssi thresh error!!\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "[BTCoex], BT Rssi thresh error!!\n");
>   			return coex_sta->pre_bt_rssi_state;
>   		}
>
> @@ -106,14 +102,12 @@ static u8 btc8723b2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh +
>   				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_bt_rssi_state ==
>   						BTC_RSSI_STATE_MEDIUM) ||
> @@ -122,31 +116,26 @@ static u8 btc8723b2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= rssi_thresh1 +
>   				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "stay at Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Medium\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh1) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state "
> -					  "stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	}
> @@ -173,36 +162,28 @@ static u8 btc8723b2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh +
>   					 BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
> -				  "[BTCoex], wifi RSSI thresh error!!\n");
> +			btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +				    "[BTCoex], wifi RSSI thresh error!!\n");
>   			return coex_sta->pre_wifi_rssi_state[index];
>   		}
>
> @@ -213,16 +194,12 @@ static u8 btc8723b2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
>   						BTC_RSSI_STATE_MEDIUM) ||
> @@ -231,36 +208,26 @@ static u8 btc8723b2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= rssi_thresh1 +
>   					 BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "stay at Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Medium\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh1) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state "
> -					  "stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	}
> @@ -292,12 +259,12 @@ static void btc8723b2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
>   	coex_sta->low_priority_tx = reg_lp_tx;
>   	coex_sta->low_priority_rx = reg_lp_rx;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], High Priority Tx/Rx(reg 0x%x)=0x%x(%d)/0x%x(%d)\n",
> -		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], Low Priority Tx/Rx(reg 0x%x)=0x%x(%d)/0x%x(%d)\n",
> -		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], High Priority Tx/Rx(reg 0x%x)=0x%x(%d)/0x%x(%d)\n",
> +		    reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], Low Priority Tx/Rx(reg 0x%x)=0x%x(%d)/0x%x(%d)\n",
> +		    reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
>
>   	/* reset counter */
>   	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
> @@ -311,9 +278,9 @@ static void btc8723b2ant_query_bt_info(struct btc_coexist *btcoexist)
>
>   	h2c_parameter[0] |= BIT0;	/* trigger */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
>   }
> @@ -427,8 +394,8 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>
>   	if (!bt_link_info->bt_link_exist) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], No BT link exists!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], No BT link exists!!!\n");
>   		return algorithm;
>   	}
>
> @@ -443,27 +410,27 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>
>   	if (num_of_diff_profile == 1) {
>   		if (bt_link_info->sco_exist) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], SCO only\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], SCO only\n");
>   			algorithm = BT_8723B_2ANT_COEX_ALGO_SCO;
>   		} else {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], HID only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], HID only\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], A2DP only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], A2DP only\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_A2DP;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], PAN(HS) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], PAN(HS) only\n");
>   					algorithm =
>   						BT_8723B_2ANT_COEX_ALGO_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], PAN(EDR) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], PAN(EDR) only\n");
>   					algorithm =
>   						BT_8723B_2ANT_COEX_ALGO_PANEDR;
>   				}
> @@ -472,21 +439,21 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   	} else if (num_of_diff_profile == 2) {
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + HID\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + A2DP ==> SCO\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + A2DP ==> SCO\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + PAN(HS)\n");
>   					algorithm = BT_8723B_2ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -494,31 +461,31 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   		} else {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], HID + A2DP\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], HID + A2DP\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_HID_A2DP;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + PAN(HS)\n");
>   					algorithm = BT_8723B_2ANT_COEX_ALGO_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_A2DP_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex],A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex],A2DP + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_A2DP;
>   				}
> @@ -528,37 +495,32 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + HID + A2DP"
> -					  " ==> HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + HID + A2DP ==> HID\n");
>   				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + "
> -						  "PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + "
> -						  "PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + PAN(EDR)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + A2DP + "
> -						  "PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + A2DP + "
> -						  "PAN(EDR) ==> HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + A2DP + PAN(EDR) ==> HID\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -568,15 +530,13 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + A2DP + "
> -						  "PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + A2DP + PAN(HS)\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + A2DP + "
> -						  "PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + A2DP + PAN(EDR)\n");
>   					algorithm =
>   					BT_8723B_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				}
> @@ -588,13 +548,11 @@ static u8 btc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], Error!!! SCO + HID"
> -						  " + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], Error!!! SCO + HID + A2DP + PAN(HS)\n");
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + A2DP +"
> -						  " PAN(EDR)==>PAN(EDR)+HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
>   					algorithm =
>   					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
> @@ -624,17 +582,15 @@ static bool btc8723b_need_dec_pwr(struct btc_coexist *btcoexist)
>   	if (wifi_connected) {
>   		if (bt_hs_on) {
>   			if (bt_hs_rssi > 37) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -					  "[BTCoex], Need to decrease bt "
> -					  "power for HS mode!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW,
> +					    "[BTCoex], Need to decrease bt power for HS mode!!\n");
>   				ret = true;
>   			}
>   		} else {
>   			if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
>   			    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -					  "[BTCoex], Need to decrease bt "
> -					  "power for Wifi is connected!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW,
> +					    "[BTCoex], Need to decrease bt power for Wifi is connected!!\n");
>   				ret = true;
>   			}
>   		}
> @@ -653,10 +609,10 @@ static void btc8723b2ant_set_fw_dac_swing_level(struct btc_coexist *btcoexist,
>   	 */
>   	h2c_parameter[0] = dac_swing_lvl;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Set Dac Swing Level=0x%x\n", dac_swing_lvl);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x64=0x%x\n", h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Set Dac Swing Level=0x%x\n", dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x64=0x%x\n", h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
>   }
> @@ -671,9 +627,9 @@ static void btc8723b2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
>   	if (dec_bt_pwr)
>   		h2c_parameter[0] |= BIT1;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], decrease Bt Power : %s, FW write 0x62=0x%x\n",
> -		  (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], decrease Bt Power : %s, FW write 0x62=0x%x\n",
> +		    (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
>   }
> @@ -681,15 +637,15 @@ static void btc8723b2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
>   				    bool force_exec, bool dec_bt_pwr)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s Dec BT power = %s\n",
> -		  (force_exec ? "force to" : ""), (dec_bt_pwr ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s Dec BT power = %s\n",
> +		    force_exec ? "force to" : "", dec_bt_pwr ? "ON" : "OFF");
>   	coex_dm->cur_dec_bt_pwr = dec_bt_pwr;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPreDecBtPwr=%d, bCurDecBtPwr=%d\n",
> -			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPreDecBtPwr=%d, bCurDecBtPwr=%d\n",
> +			    coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
>
>   		if (coex_dm->pre_dec_bt_pwr == coex_dm->cur_dec_bt_pwr)
>   			return;
> @@ -702,17 +658,16 @@ static void btc8723b2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_fw_dac_swing_lvl(struct btc_coexist *btcoexist,
>   					  bool force_exec, u8 fw_dac_swing_lvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s set FW Dac Swing level = %d\n",
> -		  (force_exec ? "force to" : ""), fw_dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s set FW Dac Swing level = %d\n",
> +		    (force_exec ? "force to" : ""), fw_dac_swing_lvl);
>   	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swing_lvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], preFwDacSwingLvl=%d, "
> -			  "curFwDacSwingLvl=%d\n",
> -			  coex_dm->pre_fw_dac_swing_lvl,
> -			  coex_dm->cur_fw_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], preFwDacSwingLvl=%d, curFwDacSwingLvl=%d\n",
> +			    coex_dm->pre_fw_dac_swing_lvl,
> +			    coex_dm->cur_fw_dac_swing_lvl);
>
>   		if (coex_dm->pre_fw_dac_swing_lvl ==
>   		   coex_dm->cur_fw_dac_swing_lvl)
> @@ -729,16 +684,16 @@ static void btc8723b2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   {
>   	if (rx_rf_shrink_on) {
>   		/* Shrink RF Rx LPF corner */
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Shrink RF Rx LPF corner!!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
>   					  0xfffff, 0xffffc);
>   	} else {
>   		/* Resume RF Rx LPF corner */
>   		/* After initialized, we can use coex_dm->btRf0x1eBackup */
>   		if (btcoexist->initilized) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -				  "[BTCoex], Resume RF Rx LPF corner!!\n");
> +			btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +				    "[BTCoex], Resume RF Rx LPF corner!!\n");
>   			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
>   						  0xfffff,
>   						  coex_dm->bt_rf0x1e_backup);
> @@ -749,18 +704,17 @@ static void btc8723b2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_rf_shrink(struct btc_coexist *btcoexist,
>   				   bool force_exec, bool rx_rf_shrink_on)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
> -		  (force_exec ? "force to" : ""), (rx_rf_shrink_on ?
> -		  "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn Rx RF Shrink = %s\n",
> +		    (force_exec ? "force to" : ""), (rx_rf_shrink_on ?
> +						     "ON" : "OFF"));
>   	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreRfRxLpfShrink=%d, "
> -			  "bCurRfRxLpfShrink=%d\n",
> -			  coex_dm->pre_rf_rx_lpf_shrink,
> -			  coex_dm->cur_rf_rx_lpf_shrink);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreRfRxLpfShrink=%d, bCurRfRxLpfShrink=%d\n",
> +			    coex_dm->pre_rf_rx_lpf_shrink,
> +			    coex_dm->cur_rf_rx_lpf_shrink);
>
>   		if (coex_dm->pre_rf_rx_lpf_shrink ==
>   		    coex_dm->cur_rf_rx_lpf_shrink)
> @@ -788,9 +742,9 @@ static void btc8723b_set_penalty_txrate(struct btc_coexist *btcoexist,
>   		h2c_parameter[5] = 0xf9;  /*MCS5 or OFDM36*/
>   	}
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
> -		  (low_penalty_ra ? "ON!!" : "OFF!!"));
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set WiFi Low-Penalty Retry: %s",
> +		    (low_penalty_ra ? "ON!!" : "OFF!!"));
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
>   }
> @@ -799,18 +753,17 @@ static void btc8723b2ant_low_penalty_ra(struct btc_coexist *btcoexist,
>   					bool force_exec, bool low_penalty_ra)
>   {
>   	/*return; */
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn LowPenaltyRA = %s\n",
> -		  (force_exec ? "force to" : ""), (low_penalty_ra ?
> -		  "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn LowPenaltyRA = %s\n",
> +		    (force_exec ? "force to" : ""), (low_penalty_ra ?
> +						     "ON" : "OFF"));
>   	coex_dm->cur_low_penalty_ra = low_penalty_ra;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreLowPenaltyRa=%d, "
> -			  "bCurLowPenaltyRa=%d\n",
> -			  coex_dm->pre_low_penalty_ra,
> -			  coex_dm->cur_low_penalty_ra);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreLowPenaltyRa=%d, bCurLowPenaltyRa=%d\n",
> +			    coex_dm->pre_low_penalty_ra,
> +			    coex_dm->cur_low_penalty_ra);
>
>   		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
>   			return;
> @@ -824,8 +777,8 @@ static void btc8723b2ant_set_dac_swing_reg(struct btc_coexist *btcoexist,
>   					   u32 level)
>   {
>   	u8 val = (u8) level;
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], Write SwDacSwing = 0x%x\n", level);
>   	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x883, 0x3e, val);
>   }
>
> @@ -843,20 +796,20 @@ static void btc8723b2ant_dac_swing(struct btc_coexist *btcoexist,
>   				   bool force_exec, bool dac_swing_on,
>   				   u32 dac_swing_lvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn DacSwing=%s, dac_swing_lvl=0x%x\n",
> -		  (force_exec ? "force to" : ""),
> -		  (dac_swing_on ? "ON" : "OFF"), dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn DacSwing=%s, dac_swing_lvl=0x%x\n",
> +		    (force_exec ? "force to" : ""),
> +		    (dac_swing_on ? "ON" : "OFF"), dac_swing_lvl);
>   	coex_dm->cur_dac_swing_on = dac_swing_on;
>   	coex_dm->cur_dac_swing_lvl = dac_swing_lvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreDacSwingOn=%d, preDacSwingLvl=0x%x,"
> -			  " bCurDacSwingOn=%d, curDacSwingLvl=0x%x\n",
> -			  coex_dm->pre_dac_swing_on, coex_dm->pre_dac_swing_lvl,
> -			  coex_dm->cur_dac_swing_on,
> -			  coex_dm->cur_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreDacSwingOn=%d, preDacSwingLvl=0x%x, bCurDacSwingOn=%d, curDacSwingLvl=0x%x\n",
> +			    coex_dm->pre_dac_swing_on,
> +			    coex_dm->pre_dac_swing_lvl,
> +			    coex_dm->cur_dac_swing_on,
> +			    coex_dm->cur_dac_swing_lvl);
>
>   		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
>   		    (coex_dm->pre_dac_swing_lvl == coex_dm->cur_dac_swing_lvl))
> @@ -877,8 +830,8 @@ static void btc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
>
>   	/*  BB AGC Gain Table */
>   	if (agc_table_en) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB Agc Table On!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB Agc Table On!\n");
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6e1A0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6d1B0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6c1C0001);
> @@ -887,8 +840,8 @@ static void btc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x691F0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x68200001);
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB Agc Table Off!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB Agc Table Off!\n");
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xaa1A0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa91B0001);
>   		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa81C0001);
> @@ -901,15 +854,15 @@ static void btc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
>   	/* RF Gain */
>   	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xef, 0xfffff, 0x02000);
>   	if (agc_table_en) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Agc Table On!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Agc Table On!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
>   					  0xfffff, 0x38fff);
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
>   					  0xfffff, 0x38ffe);
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Agc Table Off!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Agc Table Off!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
>   					  0xfffff, 0x380c3);
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
> @@ -920,15 +873,15 @@ static void btc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
>   	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xed, 0xfffff, 0x1);
>
>   	if (agc_table_en) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Agc Table On!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Agc Table On!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
>   					  0xfffff, 0x38fff);
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
>   					  0xfffff, 0x38ffe);
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Agc Table Off!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Agc Table Off!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
>   					  0xfffff, 0x380c3);
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
> @@ -946,16 +899,17 @@ static void btc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_agc_table(struct btc_coexist *btcoexist,
>   				   bool force_exec, bool agc_table_en)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s %s Agc Table\n",
> -		  (force_exec ? "force to" : ""),
> -		  (agc_table_en ? "Enable" : "Disable"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s %s Agc Table\n",
> +		    (force_exec ? "force to" : ""),
> +		    (agc_table_en ? "Enable" : "Disable"));
>   	coex_dm->cur_agc_table_en = agc_table_en;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], bPreAgcTableEn=%d, bCurAgcTableEn=%d\n",
> -			  coex_dm->pre_agc_table_en, coex_dm->cur_agc_table_en);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], bPreAgcTableEn=%d, bCurAgcTableEn=%d\n",
> +			    coex_dm->pre_agc_table_en,
> +			    coex_dm->cur_agc_table_en);
>
>   		if (coex_dm->pre_agc_table_en == coex_dm->cur_agc_table_en)
>   			return;
> @@ -969,20 +923,20 @@ static void btc8723b2ant_set_coex_table(struct btc_coexist *btcoexist,
>   					u32 val0x6c0, u32 val0x6c4,
>   					u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c0=0x%x\n", val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c0=0x%x\n", val0x6c0);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c4=0x%x\n", val0x6c4);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c4=0x%x\n", val0x6c4);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c8=0x%x\n", val0x6c8);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c8=0x%x\n", val0x6c8);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6cc=0x%x\n", val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6cc=0x%x\n", val0x6cc);
>   	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
>   }
>
> @@ -991,29 +945,24 @@ static void btc8723b2ant_coex_table(struct btc_coexist *btcoexist,
>   				    u32 val0x6c4, u32 val0x6c8,
>   				    u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s write Coex Table 0x6c0=0x%x,"
> -		  " 0x6c4=0x%x, 0x6c8=0x%x, 0x6cc=0x%x\n",
> -		  (force_exec ? "force to" : ""), val0x6c0,
> -		  val0x6c4, val0x6c8, val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s write Coex Table 0x6c0=0x%x, 0x6c4=0x%x, 0x6c8=0x%x, 0x6cc=0x%x\n",
> +		    force_exec ? "force to" : "",
> +		    val0x6c0, val0x6c4, val0x6c8, val0x6cc);
>   	coex_dm->cur_val0x6c0 = val0x6c0;
>   	coex_dm->cur_val0x6c4 = val0x6c4;
>   	coex_dm->cur_val0x6c8 = val0x6c8;
>   	coex_dm->cur_val0x6cc = val0x6cc;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], preVal0x6c0=0x%x, "
> -			  "preVal0x6c4=0x%x, preVal0x6c8=0x%x, "
> -			  "preVal0x6cc=0x%x !!\n",
> -			  coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4,
> -			  coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], curVal0x6c0=0x%x, "
> -			  "curVal0x6c4=0x%x, curVal0x6c8=0x%x, "
> -			  "curVal0x6cc=0x%x !!\n",
> -			  coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4,
> -			  coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], preVal0x6c0=0x%x, preVal0x6c4=0x%x, preVal0x6c8=0x%x, preVal0x6cc=0x%x !!\n",
> +			    coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4,
> +			    coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], curVal0x6c0=0x%x, curVal0x6c4=0x%x, curVal0x6c8=0x%x, curVal0x6cc=0x%x !!\n",
> +			    coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4,
> +			    coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
>
>   		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
>   		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
> @@ -1099,9 +1048,9 @@ static void btc8723b2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
>   	if (enable)
>   		h2c_parameter[0] |= BIT0;/* function enable*/
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set FW for BT Ignore Wlan_Act, "
> -		  "FW write 0x63=0x%x\n", h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63=0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
>   }
> @@ -1109,17 +1058,16 @@ static void btc8723b2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
>   					 bool force_exec, bool enable)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn Ignore WlanAct %s\n",
> -		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn Ignore WlanAct %s\n",
> +		    (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
>   	coex_dm->cur_ignore_wlan_act = enable;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPreIgnoreWlanAct = %d, "
> -			  "bCurIgnoreWlanAct = %d!!\n",
> -			  coex_dm->pre_ignore_wlan_act,
> -			  coex_dm->cur_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPreIgnoreWlanAct = %d, bCurIgnoreWlanAct = %d!!\n",
> +			    coex_dm->pre_ignore_wlan_act,
> +			    coex_dm->cur_ignore_wlan_act);
>
>   		if (coex_dm->pre_ignore_wlan_act ==
>   		    coex_dm->cur_ignore_wlan_act)
> @@ -1147,11 +1095,11 @@ static void btc8723b2ant_set_fw_ps_tdma(struct btc_coexist *btcoexist, u8 byte1,
>   	coex_dm->ps_tdma_para[3] = byte4;
>   	coex_dm->ps_tdma_para[4] = byte5;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x60(5bytes)=0x%x%08x\n",
> -		  h2c_parameter[0],
> -		  h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
> -		  h2c_parameter[3] << 8 | h2c_parameter[4]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x60(5bytes)=0x%x%08x\n",
> +		    h2c_parameter[0],
> +		    h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
> +		    h2c_parameter[3] << 8 | h2c_parameter[4]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
>   }
> @@ -1255,20 +1203,20 @@ static void btc8723b2ant_set_ant_path(struct btc_coexist *btcoexist,
>   static void btc8723b2ant_ps_tdma(struct btc_coexist *btcoexist, bool force_exec,
>   				 bool turn_on, u8 type)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn %s PS TDMA, type=%d\n",
> -		  (force_exec ? "force to" : ""),
> -		  (turn_on ? "ON" : "OFF"), type);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn %s PS TDMA, type=%d\n",
> +		    (force_exec ? "force to" : ""),
> +		    (turn_on ? "ON" : "OFF"), type);
>   	coex_dm->cur_ps_tdma_on = turn_on;
>   	coex_dm->cur_ps_tdma = type;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
> -			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
> -			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
> +			    coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
> +			    coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
>
>   		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
>   		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
> @@ -1466,8 +1414,8 @@ static bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
>   		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
>   				   &low_pwr_disable);
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non-connected idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non-connected idle!!\n");
>
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff,
>   					  0x0);
> @@ -1490,9 +1438,8 @@ static bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
>   					   BTC_SET_ACT_DISABLE_LOW_POWER,
>   					   &low_pwr_disable);
>
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi connected + "
> -				  "BT non connected-idle!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi connected + BT non connected-idle!!\n");
>
>   			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
>   						  0xfffff, 0x0);
> @@ -1518,9 +1465,8 @@ static bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
>
>   			if (bt_hs_on)
>   				return false;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi connected + "
> -				  "BT connected-idle!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi connected + BT connected-idle!!\n");
>
>   			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
>   						  0xfffff, 0x0);
> @@ -1544,17 +1490,15 @@ static bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
>   					   &low_pwr_disable);
>
>   			if (wifi_busy) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], Wifi Connected-Busy + "
> -					  "BT Busy!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
>   				common = false;
>   			} else {
>   				if (bt_hs_on)
>   					return false;
>
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], Wifi Connected-Idle + "
> -					  "BT Busy!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
>
>   				btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A,
>   							  0x1, 0xfffff, 0x0);
> @@ -1592,9 +1536,8 @@ static void set_tdma_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   {
>   	/* Set PS TDMA for max interval == 1 */
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>
>   		if (coex_dm->cur_ps_tdma == 71) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC,
> @@ -1690,9 +1633,8 @@ static void set_tdma_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 71);
>   			coex_dm->tdma_adj_type = 71;
> @@ -1790,9 +1732,8 @@ static void set_tdma_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   {
>   	/* Set PS TDMA for max interval == 2 */
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 6);
>   			coex_dm->tdma_adj_type = 6;
> @@ -1873,9 +1814,8 @@ static void set_tdma_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
>   			coex_dm->tdma_adj_type = 2;
> @@ -1963,9 +1903,8 @@ static void set_tdma_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   {
>   	/* Set PS TDMA for max interval == 3 */
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 7);
>   			coex_dm->tdma_adj_type = 7;
> @@ -2046,9 +1985,8 @@ static void set_tdma_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM,
> -			  ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
>   			coex_dm->tdma_adj_type = 3;
> @@ -2140,13 +2078,13 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	s32 result;
>   	u8 retry_count = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], TdmaDurationAdjust()\n");
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], TdmaDurationAdjust()\n");
>
>   	if (!coex_dm->auto_tdma_adjust) {
>   		coex_dm->auto_tdma_adjust = true;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], first run TdmaDurationAdjust()!!\n");
>   		if (sco_hid) {
>   			if (tx_pause) {
>   				if (max_interval == 1) {
> @@ -2250,11 +2188,11 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	} else {
>   		/*accquire the BT TRx retry count from BT_Info byte2*/
>   		retry_count = coex_sta->bt_retry_cnt;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], retry_count = %d\n", retry_count);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], up=%d, dn=%d, m=%d, n=%d, wait_count=%d\n",
> -			  up, dn, m, n, wait_count);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], retry_count = %d\n", retry_count);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], up=%d, dn=%d, m=%d, n=%d, wait_count=%d\n",
> +			    up, dn, m, n, wait_count);
>   		result = 0;
>   		wait_count++;
>   		 /* no retry in the last 2-second duration*/
> @@ -2271,10 +2209,8 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   				up = 0;
>   				dn = 0;
>   				result = 1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Increase wifi "
> -					  "duration!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Increase wifi duration!!\n");
>   			} /* <=3 retry in the last 2-second duration*/
>   		} else if (retry_count <= 3) {
>   			up--;
> @@ -2297,10 +2233,8 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   				dn = 0;
>   				wait_count = 0;
>   				result = -1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Decrease wifi duration "
> -					  "for retry_counter<3!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Decrease wifi duration for retry_counter<3!!\n");
>   			}
>   		} else {
>   			if (wait_count == 1)
> @@ -2316,13 +2250,12 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   			dn = 0;
>   			wait_count = 0;
>   			result = -1;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], Decrease wifi duration "
> -				  "for retry_counter>3!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], Decrease wifi duration for retry_counter>3!!\n");
>   		}
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], max Interval = %d\n", max_interval);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], max Interval = %d\n", max_interval);
>   		if (max_interval == 1)
>   			set_tdma_int1(btcoexist, tx_pause, result);
>   		else if (max_interval == 2)
> @@ -2336,10 +2269,9 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   	 */
>   	if (coex_dm->cur_ps_tdma != coex_dm->tdma_adj_type) {
>   		bool scan = false, link = false, roam = false;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], PsTdma type dismatch!!!, "
> -			  "curPsTdma=%d, recordPsTdma=%d\n",
> -			  coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], PsTdma type dismatch!!!, curPsTdma=%d, recordPsTdma=%d\n",
> +			    coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
> @@ -2349,9 +2281,8 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
>   			btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true,
>   					     coex_dm->tdma_adj_type);
>   		else
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], roaming/link/scan is under"
> -				  " progress, will adjust next time!!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
>   	}
>   }
>
> @@ -2989,27 +2920,26 @@ static void btc8723b2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   {
>   	u8 algorithm = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], RunCoexistMechanism()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], RunCoexistMechanism()===>\n");
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), "
> -			  "return for Manual CTRL <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
>   		return;
>   	}
>
>   	if (coex_sta->under_ips) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is under IPS !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is under IPS !!!\n");
>   		return;
>   	}
>
>   	algorithm = btc8723b2ant_action_algorithm(btcoexist);
>   	if (coex_sta->c2h_bt_inquiry_page &&
>   	    (BT_8723B_2ANT_COEX_ALGO_PANHS != algorithm)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BT is under inquiry/page scan !!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BT is under inquiry/page scan !!\n");
>   		btc8723b2ant_action_bt_inquiry(btcoexist);
>   		return;
>   	} else {
> @@ -3021,84 +2951,75 @@ static void btc8723b2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	}
>
>   	coex_dm->cur_algorithm = algorithm;
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Algorithm = %d\n",
> -		  coex_dm->cur_algorithm);
> +	btc_alg_dbg(ALGO_TRACE, "[BTCoex], Algorithm = %d\n",
> +		    coex_dm->cur_algorithm);
>
>   	if (btc8723b2ant_is_common_action(btcoexist)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Action 2-Ant common.\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Action 2-Ant common\n");
>   		coex_dm->auto_tdma_adjust = false;
>   	} else {
>   		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], preAlgorithm=%d, "
> -				  "curAlgorithm=%d\n", coex_dm->pre_algorithm,
> -				  coex_dm->cur_algorithm);
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], preAlgorithm=%d, curAlgorithm=%d\n",
> +				    coex_dm->pre_algorithm,
> +				    coex_dm->cur_algorithm);
>   			coex_dm->auto_tdma_adjust = false;
>   		}
>   		switch (coex_dm->cur_algorithm) {
>   		case BT_8723B_2ANT_COEX_ALGO_SCO:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = SCO.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = SCO\n");
>   			btc8723b2ant_action_sco(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID\n");
>   			btc8723b2ant_action_hid(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = A2DP\n");
>   			btc8723b2ant_action_a2dp(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_A2DP_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = A2DP+PAN(HS).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = A2DP+PAN(HS)\n");
>   			btc8723b2ant_action_a2dp_pan_hs(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)\n");
>   			btc8723b2ant_action_pan_edr(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = HS mode.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HS mode\n");
>   			btc8723b2ant_action_pan_hs(btcoexist);
>   				break;
>   		case BT_8723B_2ANT_COEX_ALGO_PANEDR_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = PAN+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN+A2DP\n");
>   			btc8723b2ant_action_pan_edr_a2dp(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_PANEDR_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = PAN(EDR)+HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)+HID\n");
>   			btc8723b2ant_action_pan_edr_hid(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = HID+A2DP+PAN.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID+A2DP+PAN\n");
>   			btc8723b2ant_action_hid_a2dp_pan_edr(btcoexist);
>   			break;
>   		case BT_8723B_2ANT_COEX_ALGO_HID_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = HID+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID+A2DP\n");
>   			btc8723b2ant_action_hid_a2dp(btcoexist);
>   			break;
>   		default:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, "
> -				  "algorithm = coexist All Off!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = coexist All Off!!\n");
>   			btc8723b2ant_coex_alloff(btcoexist);
>   			break;
>   		}
> @@ -3126,8 +3047,8 @@ void ex_btc8723b2ant_init_hwconfig(struct btc_coexist *btcoexist)
>   {
>   	u8 u8tmp = 0;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], 2Ant Init HW Config!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], 2Ant Init HW Config!!\n");
>   	coex_dm->bt_rf0x1e_backup =
>   		btcoexist->btc_get_rf_reg(btcoexist, BTC_RF_A, 0x1e, 0xfffff);
>
> @@ -3152,8 +3073,8 @@ void ex_btc8723b2ant_init_hwconfig(struct btc_coexist *btcoexist)
>
>   void ex_btc8723b2ant_init_coex_dm(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], Coex Mechanism Init!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], Coex Mechanism Init!!\n");
>   	btc8723b2ant_init_coex_dm(btcoexist);
>   }
>
> @@ -3388,15 +3309,15 @@ void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist)
>   void ex_btc8723b2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_IPS_ENTER == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS ENTER notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS ENTER notify\n");
>   		coex_sta->under_ips = true;
>   		btc8723b2ant_wifioff_hwcfg(btcoexist);
>   		btc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
>   		btc8723b2ant_coex_alloff(btcoexist);
>   	} else if (BTC_IPS_LEAVE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS LEAVE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS LEAVE notify\n");
>   		coex_sta->under_ips = false;
>   		ex_btc8723b2ant_init_hwconfig(btcoexist);
>   		btc8723b2ant_init_coex_dm(btcoexist);
> @@ -3407,12 +3328,12 @@ void ex_btc8723b2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_btc8723b2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_LPS_ENABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS ENABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS ENABLE notify\n");
>   		coex_sta->under_lps = true;
>   	} else if (BTC_LPS_DISABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS DISABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS DISABLE notify\n");
>   		coex_sta->under_lps = false;
>   	}
>   }
> @@ -3420,21 +3341,21 @@ void ex_btc8723b2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_btc8723b2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_SCAN_START == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN START notify\n");
>   	else if (BTC_SCAN_FINISH == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN FINISH notify\n");
>   }
>
>   void ex_btc8723b2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_ASSOCIATE_START == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT START notify\n");
>   	else if (BTC_ASSOCIATE_FINISH == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT FINISH notify\n");
>   }
>
>   void ex_btc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
> @@ -3445,11 +3366,11 @@ void ex_btc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
>   	u8 wifi_central_chnl;
>
>   	if (BTC_MEDIA_CONNECT == type)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA connect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA connect notify\n");
>   	else
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA disconnect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA disconnect notify\n");
>
>   	/* only 2.4G we need to inform bt the chnl mask */
>   	btcoexist->btc_get(btcoexist,
> @@ -3470,10 +3391,10 @@ void ex_btc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
>   	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
>   	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x66=0x%x\n",
> -		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> -		  h2c_parameter[2]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x66=0x%x\n",
> +		    h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
> +		    h2c_parameter[2]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>   }
> @@ -3482,8 +3403,8 @@ void ex_btc8723b2ant_special_packet_notify(struct btc_coexist *btcoexist,
>   					   u8 type)
>   {
>   	if (type == BTC_PACKET_DHCP)
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], DHCP Packet notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], DHCP Packet notify\n");
>   }
>
>   void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
> @@ -3501,25 +3422,24 @@ void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		rsp_source = BT_INFO_SRC_8723B_2ANT_WIFI_FW;
>   	coex_sta->bt_info_c2h_cnt[rsp_source]++;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Bt info[%d], length=%d, hex data=[",
> -		  rsp_source, length);
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Bt info[%d], length=%d, hex data=[",
> +		      rsp_source, length);
>   	for (i = 0; i < length; i++) {
>   		coex_sta->bt_info_c2h[rsp_source][i] = tmpbuf[i];
>   		if (i == 1)
>   			bt_info = tmpbuf[i];
>   		if (i == length-1)
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x]\n", tmpbuf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x]\n", tmpbuf[i]);
>   		else
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x, ", tmpbuf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x, ", tmpbuf[i]);
>   	}
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), "
> -			  "return for Manual CTRL<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), return for Manual CTRL<===\n");
>   		return;
>   	}
>
> @@ -3537,9 +3457,8 @@ void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		     because bt is reset and loss of the info.
>   		 */
>   		if ((coex_sta->bt_info_ext & BIT1)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT ext info bit1 check,"
> -				  " send wifi BW&Chnl to BT!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
>   			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
>   					   &wifi_connected);
>   			if (wifi_connected)
> @@ -3553,9 +3472,8 @@ void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		}
>
>   		if ((coex_sta->bt_info_ext & BIT3)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT ext info bit3 check, "
> -				  "set BT NOT to ignore Wlan active!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT ext info bit3 check, set BT NOT to ignore Wlan active!!\n");
>   			btc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC,
>   						     false);
>   		} else {
> @@ -3608,28 +3526,26 @@ void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   	if (!(bt_info & BT_INFO_8723B_2ANT_B_CONNECTION)) {
>   		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_NON_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), "
> -			  "BT Non-Connected idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Connected idle!!!\n");
>   	/* connection exists but no busy */
>   	} else if (bt_info == BT_INFO_8723B_2ANT_B_CONNECTION) {
>   		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
>   	} else if ((bt_info & BT_INFO_8723B_2ANT_B_SCO_ESCO) ||
>   		   (bt_info & BT_INFO_8723B_2ANT_B_SCO_BUSY)) {
>   		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_SCO_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
>   	} else if (bt_info&BT_INFO_8723B_2ANT_B_ACL_BUSY) {
>   		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_ACL_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
>   	} else {
>   		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_MAX;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), "
> -			  "BT Non-Defined state!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Defined state!!!\n");
>   	}
>
>   	if ((BT_8723B_2ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
> @@ -3652,7 +3568,7 @@ void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   void ex_btc8723b2ant_halt_notify(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
> +	btc_iface_dbg(INTF_NOTIFY, "[BTCoex], Halt notify\n");
>
>   	btc8723b2ant_wifioff_hwcfg(btcoexist);
>   	btc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
> @@ -3666,33 +3582,31 @@ void ex_btc8723b2ant_periodical(struct btc_coexist *btcoexist)
>   	static u8 dis_ver_info_cnt;
>   	u32 fw_ver = 0, bt_patch_ver = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], =========================="
> -		  "Periodical===========================\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], ==========================Periodical===========================\n");
>
>   	if (dis_ver_info_cnt <= 5) {
>   		dis_ver_info_cnt += 1;
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************"
> -			  "************************************\n");
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], Ant PG Num/ Ant Mech/ "
> -			  "Ant Pos = %d/ %d/ %d\n", board_info->pg_ant_num,
> -			  board_info->btdm_ant_num, board_info->btdm_ant_pos);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> -			  ((stack_info->profile_notified) ? "Yes" : "No"),
> -			  stack_info->hci_version);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> +			      board_info->pg_ant_num,
> +			      board_info->btdm_ant_num,
> +			      board_info->btdm_ant_pos);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> +			      stack_info->profile_notified ? "Yes" : "No",
> +			      stack_info->hci_version);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>   				   &bt_patch_ver);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], CoexVer/ fw_ver/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> -			  glcoex_ver_date_8723b_2ant, glcoex_ver_8723b_2ant,
> -			  fw_ver, bt_patch_ver, bt_patch_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], *****************************"
> -			  "***********************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], CoexVer/ fw_ver/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> +			      glcoex_ver_date_8723b_2ant, glcoex_ver_8723b_2ant,
> +			      fw_ver, bt_patch_ver, bt_patch_ver);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
>   	}
>
>   #if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 0)
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
> index 9cecf17..3ce47c7 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
> @@ -76,28 +76,28 @@ static u8 halbtc8821a1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= (rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "[BTCoex], BT Rssi thresh error!!\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "[BTCoex], BT Rssi thresh error!!\n");
>   			return coex_sta->pre_bt_rssi_state;
>   		}
>
> @@ -106,12 +106,12 @@ static u8 halbtc8821a1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= (rssi_thresh +
>   					BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_bt_rssi_state ==
>   			   BTC_RSSI_STATE_MEDIUM) ||
> @@ -120,26 +120,26 @@ static u8 halbtc8821a1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >= (rssi_thresh1 +
>   					BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Medium\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh1) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	}
> @@ -165,32 +165,28 @@ static u8 halbtc8821a1ant_WifiRssiState(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >=
>   			    (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
> -				  "[BTCoex], wifi RSSI thresh error!!\n");
> +			btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +				    "[BTCoex], wifi RSSI thresh error!!\n");
>   			return coex_sta->pre_wifi_rssi_state[index];
>   		}
>
> @@ -201,14 +197,12 @@ static u8 halbtc8821a1ant_WifiRssiState(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >=
>   			    (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
>   			BTC_RSSI_STATE_MEDIUM) ||
> @@ -218,31 +212,26 @@ static u8 halbtc8821a1ant_WifiRssiState(struct btc_coexist *btcoexist,
>   			    (rssi_thresh1 +
>   			     BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Medium\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh1) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	}
> @@ -431,9 +420,9 @@ static void halbtc8821a1ant_query_bt_info(struct btc_coexist *btcoexist)
>
>   	h2c_parameter[0] |= BIT0;	/* trigger*/
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
>   }
> @@ -504,8 +493,8 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>
>   	if (!bt_link_info->bt_link_exist) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], No BT link exists!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], No BT link exists!!!\n");
>   		return algorithm;
>   	}
>
> @@ -520,26 +509,26 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>
>   	if (num_of_diff_profile == 1) {
>   		if (bt_link_info->sco_exist) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT Profile = SCO only\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT Profile = SCO only\n");
>   			algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
>   		} else {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = HID only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = HID only\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = A2DP only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = A2DP only\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_A2DP;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = PAN(HS) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = PAN(HS) only\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = PAN(EDR) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = PAN(EDR) only\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR;
>   				}
>   			}
> @@ -547,50 +536,50 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>   	} else if (num_of_diff_profile == 2) {
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + HID\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
>   			} else if (bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
>   		} else {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = HID + A2DP\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = HID + A2DP\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
>   			} else if (bt_link_info->hid_exist &&
>   				   bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + PAN(EDR)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				   bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_A2DP_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_A2DP;
>   				}
>   			}
> @@ -599,29 +588,29 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>   		if (bt_link_info->sco_exist) {
>   			if (bt_link_info->hid_exist &&
>   			    bt_link_info->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
>   				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
>   			} else if (bt_link_info->hid_exist &&
>   				bt_link_info->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (bt_link_info->pan_exist &&
>   				bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
> @@ -630,12 +619,12 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				}
>   			}
> @@ -646,12 +635,12 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    bt_link_info->pan_exist &&
>   			    bt_link_info->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
>
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
>   					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
> @@ -670,10 +659,10 @@ static void halbtc8821a1ant_set_bt_auto_report(struct btc_coexist *btcoexist,
>   	if (enable_auto_report)
>   		h2c_parameter[0] |= BIT0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> -		  (enable_auto_report ? "Enabled!!" : "Disabled!!"),
> -		   h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> +		    (enable_auto_report ? "Enabled!!" : "Disabled!!"),
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
>   }
> @@ -682,17 +671,16 @@ static void halbtc8821a1ant_bt_auto_report(struct btc_coexist *btcoexist,
>   					   bool force_exec,
>   					   bool enable_auto_report)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM,
> -		  ALGO_TRACE_FW, "[BTCoex], %s BT Auto report = %s\n",
> -		  (force_exec ? "force to" : ""), ((enable_auto_report) ?
> -		  "Enabled" : "Disabled"));
> +	btc_alg_dbg(ALGO_TRACE_FW, "[BTCoex], %s BT Auto report = %s\n",
> +		    (force_exec ? "force to" : ""), ((enable_auto_report) ?
> +						     "Enabled" : "Disabled"));
>   	coex_dm->cur_bt_auto_report = enable_auto_report;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_bt_auto_report = %d, cur_bt_auto_report = %d\n",
> -			  coex_dm->pre_bt_auto_report,
> -			  coex_dm->cur_bt_auto_report);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_bt_auto_report = %d, cur_bt_auto_report = %d\n",
> +			    coex_dm->pre_bt_auto_report,
> +			    coex_dm->cur_bt_auto_report);
>
>   		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
>   			return;
> @@ -718,9 +706,9 @@ static void btc8821a1ant_set_sw_pen_tx_rate(struct btc_coexist *btcoexist,
>   		h2c_parameter[5] = 0xf9;	/*MCS5 or OFDM36*/
>   	}
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
> -		  (low_penalty_ra ? "ON!!" : "OFF!!"));
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set WiFi Low-Penalty Retry: %s",
> +		    (low_penalty_ra ? "ON!!" : "OFF!!"));
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
>   }
> @@ -743,20 +731,20 @@ static void halbtc8821a1ant_set_coex_table(struct btc_coexist *btcoexist,
>   					   u32 val0x6c0, u32 val0x6c4,
>   					   u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
>   	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
>   }
>
> @@ -764,10 +752,10 @@ static void halbtc8821a1ant_coex_table(struct btc_coexist *btcoexist,
>   				       bool force_exec, u32 val0x6c0,
>   				       u32 val0x6c4, u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> -		  (force_exec ? "force to" : ""), val0x6c0, val0x6c4,
> -		  val0x6c8, val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> +		    (force_exec ? "force to" : ""), val0x6c0, val0x6c4,
> +		    val0x6c8, val0x6cc);
>   	coex_dm->cur_val_0x6c0 = val0x6c0;
>   	coex_dm->cur_val_0x6c4 = val0x6c4;
>   	coex_dm->cur_val_0x6c8 = val0x6c8;
> @@ -839,9 +827,9 @@ static void btc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
>   	if (enable)
>   		h2c_parameter[0] |= BIT0;	/* function enable*/
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
>   }
> @@ -849,16 +837,16 @@ static void btc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
>   static void halbtc8821a1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
>   					    bool force_exec, bool enable)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn Ignore WlanAct %s\n",
> -		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn Ignore WlanAct %s\n",
> +		    (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
>   	coex_dm->cur_ignore_wlan_act = enable;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
> -			  coex_dm->pre_ignore_wlan_act,
> -			  coex_dm->cur_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
> +			    coex_dm->pre_ignore_wlan_act,
> +			    coex_dm->cur_ignore_wlan_act);
>
>   		if (coex_dm->pre_ignore_wlan_act ==
>   		    coex_dm->cur_ignore_wlan_act)
> @@ -887,13 +875,13 @@ static void halbtc8821a1ant_set_fw_pstdma(struct btc_coexist *btcoexist,
>   	coex_dm->ps_tdma_para[3] = byte4;
>   	coex_dm->ps_tdma_para[4] = byte5;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], PS-TDMA H2C cmd =0x%x%08x\n",
> -		  h2c_parameter[0],
> -		  h2c_parameter[1]<<24 |
> -		  h2c_parameter[2]<<16 |
> -		  h2c_parameter[3]<<8 |
> -		  h2c_parameter[4]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], PS-TDMA H2C cmd =0x%x%08x\n",
> +		    h2c_parameter[0],
> +		    h2c_parameter[1] << 24 |
> +		    h2c_parameter[2] << 16 |
> +		    h2c_parameter[3] << 8 |
> +		    h2c_parameter[4]);
>   	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
>   }
>
> @@ -910,22 +898,22 @@ static void halbtc8821a1ant_set_lps_rpwm(struct btc_coexist *btcoexist,
>   static void halbtc8821a1ant_lps_rpwm(struct btc_coexist *btcoexist,
>   				     bool force_exec, u8 lps_val, u8 rpwm_val)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
> -		  (force_exec ? "force to" : ""), lps_val, rpwm_val);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
> +		    (force_exec ? "force to" : ""), lps_val, rpwm_val);
>   	coex_dm->cur_lps = lps_val;
>   	coex_dm->cur_rpwm = rpwm_val;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], LPS-RxBeaconMode = 0x%x, LPS-RPWM = 0x%x!!\n",
> -			  coex_dm->cur_lps, coex_dm->cur_rpwm);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], LPS-RxBeaconMode = 0x%x, LPS-RPWM = 0x%x!!\n",
> +			    coex_dm->cur_lps, coex_dm->cur_rpwm);
>
>   		if ((coex_dm->pre_lps == coex_dm->cur_lps) &&
>   		    (coex_dm->pre_rpwm == coex_dm->cur_rpwm)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], LPS-RPWM_Last = 0x%x, LPS-RPWM_Now = 0x%x!!\n",
> -				  coex_dm->pre_rpwm, coex_dm->cur_rpwm);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], LPS-RPWM_Last = 0x%x, LPS-RPWM_Now = 0x%x!!\n",
> +				    coex_dm->pre_rpwm, coex_dm->cur_rpwm);
>
>   			return;
>   		}
> @@ -939,8 +927,8 @@ static void halbtc8821a1ant_lps_rpwm(struct btc_coexist *btcoexist,
>   static void halbtc8821a1ant_sw_mechanism(struct btc_coexist *btcoexist,
>   					 bool low_penalty_ra)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
>
>   	halbtc8821a1ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
>   }
> @@ -1036,13 +1024,13 @@ static void halbtc8821a1ant_ps_tdma(struct btc_coexist *btcoexist,
>
>   	if (!force_exec) {
>   		if (coex_dm->cur_ps_tdma_on) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], ********** TDMA(on, %d) **********\n",
> -				  coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], ********** TDMA(on, %d) **********\n",
> +				    coex_dm->cur_ps_tdma);
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], ********** TDMA(off, %d) **********\n",
> -				  coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], ********** TDMA(off, %d) **********\n",
> +				    coex_dm->cur_ps_tdma);
>   		}
>   		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
>   		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
> @@ -1253,50 +1241,50 @@ static bool halbtc8821a1ant_is_common_action(struct btc_coexist *btcoexist)
>   	if (!wifi_connected &&
>   	    BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
>   	    coex_dm->bt_status) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
>   		halbtc8821a1ant_sw_mechanism(btcoexist, false);
>
>   		common = true;
>   	} else if (wifi_connected &&
>   		   (BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi connected + BT non connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi connected + BT non connected-idle!!\n");
>   		halbtc8821a1ant_sw_mechanism(btcoexist, false);
>
>   		common = true;
>   	} else if (!wifi_connected &&
>   		   (BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE ==
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
>   		halbtc8821a1ant_sw_mechanism(btcoexist, false);
>
>   		common = true;
>   	} else if (wifi_connected &&
>   		   (BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE ==
>   		   coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi connected + BT connected-idle!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi connected + BT connected-idle!!\n");
>   		halbtc8821a1ant_sw_mechanism(btcoexist, false);
>
>   		common = true;
>   	} else if (!wifi_connected &&
>   		   (BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE !=
>   		    coex_dm->bt_status)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi non connected-idle + BT Busy!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi non connected-idle + BT Busy!!\n");
>   		halbtc8821a1ant_sw_mechanism(btcoexist, false);
>
>   		common = true;
>   	} else {
>   		if (wifi_busy) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
>   		}
>
>   		common = false;
> @@ -1313,8 +1301,8 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   	long			result;
>   	u8			retry_count = 0, bt_info_ext;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], TdmaDurationAdjustForAcl()\n");
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], TdmaDurationAdjustForAcl()\n");
>
>   	if ((BT_8821A_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN ==
>   	     wifi_status) ||
> @@ -1342,8 +1330,8 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>
>   	if (!coex_dm->auto_tdma_adjust) {
>   		coex_dm->auto_tdma_adjust = true;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], first run TdmaDurationAdjust()!!\n");
>
>   		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
>   		coex_dm->tdma_adj_type = 2;
> @@ -1378,9 +1366,8 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   				up = 0;
>   				dn = 0;
>   				result = 1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Increase wifi duration!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Increase wifi duration!!\n");
>   			}
>   		} else if (retry_count <= 3) {
>   			/* <=3 retry in the last 2-second duration*/
> @@ -1410,9 +1397,8 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   				dn = 0;
>   				wait_count = 0;
>   				result = -1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
>   			}
>   		} else {
>   			/* retry count > 3, if retry count > 3 happens once,
> @@ -1433,8 +1419,8 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   			dn = 0;
>   			wait_count = 0;
>   			result = -1;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
>   		}
>
>   		if (result == -1) {
> @@ -1479,9 +1465,9 @@ static void btc8821a1ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   			}
>   		} else {
>   			/*no change*/
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], ********** TDMA(on, %d) **********\n",
> -				coex_dm->cur_ps_tdma);
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], ********** TDMA(on, %d) **********\n",
> +				    coex_dm->cur_ps_tdma);
>   		}
>
>   		if (coex_dm->cur_ps_tdma != 1 &&
> @@ -1603,27 +1589,27 @@ static void btc8821a1ant_mon_bt_en_dis(struct btc_coexist *btcoexist)
>   		bt_disabled = false;
>   		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   				   &bt_disabled);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is enabled !!\n");
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is enabled !!\n");
>   	} else {
>   		bt_disable_cnt++;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], bt all counters = 0, %d times!!\n",
> -			  bt_disable_cnt);
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], bt all counters = 0, %d times!!\n",
> +			    bt_disable_cnt);
>   		if (bt_disable_cnt >= 2) {
>   			bt_disabled = true;
>   			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   					   &bt_disabled);
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -				  "[BTCoex], BT is disabled !!\n");
> +			btc_alg_dbg(ALGO_BT_MONITOR,
> +				    "[BTCoex], BT is disabled !!\n");
>   			halbtc8821a1ant_action_wifi_only(btcoexist);
>   		}
>   	}
>   	if (pre_bt_disabled != bt_disabled) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is from %s to %s!!\n",
> -			(pre_bt_disabled ? "disabled" : "enabled"),
> -			(bt_disabled ? "disabled" : "enabled"));
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is from %s to %s!!\n",
> +			    (pre_bt_disabled ? "disabled" : "enabled"),
> +			    (bt_disabled ? "disabled" : "enabled"));
>   		pre_bt_disabled = bt_disabled;
>   		if (bt_disabled) {
>   			btcoexist->btc_set(btcoexist, BTC_SET_ACT_LEAVE_LPS,
> @@ -1897,15 +1883,15 @@ static void halbtc8821a1ant_action_wifi_connected(struct btc_coexist *btcoexist)
>   	bool	scan = false, link = false, roam = false;
>   	bool	under_4way = false;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], CoexForWifiConnect()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], CoexForWifiConnect()===>\n");
>
>   	btcoexist->btc_get(btcoexist,
>   		 BTC_GET_BL_WIFI_4_WAY_PROGRESS, &under_4way);
>   	if (under_4way) {
>   		btc8821a1ant_act_wifi_conn_sp_pkt(btcoexist);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
>   		return;
>   	}
>
> @@ -1914,8 +1900,8 @@ static void halbtc8821a1ant_action_wifi_connected(struct btc_coexist *btcoexist)
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
>   	if (scan || link || roam) {
>   		halbtc8821a1ant_action_wifi_connected_scan(btcoexist);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
>   		return;
>   	}
>
> @@ -1976,58 +1962,58 @@ static void btc8821a1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
>   	if (!halbtc8821a1ant_is_common_action(btcoexist)) {
>   		switch (coex_dm->cur_algorithm) {
>   		case BT_8821A_1ANT_COEX_ALGO_SCO:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = SCO.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = SCO\n");
>   			halbtc8821a1ant_action_sco(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID\n");
>   			halbtc8821a1ant_action_hid(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = A2DP\n");
>   			halbtc8821a1ant_action_a2dp(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_A2DP_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = A2DP+PAN(HS).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = A2DP+PAN(HS)\n");
>   			halbtc8821a1ant_action_a2dp_pan_hs(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN(EDR)\n");
>   			halbtc8821a1ant_action_pan_edr(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HS mode.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HS mode\n");
>   			halbtc8821a1ant_action_pan_hs(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_PANEDR_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN+A2DP\n");
>   			halbtc8821a1ant_action_pan_edr_a2dp(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_PANEDR_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = PAN(EDR)+HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = PAN(EDR)+HID\n");
>   			halbtc8821a1ant_action_pan_edr_hid(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_HID_A2DP_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID+A2DP+PAN.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID+A2DP+PAN\n");
>   			btc8821a1ant_action_hid_a2dp_pan_edr(btcoexist);
>   			break;
>   		case BT_8821A_1ANT_COEX_ALGO_HID_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = HID+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = HID+A2DP\n");
>   			halbtc8821a1ant_action_hid_a2dp(btcoexist);
>   			break;
>   		default:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action algorithm = coexist All Off!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action algorithm = coexist All Off!!\n");
>   			/*halbtc8821a1ant_coex_all_off(btcoexist);*/
>   			break;
>   		}
> @@ -2045,31 +2031,31 @@ static void halbtc8821a1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	u8	wifi_rssi_state = BTC_RSSI_STATE_HIGH;
>   	bool	wifi_under_5g = false;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], RunCoexistMechanism()===>\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], RunCoexistMechanism()===>\n");
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
>   		return;
>   	}
>
>   	if (btcoexist->stop_coex_dm) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
>   		return;
>   	}
>
>   	if (coex_sta->under_ips) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is under IPS !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is under IPS !!!\n");
>   		return;
>   	}
>
>   	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
>   	if (wifi_under_5g) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), return for 5G <===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), return for 5G <===\n");
>   		halbtc8821a1ant_coex_under_5g(btcoexist);
>   		return;
>   	}
> @@ -2135,8 +2121,8 @@ static void halbtc8821a1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	if (!wifi_connected) {
>   		bool	scan = false, link = false, roam = false;
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], wifi is non connected-idle !!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], wifi is non connected-idle !!!\n");
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
> @@ -2168,8 +2154,8 @@ static void halbtc8821a1ant_init_hw_config(struct btc_coexist *btcoexist,
>   	u8	u1_tmp = 0;
>   	bool	wifi_under_5g = false;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], 1Ant Init HW Config!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], 1Ant Init HW Config!!\n");
>
>   	if (back_up) {
>   		coex_dm->backup_arfr_cnt1 = btcoexist->btc_read_4byte(btcoexist,
> @@ -2220,8 +2206,8 @@ void ex_halbtc8821a1ant_init_hwconfig(struct btc_coexist *btcoexist)
>
>   void ex_halbtc8821a1ant_init_coex_dm(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], Coex Mechanism Init!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], Coex Mechanism Init!!\n");
>
>   	btcoexist->stop_coex_dm = false;
>
> @@ -2515,8 +2501,8 @@ void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   		return;
>
>   	if (BTC_IPS_ENTER == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS ENTER notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS ENTER notify\n");
>   		coex_sta->under_ips = true;
>   		halbtc8821a1ant_set_ant_path(btcoexist,
>   					     BTC_ANT_PATH_BT, false, true);
> @@ -2525,8 +2511,8 @@ void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   		halbtc8821a1ant_coex_table_with_type(btcoexist,
>   						     NORMAL_EXEC, 0);
>   	} else if (BTC_IPS_LEAVE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS LEAVE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS LEAVE notify\n");
>   		coex_sta->under_ips = false;
>
>   		halbtc8821a1ant_run_coexist_mechanism(btcoexist);
> @@ -2539,12 +2525,12 @@ void ex_halbtc8821a1ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   		return;
>
>   	if (BTC_LPS_ENABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS ENABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS ENABLE notify\n");
>   		coex_sta->under_Lps = true;
>   	} else if (BTC_LPS_DISABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS DISABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS DISABLE notify\n");
>   		coex_sta->under_Lps = false;
>   	}
>   }
> @@ -2574,8 +2560,8 @@ void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   	}
>
>   	if (BTC_SCAN_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN START notify\n");
>   		if (!wifi_connected) {
>   			/* non-connected scan*/
>   			btc8821a1ant_act_wifi_not_conn_scan(btcoexist);
> @@ -2584,8 +2570,8 @@ void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   			halbtc8821a1ant_action_wifi_connected_scan(btcoexist);
>   		}
>   	} else if (BTC_SCAN_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN FINISH notify\n");
>   		if (!wifi_connected) {
>   			/* non-connected scan*/
>   			halbtc8821a1ant_action_wifi_not_connected(btcoexist);
> @@ -2614,12 +2600,12 @@ void ex_halbtc8821a1ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
>   	}
>
>   	if (BTC_ASSOCIATE_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT START notify\n");
>   		btc8821a1ant_act_wifi_not_conn_scan(btcoexist);
>   	} else if (BTC_ASSOCIATE_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT FINISH notify\n");
>
>   		btcoexist->btc_get(btcoexist,
>   			 BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
> @@ -2645,11 +2631,11 @@ void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist *btcoexist,
>   		return;
>
>   	if (BTC_MEDIA_CONNECT == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA connect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA connect notify\n");
>   	} else {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA disconnect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA disconnect notify\n");
>   	}
>
>   	/* only 2.4G we need to inform bt the chnl mask*/
> @@ -2672,9 +2658,11 @@ void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist *btcoexist,
>   	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
>   	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x66 = 0x%x\n",
> -		  h2c_parameter[0]<<16|h2c_parameter[1]<<8|h2c_parameter[2]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x66 = 0x%x\n",
> +		    h2c_parameter[0] << 16 |
> +		    h2c_parameter[1] << 8 |
> +		    h2c_parameter[2]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>   }
> @@ -2702,8 +2690,8 @@ void ex_halbtc8821a1ant_special_packet_notify(struct btc_coexist *btcoexist,
>
>   	if (BTC_PACKET_DHCP == type ||
>   	    BTC_PACKET_EAPOL == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], special Packet(%d) notify\n", type);
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], special Packet(%d) notify\n", type);
>   		btc8821a1ant_act_wifi_conn_sp_pkt(btcoexist);
>   	}
>   }
> @@ -2727,19 +2715,19 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		rsp_source = BT_INFO_SRC_8821A_1ANT_WIFI_FW;
>   	coex_sta->bt_info_c2h_cnt[rsp_source]++;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Bt info[%d], length = %d, hex data = [",
> -		  rsp_source, length);
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Bt info[%d], length = %d, hex data = [",
> +		      rsp_source, length);
>   	for (i = 0; i < length; i++) {
>   		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
>   		if (i == 1)
>   			bt_info = tmp_buf[i];
>   		if (i == length-1) {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x]\n", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x]\n", tmp_buf[i]);
>   		} else {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x, ", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x, ", tmp_buf[i]);
>   		}
>   	}
>
> @@ -2756,8 +2744,8 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		/* Here we need to resend some wifi info to BT*/
>   		/* because bt is reset and loss of the info.*/
>   		if (coex_sta->bt_info_ext & BIT1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
>   			btcoexist->btc_get(btcoexist,
>   					   BTC_GET_BL_WIFI_CONNECTED,
>   					   &wifi_connected);
> @@ -2773,8 +2761,8 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		if ((coex_sta->bt_info_ext & BIT3) && !wifi_under_5g) {
>   			if (!btcoexist->manual_control &&
>   			    !btcoexist->stop_coex_dm) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], BT ext info bit3 check, set BT NOT to ignore Wlan active!!\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], BT ext info bit3 check, set BT NOT to ignore Wlan active!!\n");
>   				halbtc8821a1ant_ignore_wlan_act(btcoexist,
>   								FORCE_EXEC,
>   								false);
> @@ -2782,8 +2770,8 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		}
>   #if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
>   		if (!(coex_sta->bt_info_ext & BIT4)) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], BT ext info bit4 check, set BT to enable Auto Report!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], BT ext info bit4 check, set BT to enable Auto Report!!\n");
>   			halbtc8821a1ant_bt_auto_report(btcoexist,
>   						       FORCE_EXEC, true);
>   		}
> @@ -2828,28 +2816,28 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   	if (!(bt_info&BT_INFO_8821A_1ANT_B_CONNECTION)) {
>   		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Non-Connected idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Connected idle!!!\n");
>   	} else if (bt_info == BT_INFO_8821A_1ANT_B_CONNECTION) {
>   		/* connection exists but no busy*/
>   		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
>   	} else if ((bt_info&BT_INFO_8821A_1ANT_B_SCO_ESCO) ||
>   		(bt_info&BT_INFO_8821A_1ANT_B_SCO_BUSY)) {
>   		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_SCO_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
>   	} else if (bt_info&BT_INFO_8821A_1ANT_B_ACL_BUSY) {
>   		if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY != coex_dm->bt_status)
>   			coex_dm->auto_tdma_adjust = false;
>   		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_ACL_BUSY;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
>   	} else {
>   		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_MAX;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BtInfoNotify(), BT Non-Defined state!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BtInfoNotify(), BT Non-Defined state!!!\n");
>   	}
>
>   	if ((BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
> @@ -2866,8 +2854,8 @@ void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Halt notify\n");
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Halt notify\n");
>
>   	btcoexist->stop_coex_dm = true;
>
> @@ -2885,20 +2873,20 @@ void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist)
>
>   void ex_halbtc8821a1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Pnp notify\n");
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Pnp notify\n");
>
>   	if (BTC_WIFI_PNP_SLEEP == pnp_state) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], Pnp notify to SLEEP\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], Pnp notify to SLEEP\n");
>   		btcoexist->stop_coex_dm = true;
>   		halbtc8821a1ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
>   		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
>   						 0x0, 0x0);
>   		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 9);
>   	} else if (BTC_WIFI_PNP_WAKE_UP == pnp_state) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], Pnp notify to WAKE UP\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], Pnp notify to WAKE UP\n");
>   		btcoexist->stop_coex_dm = false;
>   		halbtc8821a1ant_init_hw_config(btcoexist, false);
>   		halbtc8821a1ant_init_coex_dm(btcoexist);
> @@ -2914,33 +2902,33 @@ ex_halbtc8821a1ant_periodical(
>   	struct btc_board_info *board_info = &btcoexist->board_info;
>   	struct btc_stack_info *stack_info = &btcoexist->stack_info;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], ==========================Periodical===========================\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], ==========================Periodical===========================\n");
>
>   	if (dis_ver_info_cnt <= 5) {
>   		dis_ver_info_cnt += 1;
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> -			  board_info->pg_ant_num,
> -			  board_info->btdm_ant_num,
> -			  board_info->btdm_ant_pos);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> -			  ((stack_info->profile_notified) ? "Yes" : "No"),
> -			  stack_info->hci_version);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> +			      board_info->pg_ant_num,
> +			      board_info->btdm_ant_num,
> +			      board_info->btdm_ant_pos);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> +			      stack_info->profile_notified ? "Yes" : "No",
> +			      stack_info->hci_version);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>   				   &bt_patch_ver);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> -			glcoex_ver_date_8821a_1ant,
> -			glcoex_ver_8821a_1ant,
> -			fw_ver, bt_patch_ver,
> -			bt_patch_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> +			      glcoex_ver_date_8821a_1ant,
> +			      glcoex_ver_8821a_1ant,
> +			      fw_ver, bt_patch_ver,
> +			      bt_patch_ver);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
>   	}
>
>   #if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
> index 044d914..81f843b 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
> @@ -80,28 +80,28 @@ static u8 halbtc8821a2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   				   BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT;
>   			if (bt_rssi >= tmp) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -				  "[BTCoex], BT Rssi thresh error!!\n");
> +			btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +				    "[BTCoex], BT Rssi thresh error!!\n");
>   			return coex_sta->pre_bt_rssi_state;
>   		}
>
> @@ -110,12 +110,12 @@ static u8 halbtc8821a2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			if (bt_rssi >=
>   			    (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_bt_rssi_state ==
>   			   BTC_RSSI_STATE_MEDIUM) ||
> @@ -125,26 +125,26 @@ static u8 halbtc8821a2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
>   			    (rssi_thresh1 +
>   			     BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
>   				bt_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to High\n");
>   			} else if (bt_rssi < rssi_thresh) {
>   				bt_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Low\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Low\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at Medium\n");
>   			}
>   		} else {
>   			if (bt_rssi < rssi_thresh1) {
>   				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state switch to Medium\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state switch to Medium\n");
>   			} else {
>   				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
> -					  "[BTCoex], BT Rssi state stay at High\n");
> +				btc_alg_dbg(ALGO_BT_RSSI_STATE,
> +					    "[BTCoex], BT Rssi state stay at High\n");
>   			}
>   		}
>   	}
> @@ -171,32 +171,28 @@ static u8 halbtc8821a2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >=
>   			    (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	} else if (level_num == 3) {
>   		if (rssi_thresh > rssi_thresh1) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
> -				  "[BTCoex], wifi RSSI thresh error!!\n");
> +			btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +				    "[BTCoex], wifi RSSI thresh error!!\n");
>   			return coex_sta->pre_wifi_rssi_state[index];
>   		}
>
> @@ -207,14 +203,12 @@ static u8 halbtc8821a2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >=
>   			    (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Low\n");
>   			}
>   		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
>   			   BTC_RSSI_STATE_MEDIUM) ||
> @@ -223,31 +217,26 @@ static u8 halbtc8821a2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
>   			if (wifi_rssi >= (rssi_thresh1 +
>   			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
>   				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to High\n");
>   			} else if (wifi_rssi < rssi_thresh) {
>   				wifi_rssi_state = BTC_RSSI_STATE_LOW;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Low\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Low\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at Medium\n");
>   			}
>   		} else {
>   			if (wifi_rssi < rssi_thresh1) {
>   				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state switch to Medium\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state switch to Medium\n");
>   			} else {
>   				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_WIFI_RSSI_STATE,
> -					  "[BTCoex], wifi RSSI state stay at High\n");
> +				btc_alg_dbg(ALGO_WIFI_RSSI_STATE,
> +					    "[BTCoex], wifi RSSI state stay at High\n");
>   			}
>   		}
>   	}
> @@ -279,26 +268,26 @@ static void btc8821a2ant_mon_bt_en_dis(struct btc_coexist *btcoexist)
>   		bt_disabled = false;
>   		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   				   &bt_disabled);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is enabled !!\n");
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is enabled !!\n");
>   	} else {
>   		bt_disable_cnt++;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], bt all counters = 0, %d times!!\n",
> -			  bt_disable_cnt);
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], bt all counters = 0, %d times!!\n",
> +			    bt_disable_cnt);
>   		if (bt_disable_cnt >= 2) {
>   			bt_disabled = true;
>   			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
>   					   &bt_disabled);
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -				  "[BTCoex], BT is disabled !!\n");
> +			btc_alg_dbg(ALGO_BT_MONITOR,
> +				    "[BTCoex], BT is disabled !!\n");
>   		}
>   	}
>   	if (pre_bt_disabled != bt_disabled) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -			  "[BTCoex], BT is from %s to %s!!\n",
> -			  (pre_bt_disabled ? "disabled" : "enabled"),
> -			  (bt_disabled ? "disabled" : "enabled"));
> +		btc_alg_dbg(ALGO_BT_MONITOR,
> +			    "[BTCoex], BT is from %s to %s!!\n",
> +			    (pre_bt_disabled ? "disabled" : "enabled"),
> +			    (bt_disabled ? "disabled" : "enabled"));
>   		pre_bt_disabled = bt_disabled;
>   	}
>   }
> @@ -324,12 +313,12 @@ static void halbtc8821a2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
>   	coex_sta->low_priority_tx = reg_lp_tx;
>   	coex_sta->low_priority_rx = reg_lp_rx;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> -		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
> -		  "[BTCoex], Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> -		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> +		    reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
> +	btc_alg_dbg(ALGO_BT_MONITOR,
> +		    "[BTCoex], Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
> +		    reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
>
>   	/* reset counter */
>   	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
> @@ -343,9 +332,9 @@ static void halbtc8821a2ant_query_bt_info(struct btc_coexist *btcoexist)
>
>   	h2c_parameter[0] |= BIT0;	/* trigger */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
>   }
> @@ -368,8 +357,8 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>   		stack_info->bt_link_exist = coex_sta->bt_link_exist;
>
>   	if (!coex_sta->bt_link_exist) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], No profile exists!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], No profile exists!!!\n");
>   		return algorithm;
>   	}
>
> @@ -384,26 +373,26 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>
>   	if (num_of_diff_profile == 1) {
>   		if (coex_sta->sco_exist) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], SCO only\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], SCO only\n");
>   			algorithm = BT_8821A_2ANT_COEX_ALGO_SCO;
>   		} else {
>   			if (coex_sta->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], HID only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], HID only\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_HID;
>   			} else if (coex_sta->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], A2DP only\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], A2DP only\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_A2DP;
>   			} else if (coex_sta->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], PAN(HS) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], PAN(HS) only\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], PAN(EDR) only\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], PAN(EDR) only\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR;
>   				}
>   			}
> @@ -411,50 +400,50 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>   	} else if (num_of_diff_profile == 2) {
>   		if (coex_sta->sco_exist) {
>   			if (coex_sta->hid_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + HID\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (coex_sta->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + A2DP ==> SCO\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + A2DP ==> SCO\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (coex_sta->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + PAN(HS)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_SCO;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + PAN(EDR)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
>   		} else {
>   			if (coex_sta->hid_exist &&
>   			    coex_sta->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], HID + A2DP\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], HID + A2DP\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP;
>   			} else if (coex_sta->hid_exist &&
>   				coex_sta->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + PAN(HS)\n");
>   					algorithm =  BT_8821A_2ANT_COEX_ALGO_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + PAN(EDR)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (coex_sta->pan_exist &&
>   				coex_sta->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_A2DP_PANHS;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], A2DP + PAN(EDR)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_A2DP;
>   				}
>   			}
> @@ -463,29 +452,29 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>   		if (coex_sta->sco_exist) {
>   			if (coex_sta->hid_exist &&
>   			    coex_sta->a2dp_exist) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -					  "[BTCoex], SCO + HID + A2DP ==> HID\n");
> +				btc_alg_dbg(ALGO_TRACE,
> +					    "[BTCoex], SCO + HID + A2DP ==> HID\n");
>   				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   			} else if (coex_sta->hid_exist &&
>   				coex_sta->pan_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + PAN(HS)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + PAN(EDR)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			} else if (coex_sta->pan_exist &&
>   				   coex_sta->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + A2DP + PAN(EDR) ==> HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + A2DP + PAN(EDR) ==> HID\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
> @@ -494,12 +483,12 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    coex_sta->pan_exist &&
>   			    coex_sta->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + A2DP + PAN(HS)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP;
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], HID + A2DP + PAN(EDR)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], HID + A2DP + PAN(EDR)\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
>   				}
>   			}
> @@ -510,12 +499,12 @@ static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
>   			    coex_sta->pan_exist &&
>   			    coex_sta->a2dp_exist) {
>   				if (bt_hs_on) {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], Error!!! SCO + HID + A2DP + PAN(HS)\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], Error!!! SCO + HID + A2DP + PAN(HS)\n");
>
>   				} else {
> -					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -						  "[BTCoex], SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
> +					btc_alg_dbg(ALGO_TRACE,
> +						    "[BTCoex], SCO + HID + A2DP + PAN(EDR)==>PAN(EDR)+HID\n");
>   					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
>   				}
>   			}
> @@ -544,15 +533,15 @@ static bool halbtc8821a2ant_need_to_dec_bt_pwr(struct btc_coexist *btcoexist)
>   	if (wifi_connected) {
>   		if (bt_hs_on) {
>   			if (bt_hs_rssi > 37) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -					  "[BTCoex], Need to decrease bt power for HS mode!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW,
> +					    "[BTCoex], Need to decrease bt power for HS mode!!\n");
>   				ret = true;
>   			}
>   		} else {
>   			if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
>   			    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
> -				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -					  "[BTCoex], Need to decrease bt power for Wifi is connected!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW,
> +					    "[BTCoex], Need to decrease bt power for Wifi is connected!!\n");
>   				ret = true;
>   			}
>   		}
> @@ -570,10 +559,10 @@ static void btc8821a2ant_set_fw_dac_swing_lev(struct btc_coexist *btcoexist,
>   	 */
>   	h2c_parameter[0] = dac_swing_lvl;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swing_lvl);
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
>   }
> @@ -588,9 +577,9 @@ static void halbtc8821a2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
>   	if (dec_bt_pwr)
>   		h2c_parameter[0] |= BIT1;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], decrease Bt Power : %s, FW write 0x62 = 0x%x\n",
> -		  (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], decrease Bt Power : %s, FW write 0x62 = 0x%x\n",
> +		    (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
>   }
> @@ -598,16 +587,16 @@ static void halbtc8821a2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
>   static void halbtc8821a2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
>   				       bool force_exec, bool dec_bt_pwr)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s Dec BT power = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((dec_bt_pwr) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s Dec BT power = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((dec_bt_pwr) ? "ON" : "OFF"));
>   	coex_dm->cur_dec_bt_pwr = dec_bt_pwr;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_dec_bt_pwr = %d, cur_dec_bt_pwr = %d\n",
> -			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_dec_bt_pwr = %d, cur_dec_bt_pwr = %d\n",
> +			    coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
>
>   		if (coex_dm->pre_dec_bt_pwr == coex_dm->cur_dec_bt_pwr)
>   			return;
> @@ -627,10 +616,10 @@ static void btc8821a2ant_set_fw_bt_lna_constr(struct btc_coexist *btcoexist,
>   	if (bt_lna_cons_on)
>   		h2c_parameter[1] |= BIT0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set BT LNA Constrain: %s, FW write 0x69 = 0x%x\n",
> -		  (bt_lna_cons_on ? "ON!!" : "OFF!!"),
> -		  h2c_parameter[0]<<8|h2c_parameter[1]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set BT LNA Constrain: %s, FW write 0x69 = 0x%x\n",
> +		    bt_lna_cons_on ? "ON!!" : "OFF!!",
> +		    h2c_parameter[0] << 8 | h2c_parameter[1]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 2, h2c_parameter);
>   }
> @@ -638,17 +627,17 @@ static void btc8821a2ant_set_fw_bt_lna_constr(struct btc_coexist *btcoexist,
>   static void btc8821a2_set_bt_lna_const(struct btc_coexist *btcoexist,
>   				       bool force_exec, bool bt_lna_cons_on)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s BT Constrain = %s\n",
> -		  (force_exec ? "force" : ""),
> -		  ((bt_lna_cons_on) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s BT Constrain = %s\n",
> +		    (force_exec ? "force" : ""),
> +		    ((bt_lna_cons_on) ? "ON" : "OFF"));
>   	coex_dm->cur_bt_lna_constrain = bt_lna_cons_on;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_bt_lna_constrain = %d,cur_bt_lna_constrain = %d\n",
> -			  coex_dm->pre_bt_lna_constrain,
> -			  coex_dm->cur_bt_lna_constrain);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_bt_lna_constrain = %d,cur_bt_lna_constrain = %d\n",
> +			    coex_dm->pre_bt_lna_constrain,
> +			    coex_dm->cur_bt_lna_constrain);
>
>   		if (coex_dm->pre_bt_lna_constrain ==
>   		    coex_dm->cur_bt_lna_constrain)
> @@ -669,10 +658,10 @@ static void halbtc8821a2ant_set_fw_bt_psd_mode(struct btc_coexist *btcoexist,
>
>   	h2c_parameter[1] = bt_psd_mode;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set BT PSD mode = 0x%x, FW write 0x69 = 0x%x\n",
> -		  h2c_parameter[1],
> -		  h2c_parameter[0]<<8|h2c_parameter[1]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set BT PSD mode = 0x%x, FW write 0x69 = 0x%x\n",
> +		    h2c_parameter[1],
> +		    h2c_parameter[0] << 8 | h2c_parameter[1]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 2, h2c_parameter);
>   }
> @@ -680,15 +669,15 @@ static void halbtc8821a2ant_set_fw_bt_psd_mode(struct btc_coexist *btcoexist,
>   static void halbtc8821a2ant_set_bt_psd_mode(struct btc_coexist *btcoexist,
>   					    bool force_exec, u8 bt_psd_mode)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s BT PSD mode = 0x%x\n",
> -		  (force_exec ? "force" : ""), bt_psd_mode);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s BT PSD mode = 0x%x\n",
> +		    (force_exec ? "force" : ""), bt_psd_mode);
>   	coex_dm->cur_bt_psd_mode = bt_psd_mode;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_bt_psd_mode = 0x%x, cur_bt_psd_mode = 0x%x\n",
> -			  coex_dm->pre_bt_psd_mode, coex_dm->cur_bt_psd_mode);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_bt_psd_mode = 0x%x, cur_bt_psd_mode = 0x%x\n",
> +			    coex_dm->pre_bt_psd_mode, coex_dm->cur_bt_psd_mode);
>
>   		if (coex_dm->pre_bt_psd_mode == coex_dm->cur_bt_psd_mode)
>   			return;
> @@ -709,10 +698,10 @@ static void halbtc8821a2ant_set_bt_auto_report(struct btc_coexist *btcoexist,
>   	if (enable_auto_report)
>   		h2c_parameter[0] |= BIT0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> -		  (enable_auto_report ? "Enabled!!" : "Disabled!!"),
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
> +		    (enable_auto_report ? "Enabled!!" : "Disabled!!"),
> +		    h2c_parameter[0]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
>   }
> @@ -721,17 +710,17 @@ static void halbtc8821a2ant_bt_auto_report(struct btc_coexist *btcoexist,
>   					   bool force_exec,
>   					   bool enable_auto_report)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s BT Auto report = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((enable_auto_report) ? "Enabled" : "Disabled"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s BT Auto report = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((enable_auto_report) ? "Enabled" : "Disabled"));
>   	coex_dm->cur_bt_auto_report = enable_auto_report;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_bt_auto_report = %d, cur_bt_auto_report = %d\n",
> -			  coex_dm->pre_bt_auto_report,
> -			  coex_dm->cur_bt_auto_report);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_bt_auto_report = %d, cur_bt_auto_report = %d\n",
> +			    coex_dm->pre_bt_auto_report,
> +			    coex_dm->cur_bt_auto_report);
>
>   		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
>   			return;
> @@ -746,16 +735,16 @@ static void halbtc8821a2ant_fw_dac_swing_lvl(struct btc_coexist *btcoexist,
>   					     bool force_exec,
>   					     u8 fw_dac_swing_lvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s set FW Dac Swing level = %d\n",
> -		  (force_exec ? "force to" : ""), fw_dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s set FW Dac Swing level = %d\n",
> +		    (force_exec ? "force to" : ""), fw_dac_swing_lvl);
>   	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swing_lvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_fw_dac_swing_lvl = %d, cur_fw_dac_swing_lvl = %d\n",
> -			  coex_dm->pre_fw_dac_swing_lvl,
> -			  coex_dm->cur_fw_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_fw_dac_swing_lvl = %d, cur_fw_dac_swing_lvl = %d\n",
> +			    coex_dm->pre_fw_dac_swing_lvl,
> +			    coex_dm->cur_fw_dac_swing_lvl);
>
>   		if (coex_dm->pre_fw_dac_swing_lvl ==
>   		    coex_dm->cur_fw_dac_swing_lvl)
> @@ -773,8 +762,8 @@ static void btc8821a2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   {
>   	if (rx_rf_shrink_on) {
>   		/* Shrink RF Rx LPF corner */
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], Shrink RF Rx LPF corner!!\n");
>   		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
>   					  0xfffff, 0xffffc);
>   	} else {
> @@ -782,8 +771,8 @@ static void btc8821a2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   		 * After initialized, we can use coex_dm->bt_rf0x1e_backup
>   		 */
>   		if (btcoexist->initilized) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -				  "[BTCoex], Resume RF Rx LPF corner!!\n");
> +			btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +				    "[BTCoex], Resume RF Rx LPF corner!!\n");
>   			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A,
>   						  0x1e, 0xfffff,
>   						   coex_dm->bt_rf0x1e_backup);
> @@ -794,17 +783,17 @@ static void btc8821a2ant_set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
>   static void halbtc8821a2ant_RfShrink(struct btc_coexist *btcoexist,
>   				     bool force_exec, bool rx_rf_shrink_on)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((rx_rf_shrink_on) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn Rx RF Shrink = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((rx_rf_shrink_on) ? "ON" : "OFF"));
>   	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], pre_rf_rx_lpf_shrink = %d, cur_rf_rx_lpf_shrink = %d\n",
> -			  coex_dm->pre_rf_rx_lpf_shrink,
> -			  coex_dm->cur_rf_rx_lpf_shrink);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], pre_rf_rx_lpf_shrink = %d, cur_rf_rx_lpf_shrink = %d\n",
> +			    coex_dm->pre_rf_rx_lpf_shrink,
> +			    coex_dm->cur_rf_rx_lpf_shrink);
>
>   		if (coex_dm->pre_rf_rx_lpf_shrink ==
>   		    coex_dm->cur_rf_rx_lpf_shrink)
> @@ -835,9 +824,9 @@ static void btc8821a2ant_SetSwPenTxRateAdapt(struct btc_coexist *btcoexist,
>   		h2c_parameter[5] = 0xf9;
>   	}
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
> -		  (low_penalty_ra ? "ON!!" : "OFF!!"));
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set WiFi Low-Penalty Retry: %s",
> +		    (low_penalty_ra ? "ON!!" : "OFF!!"));
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
>   }
> @@ -846,17 +835,17 @@ static void halbtc8821a2ant_low_penalty_ra(struct btc_coexist *btcoexist,
>   					   bool force_exec, bool low_penalty_ra)
>   {
>   	/*return;*/
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn LowPenaltyRA = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((low_penalty_ra) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn LowPenaltyRA = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((low_penalty_ra) ? "ON" : "OFF"));
>   	coex_dm->cur_low_penalty_ra = low_penalty_ra;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], pre_low_penalty_ra = %d, cur_low_penalty_ra = %d\n",
> -			  coex_dm->pre_low_penalty_ra,
> -			  coex_dm->cur_low_penalty_ra);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], pre_low_penalty_ra = %d, cur_low_penalty_ra = %d\n",
> +			    coex_dm->pre_low_penalty_ra,
> +			    coex_dm->cur_low_penalty_ra);
>
>   		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
>   			return;
> @@ -872,8 +861,8 @@ static void halbtc8821a2ant_set_dac_swing_reg(struct btc_coexist *btcoexist,
>   {
>   	u8 val = (u8)level;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], Write SwDacSwing = 0x%x\n", level);
>   	btcoexist->btc_write_1byte_bitmask(btcoexist, 0xc5b, 0x3e, val);
>   }
>
> @@ -891,21 +880,21 @@ static void halbtc8821a2ant_dac_swing(struct btc_coexist *btcoexist,
>   				      bool force_exec, bool dac_swing_on,
>   				      u32 dac_swing_lvl)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn DacSwing = %s, dac_swing_lvl = 0x%x\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((dac_swing_on) ? "ON" : "OFF"),
> -		  dac_swing_lvl);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn DacSwing = %s, dac_swing_lvl = 0x%x\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((dac_swing_on) ? "ON" : "OFF"),
> +		    dac_swing_lvl);
>   	coex_dm->cur_dac_swing_on = dac_swing_on;
>   	coex_dm->cur_dac_swing_lvl = dac_swing_lvl;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], pre_dac_swing_on = %d, pre_dac_swing_lvl = 0x%x, cur_dac_swing_on = %d, cur_dac_swing_lvl = 0x%x\n",
> -			  coex_dm->pre_dac_swing_on,
> -			  coex_dm->pre_dac_swing_lvl,
> -			  coex_dm->cur_dac_swing_on,
> -			  coex_dm->cur_dac_swing_lvl);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], pre_dac_swing_on = %d, pre_dac_swing_lvl = 0x%x, cur_dac_swing_on = %d, cur_dac_swing_lvl = 0x%x\n",
> +			    coex_dm->pre_dac_swing_on,
> +			    coex_dm->pre_dac_swing_lvl,
> +			    coex_dm->cur_dac_swing_on,
> +			    coex_dm->cur_dac_swing_lvl);
>
>   		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
>   		    (coex_dm->pre_dac_swing_lvl ==
> @@ -924,12 +913,12 @@ static void halbtc8821a2ant_set_adc_back_off(struct btc_coexist *btcoexist,
>   					     bool adc_back_off)
>   {
>   	if (adc_back_off) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB BackOff Level On!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB BackOff Level On!\n");
>   		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x8db, 0x60, 0x3);
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -			  "[BTCoex], BB BackOff Level Off!\n");
> +		btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +			    "[BTCoex], BB BackOff Level Off!\n");
>   		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x8db, 0x60, 0x1);
>   	}
>   }
> @@ -937,16 +926,17 @@ static void halbtc8821a2ant_set_adc_back_off(struct btc_coexist *btcoexist,
>   static void halbtc8821a2ant_adc_back_off(struct btc_coexist *btcoexist,
>   					 bool force_exec, bool adc_back_off)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s turn AdcBackOff = %s\n",
> -		  (force_exec ? "force to" : ""),
> -		  ((adc_back_off) ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s turn AdcBackOff = %s\n",
> +		    (force_exec ? "force to" : ""),
> +		    ((adc_back_off) ? "ON" : "OFF"));
>   	coex_dm->cur_adc_back_off = adc_back_off;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], pre_adc_back_off = %d, cur_adc_back_off = %d\n",
> -			  coex_dm->pre_adc_back_off, coex_dm->cur_adc_back_off);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], pre_adc_back_off = %d, cur_adc_back_off = %d\n",
> +			    coex_dm->pre_adc_back_off,
> +			    coex_dm->cur_adc_back_off);
>
>   		if (coex_dm->pre_adc_back_off == coex_dm->cur_adc_back_off)
>   			return;
> @@ -960,20 +950,20 @@ static void halbtc8821a2ant_set_coex_table(struct btc_coexist *btcoexist,
>   					   u32 val0x6c0, u32 val0x6c4,
>   					   u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
>   	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
> -		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW_EXEC,
> +		    "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
>   	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
>   }
>
> @@ -981,28 +971,28 @@ static void halbtc8821a2ant_coex_table(struct btc_coexist *btcoexist,
>   				       bool force_exec, u32 val0x6c0,
>   				       u32 val0x6c4, u32 val0x6c8, u8 val0x6cc)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
> -		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> -		  (force_exec ? "force to" : ""),
> -		  val0x6c0, val0x6c4, val0x6c8, val0x6cc);
> +	btc_alg_dbg(ALGO_TRACE_SW,
> +		    "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
> +		    (force_exec ? "force to" : ""),
> +		    val0x6c0, val0x6c4, val0x6c8, val0x6cc);
>   	coex_dm->cur_val0x6c0 = val0x6c0;
>   	coex_dm->cur_val0x6c4 = val0x6c4;
>   	coex_dm->cur_val0x6c8 = val0x6c8;
>   	coex_dm->cur_val0x6cc = val0x6cc;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], pre_val0x6c0 = 0x%x, pre_val0x6c4 = 0x%x, pre_val0x6c8 = 0x%x, pre_val0x6cc = 0x%x !!\n",
> -			  coex_dm->pre_val0x6c0,
> -			  coex_dm->pre_val0x6c4,
> -			  coex_dm->pre_val0x6c8,
> -			  coex_dm->pre_val0x6cc);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
> -			  "[BTCoex], cur_val0x6c0 = 0x%x, cur_val0x6c4 = 0x%x, cur_val0x6c8 = 0x%x, cur_val0x6cc = 0x%x !!\n",
> -			  coex_dm->cur_val0x6c0,
> -			  coex_dm->cur_val0x6c4,
> -			  coex_dm->cur_val0x6c8,
> -			  coex_dm->cur_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], pre_val0x6c0 = 0x%x, pre_val0x6c4 = 0x%x, pre_val0x6c8 = 0x%x, pre_val0x6cc = 0x%x !!\n",
> +			    coex_dm->pre_val0x6c0,
> +			    coex_dm->pre_val0x6c4,
> +			    coex_dm->pre_val0x6c8,
> +			    coex_dm->pre_val0x6cc);
> +		btc_alg_dbg(ALGO_TRACE_SW_DETAIL,
> +			    "[BTCoex], cur_val0x6c0 = 0x%x, cur_val0x6c4 = 0x%x, cur_val0x6c8 = 0x%x, cur_val0x6cc = 0x%x !!\n",
> +			    coex_dm->cur_val0x6c0,
> +			    coex_dm->cur_val0x6c4,
> +			    coex_dm->cur_val0x6c8,
> +			    coex_dm->cur_val0x6cc);
>
>   		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
>   		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
> @@ -1027,9 +1017,9 @@ static void halbtc8821a2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoex,
>   	if (enable)
>   		h2c_parameter[0] |= BIT0;/* function enable */
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> -		  h2c_parameter[0]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
> +		    h2c_parameter[0]);
>
>   	btcoex->btc_fill_h2c(btcoex, 0x63, 1, h2c_parameter);
>   }
> @@ -1037,16 +1027,16 @@ static void halbtc8821a2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoex,
>   static void halbtc8821a2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
>   					    bool force_exec, bool enable)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn Ignore WlanAct %s\n",
> -		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn Ignore WlanAct %s\n",
> +		    (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
>   	coex_dm->cur_ignore_wlan_act = enable;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
> -			  coex_dm->pre_ignore_wlan_act,
> -			  coex_dm->cur_ignore_wlan_act);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
> +			    coex_dm->pre_ignore_wlan_act,
> +			    coex_dm->cur_ignore_wlan_act);
>
>   		if (coex_dm->pre_ignore_wlan_act ==
>   		    coex_dm->cur_ignore_wlan_act)
> @@ -1075,13 +1065,13 @@ static void halbtc8821a2ant_set_fw_pstdma(struct btc_coexist *btcoexist,
>   	coex_dm->ps_tdma_para[3] = byte4;
>   	coex_dm->ps_tdma_para[4] = byte5;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
> -		  h2c_parameter[0],
> -		  h2c_parameter[1]<<24|
> -		  h2c_parameter[2]<<16|
> -		  h2c_parameter[3]<<8|
> -		  h2c_parameter[4]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
> +		    h2c_parameter[0],
> +		    h2c_parameter[1] << 24 |
> +		    h2c_parameter[2] << 16 |
> +		    h2c_parameter[3] << 8 |
> +		    h2c_parameter[4]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
>   }
> @@ -1175,20 +1165,20 @@ static void halbtc8821a2ant_set_ant_path(struct btc_coexist *btcoexist,
>   static void halbtc8821a2ant_ps_tdma(struct btc_coexist *btcoexist,
>   				    bool force_exec, bool turn_on, u8 type)
>   {
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], %s turn %s PS TDMA, type = %d\n",
> -		  (force_exec ? "force to" : ""), (turn_on ? "ON" : "OFF"),
> -		  type);
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], %s turn %s PS TDMA, type = %d\n",
> +		    (force_exec ? "force to" : ""), (turn_on ? "ON" : "OFF"),
> +		    type);
>   	coex_dm->cur_ps_tdma_on = turn_on;
>   	coex_dm->cur_ps_tdma = type;
>
>   	if (!force_exec) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_ps_tdma_on = %d, cur_ps_tdma_on = %d!!\n",
> -			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], pre_ps_tdma = %d, cur_ps_tdma = %d!!\n",
> -			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_ps_tdma_on = %d, cur_ps_tdma_on = %d!!\n",
> +			    coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], pre_ps_tdma = %d, cur_ps_tdma = %d!!\n",
> +			    coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
>
>   		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
>   		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
> @@ -1374,8 +1364,8 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
>   				   &low_pwr_disable);
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi IPS + BT IPS!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi IPS + BT IPS!!\n");
>
>   		halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
>   		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
> @@ -1392,13 +1382,13 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   				   &low_pwr_disable);
>
>   		if (wifi_busy) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Busy + BT IPS!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Busy + BT IPS!!\n");
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						false, 1);
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi LPS + BT IPS!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi LPS + BT IPS!!\n");
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						false, 1);
>   		}
> @@ -1416,8 +1406,8 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
>   				   &low_pwr_disable);
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi IPS + BT LPS!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi IPS + BT LPS!!\n");
>
>   		halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
>   		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
> @@ -1433,13 +1423,13 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   			BTC_SET_ACT_DISABLE_LOW_POWER, &low_pwr_disable);
>
>   		if (wifi_busy) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Busy + BT LPS!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Busy + BT LPS!!\n");
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						false, 1);
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi LPS + BT LPS!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi LPS + BT LPS!!\n");
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						false, 1);
>   		}
> @@ -1458,8 +1448,8 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   		btcoexist->btc_set(btcoexist,
>   			BTC_SET_ACT_DISABLE_LOW_POWER, &low_pwr_disable);
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Wifi IPS + BT Busy!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Wifi IPS + BT Busy!!\n");
>
>   		halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
>   		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
> @@ -1478,12 +1468,12 @@ static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
>   				   &low_pwr_disable);
>
>   		if (wifi_busy) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi Busy + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi Busy + BT Busy!!\n");
>   			common = false;
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Wifi LPS + BT Busy!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Wifi LPS + BT Busy!!\n");
>   			halbtc8821a2ant_ps_tdma(btcoexist,
>   						NORMAL_EXEC, true, 21);
>
> @@ -1505,8 +1495,8 @@ static void btc8821a2_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   			   int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>
>   		if (coex_dm->cur_ps_tdma == 71) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
> @@ -1601,8 +1591,8 @@ static void btc8821a2_int1(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 71);
> @@ -1706,8 +1696,8 @@ static void btc8821a2_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   			   int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 6);
> @@ -1796,8 +1786,8 @@ static void btc8821a2_int2(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 2);
> @@ -1892,8 +1882,8 @@ static void btc8821a2_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   			   int result)
>   {
>   	if (tx_pause) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 1\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 1\n");
>   		if (coex_dm->cur_ps_tdma == 1) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 7);
> @@ -1982,8 +1972,8 @@ static void btc8821a2_int3(struct btc_coexist *btcoexist, bool tx_pause,
>   			}
>   		}
>   	} else {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], TxPause = 0\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], TxPause = 0\n");
>   		if (coex_dm->cur_ps_tdma == 5) {
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC,
>   						true, 3);
> @@ -2085,13 +2075,13 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   	int		result;
>   	u8		retry_count = 0;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
> -		  "[BTCoex], TdmaDurationAdjust()\n");
> +	btc_alg_dbg(ALGO_TRACE_FW,
> +		    "[BTCoex], TdmaDurationAdjust()\n");
>
>   	if (coex_dm->reset_tdma_adjust) {
>   		coex_dm->reset_tdma_adjust = false;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], first run TdmaDurationAdjust()!!\n");
>   		if (sco_hid) {
>   			if (tx_pause) {
>   				if (max_interval == 1) {
> @@ -2195,11 +2185,11 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   	} else {
>   		/* accquire the BT TRx retry count from BT_Info byte2 */
>   		retry_count = coex_sta->bt_retry_cnt;
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], retry_count = %d\n", retry_count);
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], up = %d, dn = %d, m = %d, n = %d, wait_count = %d\n",
> -			  (int)up, (int)dn, (int)m, (int)n, (int)wait_count);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], retry_count = %d\n", retry_count);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], up = %d, dn = %d, m = %d, n = %d, wait_count = %d\n",
> +			    (int)up, (int)dn, (int)m, (int)n, (int)wait_count);
>   		result = 0;
>   		wait_count++;
>
> @@ -2220,9 +2210,8 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   				up = 0;
>   				dn = 0;
>   				result = 1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Increase wifi duration!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Increase wifi duration!!\n");
>   			}
>   		} else if (retry_count <= 3) {
>   			/* <=3 retry in the last 2-second duration */
> @@ -2251,9 +2240,8 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   				dn = 0;
>   				wait_count = 0;
>   				result = -1;
> -				BTC_PRINT(BTC_MSG_ALGORITHM,
> -					  ALGO_TRACE_FW_DETAIL,
> -					  "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
> +				btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +					    "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
>   			}
>   		} else {
>   			/* retry count > 3, if retry count > 3 happens once,
> @@ -2274,12 +2262,12 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   			dn = 0;
>   			wait_count = 0;
>   			result = -1;
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
>   		}
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], max Interval = %d\n", max_interval);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], max Interval = %d\n", max_interval);
>   		if (max_interval == 1)
>   			btc8821a2_int1(btcoexist, tx_pause, result);
>   		else if (max_interval == 2)
> @@ -2295,9 +2283,9 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   	if (coex_dm->cur_ps_tdma != coex_dm->tdma_adj_type) {
>   		bool	scan = false, link = false, roam = false;
>
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -			  "[BTCoex], PsTdma type dismatch!!!, cur_ps_tdma = %d, recordPsTdma = %d\n",
> -			  coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
> +		btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +			    "[BTCoex], PsTdma type dismatch!!!, cur_ps_tdma = %d, recordPsTdma = %d\n",
> +			    coex_dm->cur_ps_tdma, coex_dm->tdma_adj_type);
>
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>   		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
> @@ -2307,8 +2295,8 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
>   			halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, true,
>   						coex_dm->tdma_adj_type);
>   		} else {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
> -				  "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
> +			btc_alg_dbg(ALGO_TRACE_FW_DETAIL,
> +				    "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
>   		}
>   	}
>
> @@ -3183,8 +3171,8 @@ static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	u8	algorithm = 0;
>
>   	if (btcoexist->manual_control) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Manual control!!!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Manual control!!!\n");
>   		return;
>   	}
>
> @@ -3192,8 +3180,8 @@ static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   		BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
>
>   	if (wifi_under_5g) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], RunCoexistMechanism(), run 5G coex setting!!<===\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], RunCoexistMechanism(), run 5G coex setting!!<===\n");
>   		halbtc8821a2ant_coex_under_5g(btcoexist);
>   		return;
>   	}
> @@ -3201,81 +3189,82 @@ static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
>   	algorithm = halbtc8821a2ant_action_algorithm(btcoexist);
>   	if (coex_sta->c2h_bt_inquiry_page &&
>   	    (BT_8821A_2ANT_COEX_ALGO_PANHS != algorithm)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], BT is under inquiry/page scan !!\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], BT is under inquiry/page scan !!\n");
>   		halbtc8821a2ant_bt_inquiry_page(btcoexist);
>   		return;
>   	}
>
>   	coex_dm->cur_algorithm = algorithm;
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
>
>   	if (halbtc8821a2ant_is_common_action(btcoexist)) {
> -		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -			  "[BTCoex], Action 2-Ant common.\n");
> +		btc_alg_dbg(ALGO_TRACE,
> +			    "[BTCoex], Action 2-Ant common\n");
>   		coex_dm->reset_tdma_adjust = true;
>   	} else {
>   		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], pre_algorithm = %d, cur_algorithm = %d\n",
> -			coex_dm->pre_algorithm, coex_dm->cur_algorithm);
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], pre_algorithm = %d, cur_algorithm = %d\n",
> +				    coex_dm->pre_algorithm,
> +				    coex_dm->cur_algorithm);
>   			coex_dm->reset_tdma_adjust = true;
>   		}
>   		switch (coex_dm->cur_algorithm) {
>   		case BT_8821A_2ANT_COEX_ALGO_SCO:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = SCO.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = SCO\n");
>   			halbtc8821a2ant_action_sco(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID\n");
>   			halbtc8821a2ant_action_hid(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = A2DP\n");
>   			halbtc8821a2ant_action_a2dp(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_A2DP_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = A2DP+PAN(HS).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = A2DP+PAN(HS)\n");
>   			halbtc8821a2ant_action_a2dp_pan_hs(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR).\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)\n");
>   			halbtc8821a2ant_action_pan_edr(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_PANHS:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = HS mode.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HS mode\n");
>   			halbtc8821a2ant_action_pan_hs(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_PANEDR_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = PAN+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN+A2DP\n");
>   			halbtc8821a2ant_action_pan_edr_a2dp(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_PANEDR_HID:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)+HID.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)+HID\n");
>   			halbtc8821a2ant_action_pan_edr_hid(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP+PAN.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID+A2DP+PAN\n");
>   			btc8821a2ant_act_hid_a2dp_pan_edr(btcoexist);
>   			break;
>   		case BT_8821A_2ANT_COEX_ALGO_HID_A2DP:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP.\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = HID+A2DP\n");
>   			halbtc8821a2ant_action_hid_a2dp(btcoexist);
>   			break;
>   		default:
> -			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -				  "[BTCoex], Action 2-Ant, algorithm = coexist All Off!!\n");
> +			btc_alg_dbg(ALGO_TRACE,
> +				    "[BTCoex], Action 2-Ant, algorithm = coexist All Off!!\n");
>   			halbtc8821a2ant_coex_all_off(btcoexist);
>   			break;
>   		}
> @@ -3294,8 +3283,8 @@ void ex_halbtc8821a2ant_init_hwconfig(struct btc_coexist *btcoexist)
>   {
>   	u8 u1tmp = 0;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], 2Ant Init HW Config!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], 2Ant Init HW Config!!\n");
>
>   	/* backup rf 0x1e value */
>   	coex_dm->bt_rf0x1e_backup =
> @@ -3328,8 +3317,8 @@ ex_halbtc8821a2ant_init_coex_dm(
>   	struct btc_coexist *btcoexist
>   	)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -		  "[BTCoex], Coex Mechanism Init!!\n");
> +	btc_iface_dbg(INTF_INIT,
> +		      "[BTCoex], Coex Mechanism Init!!\n");
>
>   	halbtc8821a2ant_init_coex_dm(btcoexist);
>   }
> @@ -3574,13 +3563,13 @@ ex_halbtc8821a2ant_display_coex_info(
>   void ex_halbtc8821a2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_IPS_ENTER == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS ENTER notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS ENTER notify\n");
>   		coex_sta->under_ips = true;
>   		halbtc8821a2ant_coex_all_off(btcoexist);
>   	} else if (BTC_IPS_LEAVE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], IPS LEAVE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], IPS LEAVE notify\n");
>   		coex_sta->under_ips = false;
>   		/*halbtc8821a2ant_init_coex_dm(btcoexist);*/
>   	}
> @@ -3589,12 +3578,12 @@ void ex_halbtc8821a2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_halbtc8821a2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_LPS_ENABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS ENABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS ENABLE notify\n");
>   		coex_sta->under_lps = true;
>   	} else if (BTC_LPS_DISABLE == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], LPS DISABLE notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], LPS DISABLE notify\n");
>   		coex_sta->under_lps = false;
>   	}
>   }
> @@ -3602,22 +3591,22 @@ void ex_halbtc8821a2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
>   void ex_halbtc8821a2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_SCAN_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN START notify\n");
>   	} else if (BTC_SCAN_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], SCAN FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], SCAN FINISH notify\n");
>   	}
>   }
>
>   void ex_halbtc8821a2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
>   {
>   	if (BTC_ASSOCIATE_START == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT START notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT START notify\n");
>   	} else if (BTC_ASSOCIATE_FINISH == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], CONNECT FINISH notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], CONNECT FINISH notify\n");
>   	}
>   }
>
> @@ -3629,11 +3618,11 @@ void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
>   	u8	wifi_central_chnl;
>
>   	if (BTC_MEDIA_CONNECT == type) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA connect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA connect notify\n");
>   	} else {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], MEDIA disconnect notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], MEDIA disconnect notify\n");
>   	}
>
>   	/* only 2.4G we need to inform bt the chnl mask*/
> @@ -3654,9 +3643,11 @@ void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
>   	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
>   	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
> -		  "[BTCoex], FW write 0x66 = 0x%x\n",
> -		h2c_parameter[0]<<16|h2c_parameter[1]<<8|h2c_parameter[2]);
> +	btc_alg_dbg(ALGO_TRACE_FW_EXEC,
> +		    "[BTCoex], FW write 0x66 = 0x%x\n",
> +		    h2c_parameter[0] << 16 |
> +		    h2c_parameter[1] << 8 |
> +		    h2c_parameter[2]);
>
>   	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>   }
> @@ -3664,8 +3655,8 @@ void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
>   void ex_halbtc8821a2ant_special_packet_notify(struct btc_coexist *btcoexist,
>   					      u8 type) {
>   	if (type == BTC_PACKET_DHCP) {
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -			  "[BTCoex], DHCP Packet notify\n");
> +		btc_iface_dbg(INTF_NOTIFY,
> +			      "[BTCoex], DHCP Packet notify\n");
>   	}
>   }
>
> @@ -3685,19 +3676,19 @@ void ex_halbtc8821a2ant_bt_info_notify(struct btc_coexist *btcoexist,
>   		rsp_source = BT_INFO_SRC_8821A_2ANT_WIFI_FW;
>   	coex_sta->bt_info_c2h_cnt[rsp_source]++;
>
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Bt info[%d], length = %d, hex data = [",
> -		  rsp_source, length);
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Bt info[%d], length = %d, hex data = [",
> +		      rsp_source, length);
>   	for (i = 0; i < length; i++) {
>   		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
>   		if (i == 1)
>   			bt_info = tmp_buf[i];
>   		if (i == length-1) {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x]\n", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x]\n", tmp_buf[i]);
>   		} else {
> -			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -				  "0x%02x, ", tmp_buf[i]);
> +			btc_iface_dbg(INTF_NOTIFY,
> +				      "0x%02x, ", tmp_buf[i]);
>   		}
>   	}
>
> @@ -3823,8 +3814,8 @@ void ex_halbtc8821a2ant_bt_info_notify(struct btc_coexist *btcoexist,
>
>   void ex_halbtc8821a2ant_halt_notify(struct btc_coexist *btcoexist)
>   {
> -	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
> -		  "[BTCoex], Halt notify\n");
> +	btc_iface_dbg(INTF_NOTIFY,
> +		      "[BTCoex], Halt notify\n");
>
>   	halbtc8821a2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
>   	ex_halbtc8821a2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
> @@ -3837,31 +3828,31 @@ void ex_halbtc8821a2ant_periodical(struct btc_coexist *btcoexist)
>   	struct btc_board_info *board_info = &btcoexist->board_info;
>   	struct btc_stack_info *stack_info = &btcoexist->stack_info;
>
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "[BTCoex], ==========================Periodical===========================\n");
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "[BTCoex], ==========================Periodical===========================\n");
>
>   	if (dis_ver_info_cnt <= 5) {
>   		dis_ver_info_cnt += 1;
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> -			  board_info->pg_ant_num,
> -			  board_info->btdm_ant_num,
> -			  board_info->btdm_ant_pos);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> -			  ((stack_info->profile_notified) ? "Yes" : "No"),
> -			  stack_info->hci_version);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
> +			      board_info->pg_ant_num,
> +			      board_info->btdm_ant_num,
> +			      board_info->btdm_ant_pos);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
> +			      stack_info->profile_notified ? "Yes" : "No",
> +			      stack_info->hci_version);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>   				   &bt_patch_ver);
>   		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> -			  glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
> -			  fw_ver, bt_patch_ver, bt_patch_ver);
> -		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
> -			  "[BTCoex], ****************************************************************\n");
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
> +			      glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
> +			      fw_ver, bt_patch_ver, bt_patch_ver);
> +		btc_iface_dbg(INTF_INIT,
> +			      "[BTCoex], ****************************************************************\n");
>   	}
>
>   	halbtc8821a2ant_query_bt_info(btcoexist);
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> index b2791c8..996f2f7 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> @@ -141,8 +141,8 @@ static u8 halbtc_get_wifi_central_chnl(struct btc_coexist *btcoexist)
>
>   	if (rtlphy->current_channel != 0)
>   		chnl = rtlphy->current_channel;
> -	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
> -		  "static halbtc_get_wifi_central_chnl:%d\n", chnl);
> +	btc_alg_dbg(ALGO_TRACE,
> +		    "static halbtc_get_wifi_central_chnl:%d\n", chnl);
>   	return chnl;
>   }
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.h
> index 0a903ea..6008ecb 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.h
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.h
> @@ -116,12 +116,17 @@ extern u32 btc_dbg_type[];
>   #define		WIFI_P2P_GO_CONNECTED			BIT3
>   #define		WIFI_P2P_GC_CONNECTED			BIT4
>
> -#define	BTC_PRINT(dbgtype, dbgflag, printstr, ...)		\
> -	do {							\
> -		if (unlikely(btc_dbg_type[dbgtype] & dbgflag)) {\
> -			printk(printstr, ##__VA_ARGS__);	\
> -		}						\
> -	} while (0)
> +#define	btc_alg_dbg(dbgflag, fmt, ...)					\
> +do {									\
> +	if (unlikely(btc_dbg_type[BTC_MSG_ALGORITHM] & dbgflag))	\
> +		printk(KERN_DEBUG fmt, ##__VA_ARGS__);			\
> +} while (0)
> +#define	btc_iface_dbg(dbgflag, fmt, ...)				\
> +do {									\
> +	if (unlikely(btc_dbg_type[BTC_MSG_INTERFACE] & dbgflag))	\
> +		printk(KERN_DEBUG fmt, ##__VA_ARGS__);			\
> +} while (0)
> +
>
>   #define	BTC_RSSI_HIGH(_rssi_)	\
>   	((_rssi_ == BTC_RSSI_STATE_HIGH ||	\
>

Joe,

The patch looks good, but it has conflict in 
drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c with the patch 
[PATCH 2/2] rtlwifi: btcoexist: Implement antenna selection that I submitted 
yesterday.

Larry
