From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/2] wcn36xx: Pass used skb to ieee80211_tx_status()
Date: Thu, 27 Apr 2017 10:22:12 +0200
Message-ID: <1493281332.2529.1.camel@sipsolutions.net>
References: <20170426220444.10539-1-bjorn.andersson@linaro.org>
         (sfid-20170427_000624_047560_805C9599)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        David Brown <david.brown-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Nicolas Dechesne <nicolas.dechesne-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170426220444.10539-1-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20170427_000624_047560_805C9599)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> @@ -371,7 +371,7 @@ static void reap_tx_dxes(struct wcn36xx *wcn,
> struct wcn36xx_dxe_ch *ch)
>  			info = IEEE80211_SKB_CB(ctl->skb);
>  			if (!(info->flags &
> IEEE80211_TX_CTL_REQ_TX_STATUS)) {
>  				/* Keep frame until TX status comes
> */
> -				ieee80211_free_txskb(wcn->hw, ctl-
> >skb);
> +				ieee80211_tx_status(wcn->hw, ctl-
> >skb);
> 

I don't think this is a good idea. This code intentionally checked if
TX status was requested, and if not then it doesn't go to the effort of
building it.

As it is with your patch, it'll go and report the TX status without any
TX status information - which is handled in wcn36xx_dxe_tx_ack_ind()
for those frames needing it.

johannes
