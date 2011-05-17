From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Tue, 17 May 2011 10:27:00 +0200
Message-ID: <20110517082700.GA18423@rere.qmqm.pl>
References: <20110516131757.ED57E13A6A@rere.qmqm.pl>
 <20110516.151434.829498612745581899.davem@davemloft.net>
 <20110516234816.GA12024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mst@redhat.com, bhutchings@solarflare.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39333 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab1EQI1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 04:27:01 -0400
Content-Disposition: inline
In-Reply-To: <20110516234816.GA12024@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 09:48:16AM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 03:14:34PM -0400, David Miller wrote:
> > From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)
> >=20
> > > Those reduced to DEBUG can possibly be triggered by unprivileged =
processes
> > > and are nothing exceptional. Illegal checksum combinations can on=
ly be
> > > caused by driver bug, so promote those messages to WARN.
> > >=20
> > > Since GSO without SG will now only cause DEBUG message from
> > > netdev_fix_features(), remove the workaround from register_netdev=
ice().
> > >=20
> > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > Applied, thanks.
> I think this patch is not a good idea.  The only problem here
> is the tun driver which should just fix up the feature bits
> silently (we need to do that anyway as right now it doesn't
> verify the feature bits at all, those warnings are only trigger
> on registering the tun device).
>=20
> With this patch future buggy drivers will instead trigger hard-
> to-debug warnings further down the stack in the TSO code path,
> like they have before (or silent packet drops if those warnings
> aren't there anymore).

If core TSO code really depends on checksumming features being turned o=
n
then this dependency should be checked in netdev_fix_features. There
will be no possibility for a driver to cause bugs then.

Network core is making up for devices which can't checksum just before
calling ndo_hard_start_xmit. It's a possibility that packet to be TSOed
will be unnecessarily checksummed in dev_hard_start_xmit() if HW checks=
um
is off while TSO is on (I deduce this based on the code, can't test as
TSO in my test-box is busted).

Best Regards,
Micha=B3 Miros=B3aw
