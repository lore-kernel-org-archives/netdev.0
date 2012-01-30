From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1] wireless: move ifs' in _rtl92c_store_pwrIndex_diffrate_offset
 into elseif statements
Date: Mon, 30 Jan 2012 17:38:23 -0600
Message-ID: <4F2729EF.8090309@lwfinger.net>
References: <1327906245-8200-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	paul.gortmaker@windriver.com, joe@perches.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Devendra.Naga" <devendra.aaru@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327906245-8200-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 12:50 AM, Devendra.Naga wrote:
> From: "Devendra.Naga"<devendra.aaru@gmail.com>
>
>          The regaddr is compared against different rates in each case and the powerlevels are set
>          accordingly. as this can match for the first if and we still check for other powerlevels too,
>          use else if ratherthan using if statements
> Signed-off-by: Devendra.Naga<devendra.aaru@gmail.com>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   47 +++++++------------
>   1 files changed, 17 insertions(+), 30 deletions(-)

Another bad patch title. The component changed is rtlwifi: rtl8192c:, not wireless.

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> index 22e998d..cb11e5a 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
> @@ -260,106 +260,93 @@ void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
>   			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][0]);
> -	}
> -	if (regaddr == RTXAGC_A_RATE54_24) {
> +	} else if (regaddr == RTXAGC_A_RATE54_24) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][1] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][1]);
> -	}
> -	if (regaddr == RTXAGC_A_CCK1_MCS32) {
> +	} else if (regaddr == RTXAGC_A_CCK1_MCS32) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][6] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][6]);
> -	}
> -	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11&&  bitmask == 0xffffff00) {
> +	} else if (regaddr == RTXAGC_B_CCK11_A_CCK2_11&&
> +		bitmask == 0xffffff00) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][7] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][7]);
> -	}
> -	if (regaddr == RTXAGC_A_MCS03_MCS00) {
> +	} else if (regaddr == RTXAGC_A_MCS03_MCS00) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][2] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][2]);
> -	}
> -	if (regaddr == RTXAGC_A_MCS07_MCS04) {
> +	} else if (regaddr == RTXAGC_A_MCS07_MCS04) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][3] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][3]);
> -	}
> -	if (regaddr == RTXAGC_A_MCS11_MCS08) {
> +	} else if (regaddr == RTXAGC_A_MCS11_MCS08) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][4] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][4]);
> -	}
> -	if (regaddr == RTXAGC_A_MCS15_MCS12) {
> +	} else if (regaddr == RTXAGC_A_MCS15_MCS12) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][5] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][5]);
> -	}
> -	if (regaddr == RTXAGC_B_RATE18_06) {
> +	} else if (regaddr == RTXAGC_B_RATE18_06) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][8] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][8]);
> -	}
> -	if (regaddr == RTXAGC_B_RATE54_24) {
> +	} else if (regaddr == RTXAGC_B_RATE54_24) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][9] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][9]);
> -	}
> -	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
> +	} else if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][14] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][14]);
> -	}
> -	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11&&  bitmask == 0x000000ff) {
> +	} else if (regaddr == RTXAGC_B_CCK11_A_CCK2_11&&
> +		bitmask == 0x000000ff) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][15] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][15]);
> -	}
> -	if (regaddr == RTXAGC_B_MCS03_MCS00) {
> +	} else if (regaddr == RTXAGC_B_MCS03_MCS00) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][10] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][10]);
> -	}
> -	if (regaddr == RTXAGC_B_MCS07_MCS04) {
> +	} else if (regaddr == RTXAGC_B_MCS07_MCS04) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][11] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][11]);
> -	}
> -	if (regaddr == RTXAGC_B_MCS11_MCS08) {
> +	} else if (regaddr == RTXAGC_B_MCS11_MCS08) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][12] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
>   			 rtlphy->pwrgroup_cnt,
>   			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][12]);
> -	}
> -	if (regaddr == RTXAGC_B_MCS15_MCS12) {
> +	} else if (regaddr == RTXAGC_B_MCS15_MCS12) {
>   		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][13] = data;
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>   			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
