From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC 3/3] mac80211: support bpf monitor filter
Date: Wed, 12 Apr 2017 11:22:12 -0400 (EDT)
Message-ID: <20170412.112212.441025205054195351.davem@davemloft.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
        <20170412110726.9689-3-johannes@sipsolutions.net>
        <1492007347.2855.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492007347.2855.12.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 12 Apr 2017 16:29:07 +0200

> On Wed, 2017-04-12 at 13:07 +0200, Johannes Berg wrote:
>> 
>>  struct ieee80211_if_mntr {
>>  	u32 flags;
>> 
> [...]
> +	bool deliver;
> 
> That's ... broken for multi-queue RX. I haven't really found a good
> other way to do it. The best way will likely be to copy the SKB the
> first time it's needed, build the radiotap header, and then keep a
> reference to it to be able to clone it later if it's needed again.

If you don't recurse into the receive path for different devices before
you are done with this boolean, simply make a global per-cpu boolean
and use that.
