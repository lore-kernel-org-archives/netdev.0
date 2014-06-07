From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: hw.c:  Cleaning up conjunction always evaluates to false
Date: Sat, 07 Jun 2014 17:02:30 +0200
Message-ID: <1670424.dXK6NPb10R@al>
References: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lekensteyn.nl ([178.21.112.251]:40084 "EHLO lekensteyn.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbaFGPaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2014 11:30:00 -0400
In-Reply-To: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 07 June 2014 16:30:19 Rickard Strandqvist wrote:
> Expression '(X & 0xfc) == 0x3' is always false

While this is true, I believe that some other mistake is made.

> I chose to remove this code, because it will not make any difference.
> But obviously it is rather a properly designed if statement that is needed.
> 
> This was partly found using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/wireless/rtlwifi/rtl8192de/hw.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> index 2b08671..a1520d5 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
> @@ -1128,10 +1128,7 @@ static int _rtl92de_set_media_status(struct ieee80211_hw *hw,
>  	}
>  	rtl_write_byte(rtlpriv, REG_CR + 2, bt_msr);
>  	rtlpriv->cfg->ops->led_control(hw, ledaction);
> -	if ((bt_msr & 0xfc) == MSR_AP)

If you look a few lines up, then you see that bt_msr is OR-ed with MSR_AP
for AP interfaces. The 0xfc should be 0x03, see other drivers for example:

rtl8723ae/hw.c:1112:    if ((bt_msr & 0x03) == MSR_AP)
rtl8723be/hw.c:1200:    if ((bt_msr & 0x03) == MSR_AP)
rtl8192cu/hw.c:1363:    if ((bt_msr & 0xfc) == MSR_AP)
rtl8192ce/hw.c:1209:    if ((bt_msr & 0xfc) == MSR_AP)
rtl8188ee/hw.c:1234:    if ((bt_msr & 0xfc) == MSR_AP)
rtl8192de/hw.c:1131:    if ((bt_msr & 0xfc) == MSR_AP)

> -		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
> -	else
> -		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
> +	rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
>  	return 0;
>  }

Kind regards,
Peter
