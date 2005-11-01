From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Tue, 1 Nov 2005 13:39:50 -0500
Message-ID: <20051101183950.GJ6026@ns.snowman.net>
References: <20051026003954.GA14068@gondor.apana.org.au>
	<4360E75A.10405@trash.net> <43655428.3040904@trash.net>
	<200510310319.j9V3JHZK008295@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OpjiOMsh+o5vh7q4"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200510310319.j9V3JHZK008295@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--OpjiOMsh+o5vh7q4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Yasuyuki KOZAKAI (yasuyuki.kozakai@toshiba.co.jp) wrote:
> I think pure transport mode is important, too. For example, for users of
> L2TP over IPsec.
>=20
> But I'm not sure that how many people wants to use netfilter hook togethe=
r.
> At least, I don't need that. Because I can use IPsec policy instead of
> iptables rule and that's enough for me.
>=20
> I also think that it's the work for IPsec policy check to decide to
> accept or drop decrypted packets on input path of transport mode, that is
> not netfilter work.

Trying to compare IPsec policy to netfilter is just plain silly.  IPsec
policy is *not* equivilant to a firewall system like netfilter.  Not
even close.  Not offering the ability to firewall transport-mode IPsec=20
packets shouldn't even be an option. :/  With 15 servers which all talk
transport-mode IPsec to each other I'd still want to be able to do
firewalling to hopefully reduce the impact of one of the servers being
compromised.

> On the other hand, for the users who want to use local NAT and IPsec
> transport mode together, we might have to add netfilter hook to input
> path. But I'm not sure how many such users are. If nobody want, hooks
> we need are only LOCAL_OUT and POST_ROUTING on output path per tunnel.

I had wanted to do this, in order to hide the network configuration of
the machines behind the gateway but ended up not being able to. :/  My
situation is perhaps not very common but I think it will become more
common in the future: I've got a VPN setup with multiple different
people who I don't completely trust and who don't entirely trust me or
the other people.  This situation can exist for tunnel mode and
transport mode users.  As use-ipsec-when-available transport mode
increases in use this need seems likely to grow.

Consider a corporate network where the whole thing is set up to do
transport-mode ipsec.  Chances are the guys who run the corporate
servers are still going to want to be able to run firewalls on their
servers to cover things in case a given desktop is compromised.

	Thanks,

		Stephen

--OpjiOMsh+o5vh7q4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDZ7Z1rzgMPqB3kigRAroXAJ9+IzjIKquOnfKEG+hwzvYSAc8w4wCdHN0E
bGOtLZZ0RiPMuxKSNCHjrFs=
=pDJX
-----END PGP SIGNATURE-----

--OpjiOMsh+o5vh7q4--
