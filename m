From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 9 Jul 2014 13:26:19 +1000
Message-ID: <20140709132619.19eb3f6a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//LD23Ml/Efg.AWxd8mRK1zy"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_//LD23Ml/Efg.AWxd8mRK1zy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

In file included from include/linux/tcp.h:23:0,
                 from include/linux/ipv6.h:63,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:27,
                 from include/linux/nfs_fs.h:30,
                 from init/do_mounts.c:32:
include/net/ipv6.h: In function 'ip6_set_txhash':
include/net/sock.h:327:33: error: 'struct sock_common' has no member named =
'skc_v6_daddr'
 #define sk_v6_daddr  __sk_common.skc_v6_daddr
                                 ^
include/net/ipv6.h:695:49: note: in expansion of macro 'sk_v6_daddr'
  keys.dst =3D (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
                                                 ^
In file included from include/linux/sunrpc/clnt.h:27:0,
                 from include/linux/nfs_fs.h:30,
                 from init/do_mounts.c:32:
include/net/ipv6.h: In function 'ip6_make_flowlabel':
include/net/ipv6.h:705:37: error: 'struct net' has no member named 'ipv6'
  if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
                                     ^

And lots more ...

Caused by commits b73c3d0e4f0e ("net: Save TX flow hash in sock and set
in skbuf on xmit") and cb1ce2ef387b ("ipv6: Implement automatic flow
label generation on transmit").  This build has CONFIG_IPV6 unset.

I have used the net-next tree from next-20140708 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_//LD23Ml/Efg.AWxd8mRK1zy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTvLZgAAoJEMDTa8Ir7ZwVTlMP/RJiDnsiPndLfxDp159bHFsU
549Oj2Mfrm/bAUiFchg/3kPbbHv3GqVdV66PvTbJuLipB9tgCduv01YYn/dOkpBb
CSbsE0OMJkXSdDxAn/4Y35c/4P61RsBpxcmFBvKL6H9rvWYEriJ1iGWnKlGyN/W6
q5MPa+VAnrBXy56URTPUd86iwXgCMZZvN1LRpf7oluJjrMLL4lKz6vTECRWDwHb3
4W5v2xUYy1o+DBlxhHspSsNYyRUVWPrmVXXhyywMV6D5Onro4NROeKow8NitNLv4
VVPxcInXeA5vdhogbDtlcvV32+cRfww4sgR2RBdpcZe5QBgSgSTJygG6gro8mIGU
WpH8ogdtcZ+zoybz+HUsLO6qAmKet0USuYD4fcsUO9doMqy4L6cBvnuab5/N2I/t
NWLTm4HG27dOG/E5IuoBDU1ZHX23dPbYhX8n8YD2fSD0/SzaUcpBEIY7MJMspffh
rK/kxuTYXDw5aBe8ajulT8sWa3+dHG+GOlN0bylhSxAUUXuWhQ08VaJ1oQxqrqMz
1t16APGCuhP5ugVOKa0D9se1xCcITQgij4ddZCBg/0YW1xB79HVDhQWMZPddpoIm
eQX+PzT/NkwjPsgkjy91yb7AJIDfyZPQRjb+NuKbo/4dQrCeMXr47dnAAf3zM9n3
/mRIiP8/Pcs1eq8ZoZRr
=3ZgA
-----END PGP SIGNATURE-----

--Sig_//LD23Ml/Efg.AWxd8mRK1zy--
