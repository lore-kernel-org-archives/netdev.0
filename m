From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 10:59:04 +0200
Message-ID: <20130530085904.GA2475@ritirata.org>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
 <20130528.233647.1209227470109213894.davem@davemloft.net>
 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
 <20130529194438.GY3333@ritirata.org>
 <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, horms@verge.net.au
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:35382 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967942Ab3E3JB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 05:01:58 -0400
Content-Disposition: inline
In-Reply-To: <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 29, 2013 at 10:02:06PM +0100, Ben Hutchings wrote:
> On Wed, 2013-05-29 at 21:44 +0200, Antonio Quartulli wrote:
> > On Wed, May 29, 2013 at 08:34:33PM +0100, Ben Hutchings wrote:
> > > On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> > > > From: Cong Wang <amwang@redhat.com>
> > > > Date: Wed, 29 May 2013 14:09:00 +0800
> > > >=20
> > > > > commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> > > > > fields of struct skbuff) converts skb->*_header to u16,
> > > > > therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> > > > > 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> > > > >=20
> > > > >=20
> > > > > Cc: David S. Miller <davem@davemloft.net>
> > > > > Cc: Simon Horman <horms@verge.net.au>
> > > > > Signed-off-by: Cong Wang <amwang@redhat.com>
> > > >=20
> > > > I want to use something that will either break the build or
> > > > automatically work if the type changes again.
> > > >=20
> > > > So something like "X =3D (typeof(X)) ~0U;".
> > >=20
> > > I think you mean ~(typeof(X))0.
> >=20
> > Am I wrong or you should cast the value once again, like this:
> >=20
> > ((typeof(X))~(typeof(X))0)
> >=20
> > because the ~ operator will implicitly cast the argument to int (if I r=
emember
> > correctly).
>=20
> It will promote to at least int, but that still results in the right
> value and doesn't provoke a warning.  Try this test (with -Wall
> -Wextra):

thanks for the test code Ben.

Yeah it gives the results you expected. Then I don't know why somebody sugg=
ested
us to do this double cast in batman-adv when we wanted to obtain the same.

At this point I'll remove the double cast in our code too.

Thanks.

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRpxTYAAoJEADl0hg6qKeOZMAP/1nvhSQyyc0y5+xI1wN45QhO
KATVb8Hybc3eH7AMbwaPrcoZNmJkKSzao0AMu8a3zKQyJfxodoBLNoLL7kEIY160
ub3u+Z541s23LdJOt9v1JowrS2ikkwsFXwjLRSZcPn46oGAUAe7wdJntoJGFYeB1
rZNcRxEUDVouDUBqPK/f90nskWlwgUsNQM5wNlISwLytMEZk68DNawIGrAnaiqPw
ve7MBd1EWSRiKZuF0hxU0NnL6TGGXUhJhLbl9vL8HYYMO4N+Rrun9/Nz0jqUBqUP
lrYRp+FXNr8rMxUfE6/wB5LRdjBwXo/whVg1zpELnYaj+dPuupSSfel0wMZdssiD
4xwloPMCKPA+BMieTnUPfSF4abiH+dVvm4FG57UjQgdl/aMudZq41WM/K01obLnn
mfxTmBydtMA+hztz4AhKtSKsBeSXqX5TrnE4iOC4LxwyPR+sQDIDvltYwji5Auk6
/oBe60JTmXb1t0oBDgZX1nFE68+VSVMGJzb3JJ+WJTohU+2X2UUEPMryx3BrHTUk
G8Wptm4qGMGGxco9vHmscRoEdBBSnRySk33W+X2D07m1Owy9FIOF5yy4f2p+bxEd
JlG8o2xQPFmzCFEJUM08E+SmXkFA2LLVdoDKuDe+gLbyukkY+Y0ClhDWErNP2hlo
Gl8kAOGTG8ZlZWueNot6
=8kIs
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
