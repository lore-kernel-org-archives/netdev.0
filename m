From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH v2] net: wireless: rtlwifi: rtl8192cu: hw.c:  Cleaning up if statement that always evaluates to false
Date: Sat, 21 Jun 2014 23:34:41 +0200
Message-ID: <4791769.OUXNIfgtp2@al>
References: <1403384437-9615-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <1403384437-9615-2-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403384437-9615-2-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 June 2014 23:00:37 Rickard Strandqvist wrote:
> I found a logical error in an if statement that always evaluates to false.
> 
> This has after same discussion resulted in that we add a macro to handle this.

The subject is still wrong (it is not a cleanup, but a fix) and the
commit message could also be improved (no need to mention the
discussion, just say why it was necessary and what you did to fix it).

Suggested text:

    rtlwifi/rtl8192c[eu]: fix media status register mask

    bt_msr & 0xfc will never match 0x3. Fix this by using a mask that
    actually matches the available types.

With that, you can add my
Reviewed-by: Peter Wu <peter@lekensteyn.nl>
(oh, and please mail me at @lekensteyn.nl for patches)

Also, when using a cover letter, you are supposed to group your changes. Not
add a single commit to each cover letter. If you made three sequential changes
for example, then you can generate your patches with:

    mkdir /tmp/patches
    git format-patch --cover-letter -o /tmp/patches/ HEAD~3

Then review the files in /tmp/patches/ and if you are satisfied:

    git send-email --to linux-wireless@... --cc ... /tmp/patches/*

Kind regards,
Peter

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/reg.h |    1 +
>  drivers/net/wireless/rtlwifi/rtl8192cu/hw.c  |    2 +-
>  3 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> index 55adf04..5050938 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> @@ -1206,7 +1206,7 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
>  
>  	rtl_write_byte(rtlpriv, (MSR), bt_msr);
>  	rtlpriv->cfg->ops->led_control(hw, ledaction);
> -	if ((bt_msr & 0xfc) == MSR_AP)
> +	if ((bt_msr & MSR_MASK) == MSR_AP)
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
>  	else
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
> index ed703a1..dc8460c 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
> @@ -375,6 +375,7 @@
>  #define	MSR_ADHOC				0x01
>  #define	MSR_INFRA				0x02
>  #define	MSR_AP					0x03
> +#define	MSR_MASK				0x03
>  
>  #define	RRSR_RSC_OFFSET				21
>  #define	RRSR_SHORT_OFFSET			23
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> index 07cb06d..87c0a27 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> @@ -1360,7 +1360,7 @@ static int _rtl92cu_set_media_status(struct ieee80211_hw *hw,
>  	}
>  	rtl_write_byte(rtlpriv, (MSR), bt_msr);
>  	rtlpriv->cfg->ops->led_control(hw, ledaction);
> -	if ((bt_msr & 0xfc) == MSR_AP)
> +	if ((bt_msr & MSR_MASK) == MSR_AP)
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
>  	else
>  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
> 
