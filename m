From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH] Reduce netfilter memory use on MP systems
Date: Fri, 04 Feb 2005 18:34:42 +0100
Message-ID: <1107538482.1111.6.camel@tux.rsn.bth.se>
References: <20050204140900.GD2518@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-A0J9aMmekRjWTUo18QHr"
Cc: netdev@oss.sgi.com, Netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Andi Kleen <ak@suse.de>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20050204140900.GD2518@wotan.suse.de>
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


--=-A0J9aMmekRjWTUo18QHr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-02-04 at 15:09 +0100, Andi Kleen wrote:
> On kernels compiled with a big NR_CPUS netfilter rules would=20
> eat a lot of memory because all counters would be duplicated
> for all NR_CPUs CPUs.  With NR_CPUS=3D256 this would add up
> to many MBs of memory.
>=20
> This patch only allocates enough memory for the possible CPUs,
> which is usually a much smaller number than NR_CPUS.
>=20
> This allows loading of bigger rule sets on 64bit systems.
> There is still a limit because someone else broke vmalloc to have a 64MB=20
> limit on 64bit systems for single allocations, 129MB on 32bit.
> It allocates an array of pages with kmalloc and kmalloc has a 128K limit.=
=20
> To be fixed with a separate patch.
>=20
> 64bit systems were hurt worst because they tend to have big NR_CPUS
> and the counters need more memory there, and the vmalloc limit is lower.
> But it will raise the limits even on 32bit.=20
>=20
> And in general it saves a lot of memory.

Patrick, could you apply and submit this patch to Davem? Or if Davem
applies it himself. It's pretty obvious and would help small SMP
machines with distribution kernels and/or strange admins.

--=20
/Martin

--=-A0J9aMmekRjWTUo18QHr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBCA7IyWm2vlfa207ERApm/AJ9LEA2DHbXBJhRewpcgZ95JWtcw5QCgsq+v
wbiXYM5H1VpufxryKV8ufZU=
=GMMw
-----END PGP SIGNATURE-----

--=-A0J9aMmekRjWTUo18QHr--
