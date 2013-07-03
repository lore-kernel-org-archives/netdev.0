From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 3 Jul 2013 17:48:22 +1000
Message-ID: <20130703174822.d06500db5cbd5191c39e3f08@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__3_Jul_2013_17_48_22_+1000_kF2TGyGWWDgMaPhN"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__3_Jul_2013_17_48_22_+1000_kF2TGyGWWDgMaPhN
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allnoconfig) failed like this:

fs/select.c: In function 'do_select':
fs/select.c:408:2: error: implicit declaration of function 'll_start_time' =
[-Werror=3Dimplicit-function-declaration]
  u64 ll_start =3D ll_start_time(ll_flag);
  ^
fs/select.c:409:2: error: implicit declaration of function 'll_run_time' [-=
Werror=3Dimplicit-function-declaration]
  u64 ll_time =3D ll_run_time();
  ^
fs/select.c:504:3: error: too many arguments to function 'can_poll_ll'
   if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
   ^
In file included from fs/select.c:31:0:
include/net/ll_poll.h:194:20: note: declared here
 static inline bool can_poll_ll(u64 end_time)
                    ^
fs/select.c: In function 'do_poll':
fs/select.c:826:3: error: too many arguments to function 'can_poll_ll'
   if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
   ^
In file included from fs/select.c:31:0:
include/net/ll_poll.h:194:20: note: declared here
 static inline bool can_poll_ll(u64 end_time)
                    ^

Caused by commit 1bc2774d8664 ("net: convert lls to use time_in_range()")
from the net-next tree.

I cherry-picked the commit 419076f59fc5 ("net: lls fix build with
allnoconfig") out of tomorrow's net-next tree.  (I am feeling generous
and noticed that patch being applied :-))

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__3_Jul_2013_17_48_22_+1000_kF2TGyGWWDgMaPhN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR09dKAAoJEECxmPOUX5FEcZwQAJC4R0M2sqUODcOmBTuonllQ
Rf9DJ4LHt4Dmh4lv2SUlt38LfeRitaRyWOYZ6YDPHEb0UgmLYvycT6KrT7kvy42y
mSm2cjkZpQFUihAMGkhL+yJWM8HVAOwnv7E3DPuJFexv+DUM6I+570NVwxCAj5JD
vsHyTl1/ZCLA9fMkGHMb57jDw7fw30aBOzBkjl0AMx8XFpsoOaAWPKaCeGw3u2VH
2ZSlgud+zICJGF1mSh82lwAassKTNUxcgGd8plyN1NxAD+IaQNR4gqBiLblgm4F0
kbzwDdBt1875Vzcvycm4YQmGEK4oQzabs/RgoVDJXEDIevLg238X5orNCRYXiELa
TdoIo0hKVgnwDlkEHKvdup1eL/YPDIRL5n43Ei46SHfH+DNgCh7f70OoVS4LwW+m
QT88WEa7t1s6GT5+ZVk2ljCEmIm4OSPP+c/IWnN6REPoBsf2xg6puS+C6IiEMHdH
woQlMUHiZxTTtVBQzdOMfwbvTQpIPeiiMUrDGqItMq1gbokfk5G9d2thWqinZKkJ
pPYr/9G4VlmuEpJ0vb7wTegsKP/rlnfVh6Aw0grrWutIjzSRKDdfB8yVwjoNiR21
47MykM6buu0IIjtbXveXjkQKGhCzufAutO8ovj/gxVWT0JcpC6U6PUnsBfx/7yKV
XVOgjpN/SGbt3fdZlDr0
=JRbT
-----END PGP SIGNATURE-----

--Signature=_Wed__3_Jul_2013_17_48_22_+1000_kF2TGyGWWDgMaPhN--
