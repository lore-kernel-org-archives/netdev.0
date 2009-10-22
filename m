From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm transport mode policy and forward packets
Date: Thu, 22 Oct 2009 22:21:26 +0900
Message-ID: <20091022132126.GB28893@gondor.apana.org.au>
References: <4AE04B00.8090207@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41641 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755219AbZJVNV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 09:21:28 -0400
Content-Disposition: inline
In-Reply-To: <4AE04B00.8090207@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2009 at 03:07:28PM +0300, Timo Ter=E4s wrote:
>
> I'm using on my dmvpn environment security policies like:
>
> src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 	dir in priority 2147483648 pty=
pe=20
> main 	tmpl src 0.0.0.0 dst 0.0.0.0
> 		proto esp reqid 0 mode transport
>
> src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 	dir out priority 2147483648 pt=
ype=20
> main 	tmpl src 0.0.0.0 dst 0.0.0.0
> 		proto esp reqid 0 mode transport
>
> To make sure the locally generated/received GRE traffic is IPsec prot=
ected.
> Now when some other non-local gre traffic is being forwarded by this =
router,
> that seems to match these SPs too. Basically no one behind this route=
r box
> can use GRE (or PPTP).

This is expected since forwarded GRE packets match the selector
given.

> My ideas so far have been:
> a) rename 'fwd' to 'infwd' and split 'out' to 'out' and 'outfwd' ?
>   (sounds kinda intrusive)
> b) iptables target that would be able to disable xfrm
>
> Any other ideas?
> What would be the proper fix for this problem?

We could add the fwmark as a key.

Alexey and others may have better ideas on this.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
