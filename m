From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-06-30
Date: Wed, 30 Jun 2010 12:05:51 -0700 (PDT)
Message-ID: <20100630.120551.170116973.davem@davemloft.net>
References: <20100630185319.GA2618@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100630185319.GA2618-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 30 Jun 2010 14:53:20 -0400

> Here are a few more fixes intended for 2.6.35.  Included are a couple of
> small regression fixes for iwlwifi, one that causes connection stalls with
> 802.11n on some devices and another which could disable multicast traffic.
> Also included is an ath9k fix which avoids a null pointer dereference
> resulting from a timer leak.
> 
> Please let me know if there are problems!
...
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Pulled, thanks John.

> @@ -1329,6 +1328,12 @@ void iwl_configure_filter(struct ieee80211_hw *hw,
>  
>  	mutex_unlock(&priv->mutex);
>  
> +	/*
> +	 * Receiving all multicast frames is always enabled by the
> +	 * default flags setup in iwl_connection_init_rx_config()
> +	 * since we currently do not support programming multicast
> +	 * filters into the device.
> +	 */
>  	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
>  			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;

Note that this is an amazingly serious limitation.

This basically makes iwl chips unsuitable for use on networks where
real multicast use is common.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
