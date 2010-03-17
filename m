From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Wed, 17 Mar 2010 22:58:50 +0800
Message-ID: <20100317145850.GA4257@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34159 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750731Ab0CQO6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 10:58:52 -0400
Content-Disposition: inline
In-Reply-To: <4BA0E435.6090801@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 04:16:21PM +0200, Timo Ter=E4s wrote:
>
> The problem is if I have multipoint gre1 and policy that says
> "encrypt all gre in transport mode".
>
> Thus for each public address, I get one bundle. But the
> xfrm_lookup() is called for each packet because ipgre_tunnel_xmit()
> calls ip_route_output_key() on per-packet basis.
>
> For my use-case it makes a huge difference.

But if your traffic switches between those tunnels on each packet,
we're back to square one, right?

> Then we cannot maintain policy use time. But if it's not a
> requirement, we could drop the policy from cache.

I don't see why we can't maintain the policy use time if we did
this, all you need is a back-pointer from the top xfrm_dst.

> Also. With this and your recent flowi patch, I'm seeing pmtu
> issues. Seems like xfrm_bundle_ok uses the original dst which
> resulted in the creation of the bundle. Somehow that dst
> does not get updated with pmtu... but the new dst used in
> next xfrm_lookup for same target does have proper mtu.
> I'm debugging right now why this is happening. Any ideas?

The dynamic MTU is always maintained in a normal dst object in
the IPv4 routing cache.  Each xfrm_dst points to such a dst
through xdst->route.

If you were looking at the xfrm_dst's own MTU then that may well
cause problems.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
