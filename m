From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
	else")
Date: Tue, 31 Aug 2004 03:38:42 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
References: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
	<20040830140729.7309ecc0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZrqbukKJvfR9Lgmd"
Cc: netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040830140729.7309ecc0.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--ZrqbukKJvfR9Lgmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Thanks for your quick reply, Dave.

On Mon, Aug 30, 2004 at 02:07:29PM -0700, David S. Miller wrote:

> The original idea was that if the input route relookup sends us
> to a different device, something is very strange.
>=20
> Input routing looks up using daddr/saddr/tos as the key.  The change
> here is that we're now using the fwmark, so you're right that only
> policy routing can cause this thing to trigger.

and it apparently happens in a lot of 'typical' setups where you have a
masqueraded DSL line with dynamic ip address for bulk traffic, and
fwmark-based routing through one or more tunnel interfaces, optionally
with different masqerading/SNAT.

Also, the MASQUERADE lookup (obviously) has no more saddr in the lookup,
that's another difference from the 'original' lookup.

> Where did this check some from?  From this change below, and the
> changelog explains why we do things this way.
>=20
> I know you don't use BK Harald, but things like this are why you should
> at least use the web based interface to look at file change history.

Thanks Dave, I did look up the bk web interface on this item before sending
this post ;) However

> # It can screw up the things a lot.=20

does not really give me an understanding of why and where it might screw
up. I really want  to fully understand this issue before proposing any
change.

> # In this context, if you want to be sure that packet will go out
> # expected interface you do plain lookup and drop packet if it gave
> # you some strange route.

That is the presumption I am about to challenge.  Is the 'original'
interface really the one we want in this case?=20

I've seen a number of users commenting out that check or even starting
to use the iptables ROUTE target (ugly) to get it working in their
setup.  Or they start to use SNAT with scripts in PPP if-up to update
the ruleset with the new dynamic IP :(

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ZrqbukKJvfR9Lgmd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBM9ahXaXGVTD0i/8RAs7XAJ97y+WpnkndVyWUPKco8dmaDvc2zwCdGsRk
m21X4boa6tb0OS/Ru0WaXwQ=
=ca0m
-----END PGP SIGNATURE-----

--ZrqbukKJvfR9Lgmd--
