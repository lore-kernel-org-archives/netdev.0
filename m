From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8723be: hw.c:  Cleaning up
 if statement that always evaluates to false
Date: Sun, 8 Jun 2014 13:35:15 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406081333550.19183@chino.kir.corp.google.com>
References: <1402191743-26177-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Joe Perches <joe@perches.com>, Peter Wu <lekensteyn@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402191743-26177-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 8 Jun 2014, Rickard Strandqvist wrote:

> I find a logical error in an if statement '(X & 0xfc) == 0x3' is always false
> 

Where is the 0xfc that your converting?

> After pointing this out, Larry Finger informed what would be the correct one.
> '(X & 0x3) == 0x3'
> 

This is already what it is, just say that you're replacing it with the 
constant.

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/wireless/rtlwifi/rtl8723be/hw.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
> index 0fdf090..b61044f 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
> @@ -1197,7 +1197,7 @@ static int _rtl8723be_set_media_status(struct ieee80211_hw *hw,
>  	}
>  	rtl_write_byte(rtlpriv, (MSR), bt_msr);
>  	rtlpriv->cfg->ops->led_control(hw, ledaction);
> -	if ((bt_msr & 0x03) == MSR_AP)
> +	if ((bt_msr & MSR_AP) == MSR_AP)
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
>  	else
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
