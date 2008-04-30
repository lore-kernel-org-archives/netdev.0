From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Wed, 30 Apr 2008 17:34:10 +0200
Message-ID: <200804301734.11804.IvDoorn@gmail.com>
References: <20080430124055.091382000@sipsolutions.net> <1209566743.18659.30.camel@johannes.berg> <1209567609.18659.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209567609.18659.33.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Don't want to spoil the fun, but the following part doesn't compile
when CONFIG_MAC80211_QOS is not set.

In the following occurences struct ieee80211_local *local needs to be defined.

>  void ieee80211_start_queues(struct ieee80211_hw *hw)
>  {
> -	struct ieee80211_local *local = hw_to_local(hw);
> +#ifdef CONFIG_MAC80211_QOS
>  	int i;
>  
> -	for (i = 0; i < local->hw.queues; i++)
> -		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
> -	if (!ieee80211_qdisc_installed(local->mdev))
> -		netif_start_queue(local->mdev);
> +	for (i = 0; i < hw->queues; i++)
> +		ieee80211_start_queue(hw, i);
> +#else

	struct ieee80211_local *local = hw_to_local(hw);

> +	netif_start_queue(local->mdev);
> +#endif
>  }
>  EXPORT_SYMBOL(ieee80211_start_queues);
>  
>  void ieee80211_stop_queues(struct ieee80211_hw *hw)
>  {
> +#ifdef CONFIG_MAC80211_QOS
>  	int i;
>  
>  	for (i = 0; i < hw->queues; i++)
>  		ieee80211_stop_queue(hw, i);
> +#else

	struct ieee80211_local *local = hw_to_local(hw);

> +	netif_stop_queue(local->mdev);
> +#endif
>  }
>  EXPORT_SYMBOL(ieee80211_stop_queues);
>  
>  void ieee80211_wake_queues(struct ieee80211_hw *hw)
>  {
> +#ifdef CONFIG_MAC80211_QOS
>  	int i;
>  
>  	for (i = 0; i < hw->queues; i++)
>  		ieee80211_wake_queue(hw, i);
> +#else

	struct ieee80211_local *local = hw_to_local(hw);

> +	netif_wake_queue(local->mdev);
> +#endif
>  }
>  EXPORT_SYMBOL(ieee80211_wake_queues);

Ivo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
