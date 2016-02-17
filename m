From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic
 unless there was an error
Date: Wed, 17 Feb 2016 00:24:51 +0000
Message-ID: <1455668691.1143.18.camel@decadent.org.uk>
References: <87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com>
	 <87twljrsb1.fsf@doppelsaurus.mobileactivedefense.com>
	 <87bn7rrqdk.fsf@doppelsaurus.mobileactivedefense.com>
	 <20160216.125157.1927195719504877809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QtodL1XlQaHxt4GSd37m"
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, joseph.salisbury@canonical.com
To: David Miller <davem@davemloft.net>,
	rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160216.125157.1927195719504877809.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QtodL1XlQaHxt4GSd37m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-16 at 12:51 -0500, David Miller wrote:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Mon, 08 Feb 2016 18:47:19 +0000
>=20
> > The present unix_stream_read_generic contains various code sequences of
> > the form
> >=C2=A0
> > err =3D -EDISASTER;
> > if ()
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0goto out;
> >=C2=A0
> > This has the unfortunate side effect of possibly causing the error code
> > to bleed through to the final
> >=C2=A0
> > out:
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return copied ? : err;
> >=C2=A0
> > and then to be wrongly returned if no data was copied because the calle=
r
> > didn't supply a data buffer, as demonstrated by the program available a=
t
> >=C2=A0
> > http://pad.lv/1540731
> >=C2=A0
> > Change it such that err is only set if an error condition was detected.
> >=C2=A0
> > Fixes: 3822b5c2fc62 ("af_unix: Revert 'lock_interruptible' in stream re=
ceive code")
> > Reported-by: Joseph Salisbury <joseph.salisbury@canonical.com>
> > Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>=20
> Applied, thanks Rainer.
>=20
> And BTW I disagree with some of the feedback I saw in these threads
> about "if (x) goto out;" being unreadable and that it should be avoided.

That's not what I said.

> That's completely wrong.
>=20
> Fact is, we've all been reading code of that form for multiple decades.
> So it's the style we are _MOST_ familiar with, and it is therefore the
> style that is the easiest and clearest for kernel developers to understan=
d.
[...]

I agree that 'if (err) goto cleanup;' is widely used and is generally
understandable (though more creative uses of goto are often not).

My objection was to 'err =3D -EFOO; if (cond) goto cleanup;'. =C2=A0That is=
 definitely not clear and it hides mistakes like this.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.
--=-QtodL1XlQaHxt4GSd37m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsO90+e/yOyVhhEJAQrLUQ//dGySNNkKOgmgxPfLgQWsRKdosC68DRh6
eq+ireOz7TgfPExby7icbA55HThvsmLQxr2X0AqmMNQOp6fcJG4iXyxq5dGtITHO
kWpCdrhHVKjB6dvl3F8yWH+Ca7f8jmOXDLXh2lHDFJbKCTlljZNKa7gfzuQSRdZF
VKc8BpTcsJ9wHp1+xbfZH7VI3kB/ef+Mj8776u2pJnop6qBqQmtgezvjonoulMGO
HOwYRyNU1Y+iqxBvTxQzteClPuDc1DheY/5CtSzZeezYjDLVc75GjzT+U6idVRpo
7l0Q5ucQW6GWr5Vu1IMW7IEH7S5kZEqH5ap4IR5B+Ci32LNLEqOVmL+H39UbLmFE
uCQUt4IwJA2hLaB5B1a5RfzGn1NYLSGJzSXarAykdbwBgAtaMGzSVohecVVQAM6z
ZpJjKhYDdMeDMeKLZldPj8liFhhdRsEFEQNNMRcj1mVNdlZxIxAD3Zlxhz1FPgHk
EX4VaES7cJUPvL9tRL4jNHDUaW/1Xi28X972bEwuXC4QKeTlAJm3fT3mFzG8B0/n
lN7hLBmwXFbUGWpIUlUeyDRlZZqSs0y9A4qu215O7CsBAhTTA/EbRaR+p0Dfqd7f
9YWpEvQCtu8sm+c5WNCPsGcfUExFbXeGplMzS8PJWo+7sBueW+Yx88wB0p5CS2FJ
NgAOOGJLZ9U=
=A7nu
-----END PGP SIGNATURE-----

--=-QtodL1XlQaHxt4GSd37m--
