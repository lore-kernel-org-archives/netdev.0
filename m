From: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Subject: Re: [PATCH 6/7] net: wireless: wcn36xx: remove powersaving for wcn3620
Date: Mon, 9 Feb 2015 09:54:23 -0800
Message-ID: <CAJAp7OhcFTuYfc7JOKW1SrVRbucuSWg5jcFaoVnSDgBxsyo2ng@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051111.31866.39208.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150118051111.31866.39208.stgit-FDDIDLfWL9/T9rR/E2HzMujRB4CPm7EUkgzjau31qRg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 17, 2015 at 9:11 PM, Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
> WCN3620 powersaving mode is not stable.  Disable it if we're
> on a wcn3620 chip type.
>
> Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/wireless/ath/wcn36xx/main.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
> index c4178c7..569d45b 100644
> --- a/drivers/net/wireless/ath/wcn36xx/main.c
> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
> @@ -924,6 +924,10 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
>                 IEEE80211_HW_AMPDU_AGGREGATION |
>                 IEEE80211_HW_TIMING_BEACON_ONLY;
>
> +       /* 3620 powersaving currently unstable */
> +       if (wcn->chip_version == WCN36XX_CHIP_3620)
> +               wcn->hw->flags &= ~IEEE80211_HW_SUPPORTS_PS;
> +

Hi Andy,

I have the same problem (Data Abort Exception in wcnss) on 3680, this
with my wip smd code and a hacked up remoteproc-pil. I haven't spent
any effort on debugging this, but it looks like it's something related
to what we have ported to mainline (or lack thereof) rather than a
3620 specific issue.

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
