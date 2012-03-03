From: Sergei Trofimovich <slyich@gmail.com>
Subject: Re: [PATCHv 2] tcp: properly initialize tcp memory limits part 2
 (fix nfs regression)
Date: Sat, 3 Mar 2012 17:43:22 +0300
Message-ID: <20120303174322.7e920bc5@sf.home>
References: <1330675173-18968-1-git-send-email-slyich@gmail.com>
	<4F509150.5060904@redhat.com>
	<20120302202421.753b36bc@sf.home>
	<20120302205000.088bf231@sf.home>
	<4F5227C9.7060209@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/g=oQQ04CBUNKqm8mTdjuPu."; protocol="application/pgp-signature"
Cc: Jason Wang <jasowang@redhat.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F5227C9.7060209@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/g=oQQ04CBUNKqm8mTdjuPu.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 3 Mar 2012 11:16:41 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 03/02/2012 02:50 PM, Sergei Trofimovich wrote:
> >>>> The change looks like a typo (division flipped to multiplication):
> >>>>> limit =3D nr_free_buffer_pages() / 8;
> >>>>> limit =3D nr_free_buffer_pages()<<   (PAGE_SHIFT - 10);
> >>>
> >>> Hi, thanks for the reporting. It's not a typo. It was previously:
> >>> sysctl_tcp_mem[1]<<  (PAGE_SHIFT -  7). Looks like we need to do the
> >>> limit check before shift the value. Please try the following patch, t=
hanks.
> >>
> >> Still does not help. I test it by checking sha1sum of a large file ove=
r NFS
> >> (small files seem to work simetimes):
> >>
> >>      $ strace sha1sum /gentoo/distfiles/gcc-4.6.2.tar.bz2
> >>      ...
> >>      open("/gentoo/distfiles/gcc-4.6.2.tar.bz2", O_RDONLY
> >>      <HUNG>
> >> After a certain timeout dmesg gets odd spam:
> >> [  314.848094] nfs: server vmhost not responding, still trying
> >> [  314.848134] nfs: server vmhost not responding, still trying
> >> [  314.848145] nfs: server vmhost not responding, still trying
> >> [  314.957047] nfs: server vmhost not responding, still trying
> >> [  314.957066] nfs: server vmhost not responding, still trying
> >> [  314.957075] nfs: server vmhost not responding, still trying
> >> [  314.957085] nfs: server vmhost not responding, still trying
> >> [  314.957100] nfs: server vmhost not responding, still trying
> >> [  314.958023] nfs: server vmhost not responding, still trying
> >> [  314.958035] nfs: server vmhost not responding, still trying
> >> [  314.958044] nfs: server vmhost not responding, still trying
> >> [  314.958054] nfs: server vmhost not responding, still trying
> >>
> >> looks like bogus messages. Might be relevant to mishandled timings
> >> somewhere else or a bug in nfs code.
> >
> > And after 120 seconds hung tasks shows it might be an OOM issue
> > Likely caused by patch, as it's a 2GB RAM +4GB swap amd64 box
> > not running anything heavy:
>=20
> That is a bit weird.
>=20
> First because with Jason's patch, we should end up with the very same=20
> calculation, at the same exact order, as it was in older kernels.
> Second, because by shifting << 10, you should be ending up with very=20
> small numbers, effectively having tcp_rmem[1] =3D=3D tcp_rmem[2], and the=
=20
> same for wmem.
>=20
> Can you share which numbers you end up with at=20
> /proc/sys/net/ipv4/tcp_{r,w}mem ?
>=20

Sure:

    $ cat /proc/sys/net/ipv4/tcp_{r,w}mem
    4096    87380   1999072
    4096    16384   1999072

Nothing special with NFS nere, so I guess it uses UDP.
TCP works fine on machine (I do everything via SSH).

--=20

  Sergei

--Sig_/g=oQQ04CBUNKqm8mTdjuPu.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk9SLhEACgkQcaHudmEf86ojDACcDmBU8I7749gXsjc4faM9lvne
d/4AnipiQieUwkwzXCZHp+hWU/ii4jpb
=G2bR
-----END PGP SIGNATURE-----

--Sig_/g=oQQ04CBUNKqm8mTdjuPu.--
