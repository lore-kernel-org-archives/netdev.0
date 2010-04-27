From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Tue, 27 Apr 2010 15:25:16 +1000
Message-ID: <20100427152516.580ee620.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__27_Apr_2010_15_25_16_+1000_zmE2q3ePh3gYHmLk"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__27_Apr_2010_15_25_16_+1000_zmE2q3ePh3gYHmLk
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the bkl-ioctl tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/bridge/br_multicast.c: In function 'br_ip6_multicast_alloc_query':
net/bridge/br_multicast.c:469: error: implicit declaration of function 'csu=
m_ipv6_magic'

Introduced by commit 08b202b6726459626c73ecfa08fcdc8c3efc76c2 ("bridge
br_multicast: IPv6 MLD support") from the net tree.

csum_ipv6_magic is declared in net/ip6_checksum.h ...

I have reverted this commit (and 1fafc7a9353ef68e1b8d4bb130cb6402cf7dfd5a
"bridge br_multicast: Ensure to initialize BR_INPUT_SKB_CB
(skb)->mrouters_only" which depended on it) for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__27_Apr_2010_15_25_16_+1000_zmE2q3ePh3gYHmLk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvWdTwACgkQjjKRsyhoI8xo+wCfe4NdgRI1vaoMbE8ANt90c6FM
ivUAoLtCRRS74MM3l9r6cRXDLumxr8Qc
=W3lN
-----END PGP SIGNATURE-----

--Signature=_Tue__27_Apr_2010_15_25_16_+1000_zmE2q3ePh3gYHmLk--
