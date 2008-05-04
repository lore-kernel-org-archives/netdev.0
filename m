From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 4 May 2008 10:12:13 +0800
Message-ID: <20080504021213.GA30660@gondor.apana.org.au>
References: <1209760731.3608.17.camel@johannes.berg> <20080502.163334.148944203.davem@davemloft.net> <1209815533.3987.21.camel@johannes.berg> <20080503.180300.10562559.davem@davemloft.net> <1209865354.6210.23.camel@johannes.berg> <20080504020203.GA30514@gondor.apana.org.au> <1209866916.6210.39.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1209866916.6210.39.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 04, 2008 at 04:08:36AM +0200, Johannes Berg wrote:
>
> So, what is mac80211 supposed to do? It needs up to 54 bytes of
> available headroom (for an encrypted mesh packet which currently can't
> really happen, but anyway) yet it cannot pskb_expand_head() either.
> Cloning each packet seems even more expensive, and just like skb_orphan
> subverts the purpose of the socket accounting.

If all/the majority of your packets need the space then put it in
LL_MAX_HEADER.  In any case, you should always expand the packet
if necessary in your output routine since LL_MAX_HEADER is just a
hint.  Yes cloning is expensive compared to not having to do it,
but as long as this is only done for the exception then it's
irrelevant.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
