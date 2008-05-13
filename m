From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Tue, 13 May 2008 15:09:26 -0700 (PDT)
Message-ID: <20080513.150926.114765212.davem@davemloft.net>
References: <1210712356.4279.22.camel@johannes.berg>
	<1ba2fa240805131412i3bd1756bhb11d31742b326b2f@mail.gmail.com>
	<1210714643.4279.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210714643.4279.27.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 13 May 2008 23:37:23 +0200

> 
> > >  Most fullmac devices also need some space, whether they do things that
> > >  way or not is a completely different thing, the ieee80211 stack for
> > >  example copies every packet into a new skb anyway.
> > 
> > It's really depends on when is the 802.3 to 802.11 header translation
> > made it doesn't matter whether it's fullmac or softmac. I would say
> > that WLAN is OK.
> 
> True, some devices take 802.3 frames and do the translation and
> everything themselves. I dunno. I guess it would make sense to make it
> mac80211 anyway because ieee80211 doesn't care and the other drivers are
> probably handling this in some other way anyway (if maybe even by using
> different dma descriptors, or just not caring because transfer speeds
> are low enough)

We should fix ieee80211 (it's something I planned to look into today
in fact), and the drivers that copy or do things incorrectly.

It doesn't make sense to make this decision based upon which 80211
stack or which drivers are enabled.  All of them in essence want this
extra space, so let's give it to them.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
