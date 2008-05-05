From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 16:14:58 -0700 (PDT)
Message-ID: <20080505.161458.46071527.davem@davemloft.net>
References: <1210021066.4181.41.camel@johannes.berg>
	<20080505.153730.186617868.davem@davemloft.net>
	<1210027447.8012.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210027447.8012.15.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 06 May 2008 00:44:07 +0200

> Right, that makes sense. But will it ever return false? skb_cloned()
> returns true often enough, and we only accept linear skbs, but I think I
> don't understand yet what skb_header_cloned() vs. skb_cloned() refers
> to. Which exactly is the header space I'm allowed to modify when
> skb_header_cloned() returns false?

skb_header_cloned() will return false always if the buffer is not
cloned.

If it is cloned, it makes sure the data reference count allows
for modification of the buffer.

For normal traffic, you should see skb_header_cloned() always return
false unless a network tap like tcpdump is registered.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
