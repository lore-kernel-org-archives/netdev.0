From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] 4.9.13 brcmfmac: fix use-after-free on resume
Date: Mon, 6 Mar 2017 14:00:09 +0100
Message-ID: <3626494c-8482-d003-1c83-e6171f6990a8@broadcom.com>
References: <CAMVG2stHA9qSUiRFBW=-4jhSMk-o7Frext+Qf9JK3Fo822XHhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel J Blueman <daniel-JCXMqzvhRcvYtjvyW6yDsg@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMVG2stHA9qSUiRFBW=-4jhSMk-o7Frext+Qf9JK3Fo822XHhw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

+ linux-wireless

On 6-3-2017 8:14, Daniel J Blueman wrote:
> KASAN reported 'struct wireless_dev wdev' was read after being freed.
> Fix by freeing after the access.

I would rather like to see the KASAN report, because something is off
here. This function is called with wdev as a parameter so how can it be
accessed after free here? brcmf_remove_interface() does not free the
wdev nor the brcmf_cfg80211_vif instance which contains the wdev.

Regards,
Arend

> Signed-off-by: Daniel J Blueman <daniel-JCXMqzvhRcvYtjvyW6yDsg@public.gmane.org>
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> index de19c7c..aa0f470 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> @@ -2288,12 +2288,13 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy,
> struct wireless_dev *wdev)
>                 else
>                         err = 0;
>         }
> -       brcmf_remove_interface(vif->ifp, true);
> 
> -       brcmf_cfg80211_arm_vif_event(cfg, NULL);
>         if (vif->wdev.iftype != NL80211_IFTYPE_P2P_DEVICE)
>                 p2p->bss_idx[P2PAPI_BSSCFG_CONNECTION].vif = NULL;
> 
> +       brcmf_remove_interface(vif->ifp, true);
> +       brcmf_cfg80211_arm_vif_event(cfg, NULL);
> +
>         return err;
>  }
> 
