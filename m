From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 5 May 2008 20:15:23 +0300
Message-ID: <1ba2fa240805051015t7dfd3bd2nf7bc2fc1ab9799ca@mail.gmail.com>
References: <1209936253.7304.10.camel@johannes.berg>
	 <1209936745.7304.16.camel@johannes.berg>
	 <20080504.173051.133197507.davem@davemloft.net>
	 <1209972139.3655.9.camel@johannes.berg>
	 <1ba2fa240805050727r2060b0b4x3a9b3240647b66b1@mail.gmail.com>
	 <1210000923.8245.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210000923.8245.26.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 5, 2008 at 6:22 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>
>  > I've did some measurement of the TX path  on an embedded system (2.6.23 kernel)
>  > When bridging packets from an ethernet device to wireless  there is
>  > loss of 12% in the CPU utilization and equivalent throughput reduction
>  > in data packets that are checked and expanded in
>  > ieee80211_subif_start_xmit function.
>
>  Yeah, I figured.
>
>
>  > The expansion is just due to bigger size of the 80211 header size, yet
>  > the whole packet is reallocated and copied. As we are reaching 11n
>  > rates 200bps and up this starts to be visible.
>  > When header was reserved to the  proper side already in the ethernet
>  > driver the overhead was gone. Yet this doesn't seems to be a correct
>  > solution for bridging or forwarding.
>  > For example Iwlwifi HW supports scattered packets this would allow
>  > just reallocate the header, providing data portion is aligned.
>
>  Right. Not all hardware supports this though,
I would set  NETIF_F_SG OR FRAGLIS to features...?  (What actually is
the difference?)

but even when it does I
>  don't see what we can do unless we want to do all this inside mac80211
>  which I'd rather not.

Like Sending mac80211 header OOB as xmit function argument?  This will
probably affect all the wme code as well...
Not good.



>  SKBs don't have a way to say "I need N bytes writable headroom but I can
>  do s/g operation for the rest" which is what we'd need. If that was
>  available, we could even work with clones, then we could pull away the
>  ethernet header and build the 802.11/device headers in separate buffers,
>  demoting the old 'skb head' buffer to a data buffer...
>

Isn't this a requirement that header fits into a continuous buffer ?
It's sounds strange to me that there is no solution for efficient
bridging... Can bridging code handle this if we have native interface?


Thanks
Tomas

>  johannes
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
