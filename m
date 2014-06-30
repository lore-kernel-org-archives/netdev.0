From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 30 Jun 2014 12:47:50 +1000
Message-ID: <20140630124750.0aad0c82@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/VJceZM/kZSHofSPljmo4_NY"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Octavian Purdila <octavian.purdila@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/VJceZM/kZSHofSPljmo4_NY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

In file included from include/net/inet_connection_sock.h:23:0,
                 from include/linux/tcp.h:24,
                 from include/net/tcp.h:24,
                 from net/ipv4/tcp_input.c:72:
net/ipv4/tcp_input.c: In function 'pr_drop_req':
include/net/inet_sock.h:77:41: error: 'struct sock_common' has no member na=
med 'skc_v6_daddr'
 #define ir_v6_rmt_addr  req.__req_common.skc_v6_daddr
                                         ^
include/net/sock.h:2273:57: note: in expansion of macro 'ir_v6_rmt_addr'
  do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)
                                                         ^
net/ipv4/tcp_input.c:5889:3: note: in expansion of macro 'LIMIT_NETDEBUG'
   LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI6/%u\n"),
   ^

Caused by commit 1fb6f159fd21 ("tcp: add tcp_conn_request").  This
build has CONFIG_IPV6 unset.

I have used the net-next tree from next-20140627 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/VJceZM/kZSHofSPljmo4_NY
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTsM/fAAoJEMDTa8Ir7ZwVl1oP/jXgyvUq17AfiQBGrn9C+s0x
UXxFoGgtzjad461wUsvdg6NR6Kgq9FYMDVi1Eu6lkRMvTCNxaR5rOAU9U1TC759X
5L2F2qhly7bPMlbNlJgssbYtkWYktdBf9uCHYoZUuV4oO2y5t2JisnA65EuMNea8
OIJjX/JdrklBPUImmih8XfNeJIbf1eFcB6p19GhiXDYyIQJH+Y+ajgXOhAYe/DGz
Za9r+qdxGnTZCi/Y3zT1swBWLPm4juUPGPJU5ZkJrlLylFcjfClJ8jjnMSH6cqX4
Lcm0KB+iK/s4+eX0mLwi09k6DQ6fotJmJ8X70y/5jheVLxnJV0bYdx/aT3nJVz2q
vZim8bWDlgaFJEUG66/F9heNIJhA7AS6/iwP4FTxbT2PWF/j2YDttM+zz4pbi0bu
yxnCIhyBahWx6v46yeQp/civLXnhfq4yDEovPkV8kBPShCPyCa1JNeJ2PM+qIdRT
MdnSndKHM+Xr8dU9ZtktRt9py5HHq+mgqic6WKFArYElkv/lbIGcjn8cQwYx+IU8
84/C+opaaVXetbroLl203A+sg2z9/CW07u7LmauDfpRRcY67vXOs5P/XImmI9bTz
xiTA3w5J+7739KTVUINMGN7fVLTie7gRKDnGgwSwm7Smuyj+eAGdK2zw0760MfEp
8D9gcpbPl+duWRtghaVP
=XcTH
-----END PGP SIGNATURE-----

--Sig_/VJceZM/kZSHofSPljmo4_NY--
