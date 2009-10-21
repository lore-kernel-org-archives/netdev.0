From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Thu, 22 Oct 2009 06:25:30 +0900
Message-ID: <1256160330.12174.2.camel@johannes.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>
	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <20091021211906.GA11401@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-j0zV5AKGwGs/wyJFAi3L"
Cc: Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20091021211906.GA11401@ami.dom.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-j0zV5AKGwGs/wyJFAi3L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-10-21 at 23:19 +0200, Jarek Poplawski wrote:
> On Wed, Oct 21, 2009 at 08:46:40PM +0200, Tilman Schmidt wrote:
> ...
> > I have tested your patch and I can confirm that it fixes the messages.
> > I have not noticed any ill effects.
>=20
> OK. So, in any case, here is this next variant/proposal.
>=20
> Thanks,
> Jarek P.
> ------------------------>
> net: Adjust softirq raising in __napi_schedule
>=20
> This patch changes __raise_softirq_irqoff() to raise_softirq_irqoff()
> in __napi_schedule() to enable proper softirq scheduling from process
> context. The main intent is to let use netif_rx() universally, and
> make netif_rx_ni() redundant.
>=20
> Currently using netif_rx() instead of netif_rx_ni() triggers:
> "NOHZ: local_softirq_pending 08" warnings, but additional cost of one
> "if" on the fast path doesn't seem to justify maintaining it
> separately.
>=20
> This patch is based on the analysis, suggestions and the original
> patch for mac80211 by: Michael Buesch <mb@bu3sch.de>
>=20
> Another patch calling netif_rx variants conditionally was done by:
> Oliver Hartkopp <oliver@hartkopp.net>
>=20
> Reported-by: Michael Buesch <mb@bu3sch.de>
> Reported-by: Oliver Hartkopp <oliver@hartkopp.net>
> Reported-by: Tilman Schmidt <tilman@imap.cc>
> Diagnosed-by: Michael Buesch <mb@bu3sch.de>
> Tested-by: Tilman Schmidt <tilman@imap.cc>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>=20
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 28b0b9e..7fc4009 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2728,7 +2728,7 @@ void __napi_schedule(struct napi_struct *n)
> =20
>  	local_irq_save(flags);
>  	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
> -	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> +	raise_softirq_irqoff(NET_RX_SOFTIRQ);

This still doesn't make any sense.

There may or may not be a lot of code that assumes that everything else
is run with other tasklets disabled, and that it cannot be interrupted
by a tasklet and thus create a race.

Can you prove that is not the case, across the entire networking layer?

johannes

--=-j0zV5AKGwGs/wyJFAi3L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK33xHAAoJEODzc/N7+Qmaw0EP/1qoDK426hpAZzoIeMk7ajeU
AuI/BeRu6AyZrqm3JXGJEWS1iGK2oarAS7UsqomzPD40NYb7G7is6TBkjVmhAq2c
d7LbkrxO1o1gsaHXrJB09u96dvQ8vLizBaewFo/MV5bUmYaB85HkVt6EOzjcWN54
FRa+umsMduLRPks5GZlNwsMLPNZ6RqB+SyUSvGNpv+6/NYQ3d/jAmXdNOIcWH6bE
kGv0T+/4HFh/c9iMxfFvQiuOHrrtpeyL+hIUBFUQyp3rE1Ir/H518+I3n/I1E3YD
m4V/1+9csJcQurLj1cE+v6tpYfIk37b7JW+BjFekTivS+i/5AqsrD5fAyT3kFnif
UmaBEjoipZ/FhGzhjAEoQc2K82YFGGpiCnaJYmlq004LZZcXcnYCBP4yTjDBu0/l
Rt+4lu+IMZWIyJjUY3uWKMbvE68EjY+CrW598CASs/+13mJJfrgOQZAsSGXrxWdL
LR9k837Z1OuqK6QG/gv/27q/rrQsMLfF/wBGrDdzhd0qebVQZGAYoCc1kSxYmT/m
zrnTeSJwT3wAWU5Gru/tHvDxwnjZUThKZkd2O84ASXZ0w94bZ5TsULADUlZz4Ri9
5G9x91Pz6pxUQ7qoxxnJBnGMrgf7HvmDM0w5aeZfRwhJC9RPHSnwM/SalAFZNt/b
nbemF7khc5FqSgPjwuPe
=k3eI
-----END PGP SIGNATURE-----

--=-j0zV5AKGwGs/wyJFAi3L--

