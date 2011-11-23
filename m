From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 23 Nov 2011 11:17:51 +1100
Message-ID: <20111123111751.60b1e8ba032f6077fa03ca13@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__23_Nov_2011_11_17_51_+1100_1thCe.__6n2=ThQY"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__23_Nov_2011_11_17_51_+1100_1thCe.__6n2=ThQY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv4/inet_diag.c between commit 717b6d836646 ("net-netlink: fix diag
to export IPv4 tos for dual-stack IPv6 sockets") from the net tree and
commit 4e3fd7a06dc2 ("net: remove ipv6_addr_copy()") from the net-next
tree.

Just context changes.  I fixed it up (see below) can can carry the fix as
necessary,
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/inet_diag.c
index ccee270,bbebdec..0000000
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@@ -132,13 -129,10 +132,11 @@@ static int inet_csk_diag_fill(struct so
  	if (r->idiag_family =3D=3D AF_INET6) {
  		const struct ipv6_pinfo *np =3D inet6_sk(sk);
 =20
 -		*(struct in6_addr *)r->id.idiag_src =3D np->rcv_saddr;
 -		*(struct in6_addr *)r->id.idiag_dst =3D np->daddr;
  		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
  			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
 +
- 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
- 			       &np->rcv_saddr);
- 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
- 			       &np->daddr);
++		*(struct in6_addr *)r->id.idiag_src =3D np->rcv_saddr;
++		*(struct in6_addr *)r->id.idiag_dst =3D np->daddr;
  	}
  #endif
 =20

--Signature=_Wed__23_Nov_2011_11_17_51_+1100_1thCe.__6n2=ThQY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzDuvAAoJEECxmPOUX5FEBh0P/2oKg99DWqZnmILmMvkYLuax
DXoKW9V7yxixy5oYPgTyG3WlAA53WsifGbBqkwvK9EYZBWRceGqYZ9oMLdZZEKXa
R8pg5qnXRigu9etv5wZAqGCAoKA2R9aShZHlR4FGn6UVkAvYe06XhSij99k8C4KH
+pSrahqZ2sgqusBErkucadqSZ8h/UviG/ElXfmz0l5YTKJdrkECykEqo9K2Ur34Z
ChnQPJLY0GyAvKDzvaUGX/aajbKFct60cKgy0SMe6vciSyYCPMwxjH6b0+PVodTU
Hcjm81++lHTYPWsM+7uExL9+fVW/qQSyvZiuHGTmN7ZLJFt2ZSWoc9mgpDpSZ/56
izzZrOKLLtQkFEwDZvkEwKYRGahfevpDKmxBwTLPaW+MElpr8pX+9VPG7hfP3gk1
1zMpVndh/rGf2b1Yfl8Z2UHYCr0ogtWSG0Yf9+ZGOVUCNt1gOqrMoYCkQUAvXiym
B52r4MBvFn696UfxUsTm/RbGXIVeIJ/cZTpFh35q0BlqoYJdHnwV//pGefqjxXdW
3fP3/9pZer4rYkOm+np+o6ODuHrqJI5oG8bcSMhj5tct5qsv/1Fk95yoxq8SI9Fm
PoRbRf2oiOeypGGfaXVaSjy6Wl2pqGEN8Sq3evJQRQnX+xwp8SBsZqQVI8MOvkct
wCu+BsZPuc+stmKUtEms
=Ef/y
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Nov_2011_11_17_51_+1100_1thCe.__6n2=ThQY--
