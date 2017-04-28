From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] wcn36xx: Pass used skb to ieee80211_tx_status()
Date: Fri, 28 Apr 2017 16:42:47 -0700
Message-ID: <20170428234247.GQ15143@minitux>
References: <20170426220444.10539-1-bjorn.andersson@linaro.org>
 <1493281332.2529.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        David Brown <david.brown-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Nicolas Dechesne <nicolas.dechesne-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1493281332.2529.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu 27 Apr 01:22 PDT 2017, Johannes Berg wrote:

> 
> > @@ -371,7 +371,7 @@ static void reap_tx_dxes(struct wcn36xx *wcn,
> > struct wcn36xx_dxe_ch *ch)
> >  			info = IEEE80211_SKB_CB(ctl->skb);
> >  			if (!(info->flags &
> > IEEE80211_TX_CTL_REQ_TX_STATUS)) {
> >  				/* Keep frame until TX status comes
> > */
> > -				ieee80211_free_txskb(wcn->hw, ctl-
> > >skb);
> > +				ieee80211_tx_status(wcn->hw, ctl-
> > >skb);
> > 
> 
> I don't think this is a good idea.

Thanks for letting me know :)

> This code intentionally checked if TX status was requested, and if not
> then it doesn't go to the effort of building it.
> 

What I'm finding puzzling is the fact that the only caller of
ieee80211_led_tx() is ieee80211_tx_status() and it seems like drivers,
such as ath10k, call this for each packet handled - but I'm likely
missing something.

> As it is with your patch, it'll go and report the TX status without any
> TX status information - which is handled in wcn36xx_dxe_tx_ack_ind()
> for those frames needing it.
> 

Right, it doesn't sound desired. However, during normal operation I'm
not seeing IEEE80211_TX_CTL_REQ_TX_STATUS being set and as such
ieee80211_led_tx() is never called.

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
