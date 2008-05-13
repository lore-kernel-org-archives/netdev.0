From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 12 May 2008 22:01:21 -0700 (PDT)
Message-ID: <20080512.220121.166961544.davem@davemloft.net>
References: <20080505.134420.194001886.davem@davemloft.net>
	<1210021066.4181.41.camel@johannes.berg>
	<20080505.153730.186617868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753210AbYEMFB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 01:01:27 -0400
In-Reply-To: <20080505.153730.186617868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 05 May 2008 15:37:30 -0700 (PDT)

Just a heads up that I'm adding this to my tree as well.

> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index f35eaea..86f0e36 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -1562,13 +1562,13 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
>  	 * be cloned. This could happen, e.g., with Linux bridge code passing
>  	 * us broadcast frames. */
>  
> -	if (head_need > 0 || skb_cloned(skb)) {
> +	if (head_need > 0 || skb_header_cloned(skb)) {
>  #if 0
>  		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
>  		       "of headroom\n", dev->name, head_need);
>  #endif
>  
> -		if (skb_cloned(skb))
> +		if (skb_header_cloned(skb))
>  			I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
>  		else
>  			I802_DEBUG_INC(local->tx_expand_skb_head);
