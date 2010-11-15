From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 15 Nov 2010 11:46:51 +1100
Message-ID: <20101115114651.8e6bad6c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__15_Nov_2010_11_46_51_+1100_70vNeCZ14/1f.Dlc"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__15_Nov_2010_11_46_51_+1100_70vNeCZ14/1f.Dlc
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/ipv4/igmp.c: In function 'ip_mc_inc_group':
net/ipv4/igmp.c:1228: error: implicit declaration of function 'for_each_pmc=
_rtnl'
net/ipv4/igmp.c:1228: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_unmap':
net/ipv4/igmp.c:1333: error: expected ';' before 'igmp_group_dropped'
net/ipv4/igmp.c: In function 'ip_mc_remap':
net/ipv4/igmp.c:1343: error: expected ';' before 'igmp_group_added'
net/ipv4/igmp.c: In function 'ip_mc_down':
net/ipv4/igmp.c:1355: error: expected ';' before 'igmp_group_dropped'
net/ipv4/igmp.c: In function 'ip_mc_up':
net/ipv4/igmp.c:1400: error: expected ';' before 'igmp_group_added'
net/ipv4/igmp.c: In function 'ip_mc_del_src':
net/ipv4/igmp.c:1521: error: implicit declaration of function 'for_each_pmc=
_rcu'
net/ipv4/igmp.c:1521: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_add_src':
net/ipv4/igmp.c:1693: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_join_group':
net/ipv4/igmp.c:1800: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_source':
net/ipv4/igmp.c:1938: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_msfilter':
net/ipv4/igmp.c:2081: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_msfget':
net/ipv4/igmp.c:2159: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_gsfget':
net/ipv4/igmp.c:2212: error: expected ';' before '{' token
net/ipv4/igmp.c:2240: warning: label 'done' defined but not used
net/ipv4/igmp.c: In function 'ip_mc_sf_allow':
net/ipv4/igmp.c:2261: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_check_mc':
net/ipv4/igmp.c:2326: error: expected ';' before '{' token
net/ipv4/igmp.c:2322: warning: unused variable 'psf'

Caused by commit 1d7138de878d1d4210727c1200193e69596f93b3 ("igmp: RCU
conversion of in_dev->mc_list").  The for_each_pmc_rtnl and
for_each_pmc_rcu definitions are protected by  CONFIG_IP_MULTICAST, but
the uses are not ...

I have reverted that commit for today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__15_Nov_2010_11_46_51_+1100_70vNeCZ14/1f.Dlc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM4IL7AAoJEDMEi1NhKgbsiXcH/1ae7ygSHpHgwuE4QD0Mmy1E
o2PGaFIYYR7jBdcUZ2OEnH/+oY49ES48lZVU8uIZPejlzR0mFbb/bIL7r6Yp8kfb
4oGA92APu97u38vWFeOVCH2yGAaZJsfzm7W3hieSHfI/Gh+qsWEG5S49rX1mXh/f
iSu3hE6nZi2WbNlCE9JHAGCqJHAHnKq2Iw1SNtA9cMac699ZXnySClNFvIAG1eQe
e8fCKZk0SQkazvJXMSWeFRgjoq4he3sIydxd6u77aObHTS2SlV8NPMYyhLCI7aQB
Afz/tk/b8jdLEeBNyTjk+SEpOWSDHYZi9Ph3N08W5GwQMTa1EF92FJ/xFm2gHS0=
=r6UA
-----END PGP SIGNATURE-----

--Signature=_Mon__15_Nov_2010_11_46_51_+1100_70vNeCZ14/1f.Dlc--
