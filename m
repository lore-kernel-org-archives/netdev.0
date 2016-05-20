From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: use kmemdup
Date: Fri, 20 May 2016 09:53:42 +0200
Message-ID: <c7b2489d-8ae8-e1c5-ab85-ba88d27c9318@broadcom.com>
References: <1463666357-16719-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Muhammad Falak R Wani <falakreyaz@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463666357-16719-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19-5-2016 15:59, Muhammad Falak R Wani wrote:
> Use kmemdup when some other buffer is immediately copied into allocated
> region. It replaces call to allocation followed by memcpy, by a single
> call to kmemdup.

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> index d0631b6..705adaa 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> @@ -6699,11 +6699,10 @@ struct brcmf_cfg80211_info *brcmf_cfg80211_attach(struct brcmf_pub *drvr,
>  		return NULL;
>  	}
>  
> -	ops = kzalloc(sizeof(*ops), GFP_KERNEL);
> +	ops = kmemdup(&brcmf_cfg80211_ops, sizeof(*ops), GFP_KERNEL);
>  	if (!ops)
>  		return NULL;
>  
> -	memcpy(ops, &brcmf_cfg80211_ops, sizeof(*ops));
>  	ifp = netdev_priv(ndev);
>  #ifdef CONFIG_PM
>  	if (brcmf_feat_is_enabled(ifp, BRCMF_FEAT_WOWL_GTK))
> 
