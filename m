From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Tue, 21 Oct 2014 20:32:51 +0100
Message-ID: <1413919971.31953.39.camel@decadent.org.uk>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
		 <20141013.135127.1915115817707962111.davem@davemloft.net>
	 <1413774581.31953.12.camel@decadent.org.uk> <5446AF2A.1030508@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zvb7HOHc3Xa+e3qr8dMb"
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5446AF2A.1030508@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zvb7HOHc3Xa+e3qr8dMb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-10-21 at 17:08 -0200, Marcelo Ricardo Leitner wrote:
> On 20-10-2014 01:09, Ben Hutchings wrote:
> > On Mon, 2014-10-13 at 13:51 -0400, David Miller wrote:
> >> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >> Date: Mon, 13 Oct 2014 14:03:30 -0300
> >>
> >>> Further tests revealed that after moving the garbage collector to a w=
ork
> >>> queue and protecting it with a spinlock may leave the system prone to
> >>> soft lockups if bottom half gets very busy.
> >>>
> >>> It was reproced with a set of firewall rules that REJECTed packets. I=
f
> >>> the NIC bottom half handler ends up running on the same CPU that is
> >>> running the garbage collector on a very large cache, the garbage
> >>> collector will not be able to do its job due to the amount of work
> >>> needed for handling the REJECTs and also won't reschedule.
> >>>
> >>> The fix is to disable bottom half during the garbage collecting, as i=
t
> >>> already was in the first place (most calls to it came from softirqs).
> >>>
> >>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >>> Acked-by: David S. Miller <davem@davemloft.net>
> >>> Cc: stable@vger.kernel.org
> >>
> >> -stable folks, please integrate this directly, thanks!
> >
> > I've appplied this and the previous two patches mentioned ('ipv4: move
> > route garbage collector to work queue' and 'ipv4: avoid parallel route
> > cache gc executions').  But I didn't get the other two from you.  The
> > last batch of networking fixes I received and applied was dated
> > 2014-08-07, and the next one I've seen is dated 2014-10-11 and has
> > nothing for 3.2 or 3.4.  Did I miss one between these?
>=20
> Sorry to ask Ben but, where did you apply them? I'm not seeing the commit=
s on=20
> linux-stable.git and couldn't find their summaries anywhere else.

They're in a patch queue that I've just pushed to:

git://git.kernel.org/pub/scm/linux/kernel/git/bwh/linux-3.2.y-queue.git

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-zvb7HOHc3Xa+e3qr8dMb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVEa06Oe/yOyVhhEJAQqNKQ//dTLrv5sZOSW44DQ36MyC9M5I8Df/gLMN
7IlFlLhR+XUpA3UvrDAIeKqOU9PbbEf3ky+DuAw9uQVjkGAUlr7mEnxP2qa9RfkV
mUdkVuO6vJ+JN2CtkOph9IvTn3zt3OXCMtmeW40c98iEwH4/aLuajjFYII+pPp39
oc2BkALNwaCVjLkXM7jXYqJrk62LCM8oSGpxCptaqK4q3MevOE4O32rAZ5d2Sohy
ZcnPlhkGg2uTNLBRxqFbJXLxTPJ+QuPLA6hpkR3audwk9c/wMSsPLZ7bMkMeVQRO
3iIXFaY3s/CXTRHyTW5L0WvqWJnRLLw1ed6tnZwI6f7T7A1rZuRn+doX5X1JZxi0
XTorgfaTttFhzaqTqNM3GO/N4HBErA8zuGusnW3/qOpmflpVOrfigIlFVSBG+/4W
ouGTz9C9Drz0zM1yoUQkKaJzI1tdCpUo5KG0c/Is74LSu4d6/7MX/oKu2UxWG6uS
PKJ7KI3GvyIDimEJdJrLXUIG+ilA9X1E+c9Bxu4pCP6OE16e1RwBqMx4mJigsg6t
aDumc+Cj0UWff1OFBXunb+0K+2IHuOOBb8nDY5X0Av4b5Fp/mATcNEqU7gu8njMV
hfQWrJynEqllvkRLagzAtkESMfNJtOA0ehsMsIifSyrtIzUFTEO2h5L7sZG2HHba
6A0X0qAMxjI=
=c5Bi
-----END PGP SIGNATURE-----

--=-zvb7HOHc3Xa+e3qr8dMb--
