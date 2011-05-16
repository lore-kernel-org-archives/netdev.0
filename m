From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Tue, 17 May 2011 09:48:16 +1000
Message-ID: <20110516234816.GA12024@gondor.apana.org.au>
References: <20110516131757.ED57E13A6A@rere.qmqm.pl> <20110516.151434.829498612745581899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, mst@redhat.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37575 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276Ab1EPXsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 19:48:22 -0400
Content-Disposition: inline
In-Reply-To: <20110516.151434.829498612745581899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 03:14:34PM -0400, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)
>=20
> > Those reduced to DEBUG can possibly be triggered by unprivileged pr=
ocesses
> > and are nothing exceptional. Illegal checksum combinations can only=
 be
> > caused by driver bug, so promote those messages to WARN.
> >=20
> > Since GSO without SG will now only cause DEBUG message from
> > netdev_fix_features(), remove the workaround from register_netdevic=
e().
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Applied, thanks.

I think this patch is not a good idea.  The only problem here
is the tun driver which should just fix up the feature bits
silently (we need to do that anyway as right now it doesn't
verify the feature bits at all, those warnings are only trigger
on registering the tun device).

With this patch future buggy drivers will instead trigger hard-
to-debug warnings further down the stack in the TSO code path,
like they have before (or silent packet drops if those warnings
aren't there anymore).

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
