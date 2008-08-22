From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Fri, 22 Aug 2008 20:47:30 +1000
Message-ID: <20080822104730.GA19742@gondor.apana.org.au>
References: <20080822065655.GA18471@gondor.apana.org.au> <20080822.001620.141235108.davem@davemloft.net> <20080822074115.GB25615@gondor.apana.org.au> <20080822.034217.135152551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822.034217.135152551.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2008 at 03:42:17AM -0700, David Miller wrote:
> 
> I had another idea in the back of my head that I wanted to mention.
> 
> The SKB has a hash, and sources set the hash.  It doesn't matter
> where in the stack it comes from.

Yes this sounds great!
 
> So in the simplest case for forwarding, the RX side puts the RSS
> hash or whatever into this SKB hash location.

This works on all the routers.

> Then, taking things to the next level, protocols set hashes for
> locally created packets.  And this leads to being able to delete
> the simple_tx_hash() code entirely and also we won't have to add
> support for every protocol on the planet to that function. :)

And this takes care of the hosts.

Best of all it's per flow and we don't even need to add any new
infrastructure :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
