From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Mon, 29 Dec 2008 14:05:19 +0100
Message-ID: <1230555919.6644.36.camel@martin>
References: <20081224060225.GA26084@obsidianresearch.com>
	 <20081224085940.GA24830@gondor.apana.org.au>
	 <20081224183355.GB26084@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:40329 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751620AbYL2NFs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 08:05:48 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id B7514130022
	for <netdev@vger.kernel.org>; Mon, 29 Dec 2008 14:05:24 +0100 (CET)
In-Reply-To: <20081224183355.GB26084@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > > git blame says this setting was made before RFC 4868 was publishe=
d,
> > > so I'm not sure that it was chosen with any standard in mind.
> > >=20
> > > NOTE: This 'breaks' the user space API, however at least StrongSw=
an
> > > 4.2.9's charon already associates AUTH_HMAC_SHA2_256_128 with
> > > the transform name 'sha256'.

We already discussed this in
http://kerneltrap.org/mailarchive/linux-kernel/2008/6/5/2039114 ,
but it was too much effort for me to fix this properly then.

> > The 96 bits is actually still correct for the auth algorithm IDs
> > 5, 6, and 7.  The parameters in 4868 have been assigned new IDs
> > starting from 12.
>=20
> Oh? Ok, I didn't realize there was something that defined those usage=
s
> on PF_KEY. They are not defined for use with IKEv2 at all..

=EF=BB=BFIn PF_KEY, SADB_X_AALG_SHA2_256HMAC (5) was defined in
draft-ietf-ipsec-ciph-sha-256-00 to 96 bit truncation (what is currentl=
y
implemented). draft-ietf-ipsec-ciph-sha-256-01 defined it to 128 bit
truncation (what is now RFC 4868).
Those numbers starting from 12 are IKEv2 algorithm identifiers and are
never passed to the kernel.

> BTW, is there some reason why SADB_X_AALG_SHA2_384HMAC and
> SADB_X_AALG_SHA2_512HMAC are absent from the table in xfrm_algos?

Yes, it was not specified in draft-ietf-ipsec-ciph-sha-256-00, but is
defined in RFC 4868.

> BTW, Herbert, if this is the way to go can you fix StrongSwan?
> Mapping AUTH_HMAC_SHA2_256_128 to 'sha256' in
> src/charon/plugins/kernel_netlink/kernel_netlink_ipsec.c is not
> correct based on this discussion. It needs to be 'hmac(sha256)' and
> use this XFRMA_AUTH2 idea. Similarly for all the SHA-2 family of
> functions I guess.

Yes I'm aware of that. I'll fix it a soon as it is available in the
kernel.=20

Regards
Martin


