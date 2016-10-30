From: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine macpower
Date: Sun, 30 Oct 2016 08:00:44 -0400
Message-ID: <wrfjpomidp1v.fsf@redhat.com>
References: <cover.1477769750.git.john@zgus.com> <20161030102112.GA5789@cube>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Heenan <john-AMlJbUfTsso@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161030102112.GA5789@cube> (John Heenan's message of "Sun, 30
        Oct 2016 20:21:12 +1000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John Heenan <john-AMlJbUfTsso@public.gmane.org> writes:
> Code tests show data returned by rtl8xxxu_read8(priv, REG_CR), used to set
> macpower, is never 0xea. It is only ever 0x01 (first time after modprobe)
> using wpa_supplicant and 0x00 thereafter using wpa_supplicant. These results
> occurs with 'Fix for authentication failure' [PATCH 1/2] in place.
>
> Whatever was returned, code tests always showed that at least
> rtl8xxxu_init_queue_reserved_page(priv);
> is always required. Not called if macpower set to true.
>
> Please see cover letter, [PATCH 0/2], for more information from tests.
>
> For rtl8xxxu-devel branch of git.kernel.org/pub/scm/linux/kernel/git/jes/linux.git
>
> Signed-off-by: John Heenan <john-AMlJbUfTsso@public.gmane.org>
> ---
>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> index f25b4df..aae05f3 100644
> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> @@ -3904,6 +3904,7 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
>  		macpower = false;
>  	else
>  		macpower = true;
> +	macpower = false; // Code testing shows macpower must always be set to false to avoid failure
>  
>  	ret = fops->power_on(priv);
>  	if (ret < 0) {

Sorry but this patch is neither serious nor acceptable. First of all,
hardcoding macpower like this right after an if statement is plain
wrong, second your comments violate all kernel rules.

Second, you argue this was tested using code test - on which device? Did
you test it on all rtl8xxxu based devices or just rtl8723bu?

NACK

Jes
