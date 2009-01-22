From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 19:50:53 +1100
Message-ID: <20090122085053.GA12806@gondor.apana.org.au>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au> <49782EE4.2070809@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58415 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751055AbZAVIvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 03:51:00 -0500
Content-Disposition: inline
In-Reply-To: <49782EE4.2070809@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 10:31:32AM +0200, Timo Ter=E4s wrote:
>=20
> The (quickish) look on *swans would imply that for each
> dynamic connection I would need to hand create a new connection
> entity. Could be scriptable, but then I would somehow
> need to make up connection names based on the IPs and always
> inject full config by the admin tool.

They have templates for inbound connections on servers and also
outbound connections which were used for Opportunistic Encryption.
So you can adapt these to generate connections on demand.

Also creating/destroying connections at run-time is really easy
without generating a full config at all by using ipsec whack.
=20
> But if there's multiple nodes behind same public IP the xfrm
> has two (or more) choices for which xfrm state to use. The
> NAT-OA can be used as distinguishing factor. So when ip_gre
> sends out packet, the xfrm can choose the correct xfrm state.

That's precisely what you don't want to do unless you trust all
your peers equally.  The reason is that NAT-OA is not authenticated,
i.e., I can choose any address to send over as NAT-OA and there
is nothing you can do to stop me.

It was only ever intended to be used for fixing up the checksum
so you can't safely use it for making policy/routing decisions.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
