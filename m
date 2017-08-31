From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: refactor code in halbtcoutsrc module
Date: Thu, 31 Aug 2017 10:25:30 -0500
Message-ID: <08aeadde-8a44-c49f-bc64-5b91226d4cec@lwfinger.net>
References: <20170830164602.GA16413@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830164602.GA16413@embeddedgus>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 11:46 AM, Gustavo A. R. Silva wrote:
> Function halbtc_get_wifi_rssi always returns rtlpriv->dm.undec_sm_pwdb.
> So this function can be removed and the value of
> rtlpriv->dm.undec_sm_pwdb assigned to *s32_tmp directly.
> 
> This issue was first reported by Coverity as "identical code for different
> branches" in function halbtc_get_wifi_rssi.
> 
> Addresses-Coverity-ID: 1226793
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
> This code was reported by Coverity and it was tested by compilation only.
> Chances are this may be a copy/paste error in function
> halbtc_get_wifi_rssi. Please, verify.
> Also, notice this code has been there since 2014.

The value of *s32_tmp is not dependent on the link state, thus this patch is 
correct, but I request that it be changed. Future developments will modify 
halbtc_get_wifi_rssi() making it more complicated and not as easily inlined as 
this patch. In short, if you remove it here, we will have to add it later.

Thanks,

Larrt

> 
>   .../net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c   | 13 +------------
>   1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> index c1eacd8..2a47b97 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c
> @@ -373,17 +373,6 @@ u32 halbtc_get_wifi_link_status(struct btc_coexist *btcoexist)
>   	return ret_val;
>   }
>   
> -static s32 halbtc_get_wifi_rssi(struct rtl_priv *rtlpriv)
> -{
> -	int undec_sm_pwdb = 0;
> -
> -	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
> -		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
> -	else /* associated entry pwdb */
> -		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
> -	return undec_sm_pwdb;
> -}
> -
>   static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
>   {
>   	struct btc_coexist *btcoexist = (struct btc_coexist *)void_btcoexist;
> @@ -479,7 +468,7 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
>   		*bool_tmp = false;
>   		break;
>   	case BTC_GET_S4_WIFI_RSSI:
> -		*s32_tmp = halbtc_get_wifi_rssi(rtlpriv);
> +		*s32_tmp = rtlpriv->dm.undec_sm_pwdb;
>   		break;
>   	case BTC_GET_S4_HS_RSSI:
>   		*s32_tmp = 0;
> 
