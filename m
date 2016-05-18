From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 1/1] rtlwifi: rtl8723be: avoid undefined behavior
Date: Wed, 18 May 2016 07:12:08 -0500
Message-ID: <573C5C18.8030300@lwfinger.net>
References: <1463525183-11483-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463525183-11483-1-git-send-email-xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/17/2016 05:46 PM, Heinrich Schuchardt wrote:
> Do not return undefined value for transmission power
> if the rate is invalid.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
> ---
>   drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
> index 445f681..c5ca9df 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
> @@ -1019,7 +1019,7 @@ static u8 _rtl8723be_get_txpower_index(struct ieee80211_hw *hw, u8 path,
>   	struct rtl_priv *rtlpriv = rtl_priv(hw);
>   	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
>   	u8 index = (channel - 1);
> -	u8 txpower;
> +	u8 txpower = 0;
>   	u8 power_diff_byrate = 0;
>
>   	if (channel > 14 || channel < 1) {

Did gcc give you a warning about this variable not being initialized? Mine does 
not. In any case, this change is appropriate.

Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Thanks,

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
