From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing benchmark.
Date: Wed, 4 May 2005 20:11:43 +0400
Message-ID: <20050504201143.7f6bdcce@zanzibar.2ka.mipt.ru>
References: <20050429144103.A23268@2ka.mipt.ru>
	<20050503095312.GA29788@gondor.apana.org.au>
	<1115115502.3414.22.camel@uganda>
	<20050503101447.GA29973@gondor.apana.org.au>
	<1115116295.3414.30.camel@uganda>
	<20050503102929.GA30097@gondor.apana.org.au>
	<1115117728.3414.48.camel@uganda>
	<1115127507.3414.58.camel@uganda>
	<1115203214.7665.58.camel@localhost.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Patrick
 McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115203214.7665.58.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2005 06:40:14 -0400
jamal <hadi@cyberus.ca> wrote:

> On Tue, 2005-03-05 at 17:38 +0400, Evgeniy Polyakov wrote:
> > Here are some numbers:
> >=20
> > ./netperf -l 60 -H gw -t TCP_STREAM -i 10,2 -I 99,5 -- -m 4096 -s 573=
44
> > -S 57344
> >=20
> > TCP STREAM TEST to gw : +/-2.5% @ 99% conf.
> >=20
> > async-ipsec, 10^6bits/sec:  35.42
> >  sync-ipsec, 10^6bits/sec:  37.11
> >=20
> > So even with existing timer deferring it is not noticebly slower [abo=
ut
> > 4%].
> >=20
>=20
> by "sync" i hope you mean the original code without your change?

Yes, it is vanilla 2.6.12-rc2 kernel with native IPsec.

> The one thing i see in your POC code that may affect numbers a bit is
> allocation of struct esp_async every time in the path. Perhaps precreat=
e
> a pool of those and then just grab/return to/fro pool;

That could be skb too - since both skb/kmalloc=20
atomic allocations end up in kmem_cache_alloc().
=20
> BTW, you may need to incr ref counter of x pre-callback and decrement
> when done in callback.

It looks like dst entry holding is enough since=20
direct dst->output(), i.e. xfrm_state->output(),=20
call itself is not protected by reference counter,
but dst entry is being held during that call.

> > And I think that benefits it provides definitely cost that price and=20
> > compile time option.
>=20
> I think Herberts concerns about latency should go away if you really
> have some proper crypto hardware.=20

Unfortunately I do not have hardware crypto accelerator setup currently
[board freezes before even monitor and keyboard blink with my HIFN card,
it looks like bus arbitrage problem],
so I can not provide real numbers with it, but I will set acrypto with
several software crypto providers with that patch on SMP=20
[schei=DFe, I burned second HT Xeon] (1+1HT) up, and will rerun the test =
soon.

> cheers,
> jamal
>=20


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
