From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 27 Sep 2004 11:11:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927091148.GF3236@sunbeam.de.gnumonks.org>
References: <20040919163642.GC1307@sunbeam.de.gnumonks.org> <4155D781.8050700@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QMcAIMJS2LNMCtSQ"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <4155D781.8050700@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--QMcAIMJS2LNMCtSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[resend, went to wrong list address]

Manfred, thanks for your comments.

[explicit Cc to jamal becuase of NAPI-related stuff below]

On Sat, Sep 25, 2004 at 10:39:29PM +0200, Manfred Spraul wrote:
> >+config NATSEMI_NAPI
> >+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
> >=20
> I'm not a big fan on config options for drivers. I'd prefer a runtime=20
> option.

I see.

> >	TODO:
> >	* big endian support with CFG:BEM instead of cpu_to_le32
> >	* support for an external PHY
> >-	* NAPI
> >=20
> >
> Hmm. Actually all TODO points are done: CFG:BEM is unusable because it=20
> swaps data words.
> External PHYs are supported. You are closing the last point.

Ok, I'll remove all three with my next patch

> Additional registers. You didn't mention that in the changelog.=20
> Changelogs should mention every change, please do not piggypack=20
> unrelated changes.

ack.

> >+	long ioaddr =3D dev->base_addr;
> >+	int boguscnt =3D max_interrupt_work;
> >+
> This doesn't compile: you've removed max_interrupt_work.

mh, apparently I've sent an outdated patch then.  I'll repost an updated
version once I know what the solution for IntrStatus is

> >+	/* We cannot read IntrStatus since this would acknowledge
> >+	 * all interrupt sources. Thus we just blindly assume that
> >+	 * the interrupt really was for us -HW! */

> Huge problem - this is not acceptable. It means the driver is unusable=20
> for shared interrupts. We must find a solution.

yes, I know :(  Luckily on my embedded boards, there are no shared
interrupts - but this is obviously a special case.

I think this overall problem can be solved if there was some per-device
variable that saves the IntrStatus until the NAPI callback gets
scheduled. What do you think?  This wouldn't even need some locking,
since interrupts would be disabled before the field is updated, and not
re-enabled before the field is read by the NAPI callback?

I was surprised that this solution is not suggested in the NAPI-HOWTO.txt, =
so I though there must be an error in my proposal...

By using such a scheme, isn't it also possible to only offload RX into
the NAPI callback with clear-on-read devices?

> IRQ_NONE would be definitively wrong: The kernel disables interrupt=20
> sources if it can't find a handler. If our handler returns IRQ_NONE and=
=20
> the irq is not shared, then the kernel will disable the irq after a=20
> short while.

ok.

> Also missing in the changelog.

is related to the register definitions above.

>    Manfred

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--QMcAIMJS2LNMCtSQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBV9lUXaXGVTD0i/8RAt9CAJsHefOfhWgj96DYYeX5A1kbjR5Y0QCeP/eT
/I4V9bIhKQ+k5bZ3yuMo7/U=
=jA+9
-----END PGP SIGNATURE-----

--QMcAIMJS2LNMCtSQ--
