From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: Buggy rhashtable walking
Date: Thu, 4 Aug 2016 15:45:46 +0800
Message-ID: <20160804074546.GA996@gondor.apana.org.au>
References: <20160804071846.GA773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160804071846.GA773-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 04, 2016 at 03:18:46PM +0800, Herbert Xu wrote:
> 
> So the question is can wireless handle seeing an entry multiple
> times? In particular, __ieee80211_rx_handle_packet would appear
> to process the same packet multiple times if this were to happen.

It's worse than I thought.  In fact it's not walking the table
at all, rather it's doing a hash lookup by hand!

This cannot possibly work given that rhashtable makes use of
multiple hash tables.

In fact this also demonstrates why putting multiple identical
objects into the same table is crap.  Because there is no sane
way of returning all objects corresponding to a single key, given
that they may be spread over multiple tables.

So I'm going to fix this by consolidating identical objects into
a single rhashtable entry which also lets us get rid of the
insecure_elasticity setting.

So the next time someone comes along and wants to add multiple
objects with the same key to one table, please just say no.

Thanks,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
