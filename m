From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8723be: phy.c:  Remove unused
 function
Date: Sat, 20 Dec 2014 18:46:10 -0600
Message-ID: <54961852.8000403@lwfinger.net>
References: <1419116358-13223-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1419116358-13223-1-git-send-email-rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/20/2014 04:59 PM, Rickard Strandqvist wrote:
> Remove the function rtl8723be_phy_get_txpower_level() that is not used anywhere.
>
> This was partially found by using a static code analysis program called cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/rtl8723be/phy.c |   25 -------------------------
>   drivers/net/wireless/rtlwifi/rtl8723be/phy.h |    2 --
>   2 files changed, 27 deletions(-)

Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
> index 20dcc25..b7b73cb 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
> @@ -874,31 +874,6 @@ void rtl8723be_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
>   		  ROFDM0_RXDETECTOR3, rtlphy->framesync);
>   }
>
> -void rtl8723be_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
> -{
> -	struct rtl_priv *rtlpriv = rtl_priv(hw);
> -	struct rtl_phy *rtlphy = &rtlpriv->phy;
> -	u8 txpwr_level;
> -	long txpwr_dbm;
> -
> -	txpwr_level = rtlphy->cur_cck_txpwridx;
> -	txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_B,
> -						 txpwr_level);
> -	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
> -	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G, txpwr_level) >
> -	    txpwr_dbm)
> -		txpwr_dbm =
> -		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
> -						 txpwr_level);
> -	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
> -	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
> -					 txpwr_level) > txpwr_dbm)
> -		txpwr_dbm =
> -		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
> -						 txpwr_level);
> -	*powerlevel = txpwr_dbm;
> -}
> -
>   static u8 _rtl8723be_phy_get_ratesection_intxpower_byrate(enum radio_path path,
>   							  u8 rate)
>   {
> diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.h b/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
> index 6339738..9021d47 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
> @@ -114,8 +114,6 @@ bool rtl8723be_phy_mac_config(struct ieee80211_hw *hw);
>   bool rtl8723be_phy_bb_config(struct ieee80211_hw *hw);
>   bool rtl8723be_phy_rf_config(struct ieee80211_hw *hw);
>   void rtl8723be_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
> -void rtl8723be_phy_get_txpower_level(struct ieee80211_hw *hw,
> -				     long *powerlevel);
>   void rtl8723be_phy_set_txpower_level(struct ieee80211_hw *hw,
>   				     u8 channel);
>   void rtl8723be_phy_scan_operation_backup(struct ieee80211_hw *hw,
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
