From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 19:22:51 +0800
Message-ID: <20071125112251.GA10039@gondor.apana.org.au>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <1195938799.4149.197.camel@johannes.berg> <20071125014446.GA32104@gondor.apana.org.au> <1195988428.4149.225.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1195988428.4149.225.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 25, 2007 at 12:00:28PM +0100, Johannes Berg wrote:
>
> Not sure. On the one hand, yeah, that's something we should probably do,
> on the other hand this will suck because for most drivers either nothing
> needs to be done or the fixup is trivial. I suppose we should do this
> but stick in a WARN_ON_ONCE() or something, at least with mac80211 debug
> enabled.

I don't see how you can get a WARN_ON to work when you're expecting
there to be unaligned packets from time to time as the hardware
header changes.

> Also, we do plan to run these things on rather smallish embedded devices
> like APs that receive a lot of frames from many stations, and with 11n
> we're pushing speeds up by quite a bit. I'm wary of putting more code
> into the generic receive path.

Well you don't have a choice if the hardware header is really
unpredictable.  It's either that or we go and modify the entire
IP stack which penalises all the high-speed Ethernet NICs that
already get the alignment correctly.

> Well, you can receive non-QoS frames even in QoS or WPS frames in any
> other mode etc. so you can't really make any promises as which will be
> more common. Bu in practice all (sane) hardware makes sure things are
> aligned properly.

Here's an idea.  Even if you can't predict the header length of
all packets, can you at least predict the header length of the
majority of data (ones carrying IP etc.) packets?

If so then you can do the skb_reserve based on that and the fix-up
in the wireless core would be minimised.

Since I know next to nothing about the wireless transport layer,
one of you experts will need to tell me whether such a prediction
could work :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
