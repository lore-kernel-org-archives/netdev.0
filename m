From: Johannes Berg <johannes@sipsolutions.net>
Subject: compat_sock_common_getsockopt typo?
Date: Tue, 06 Mar 2007 00:26:51 +0100
Message-ID: <1173137211.15891.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tosyh4j1/RgjOKKP+OpE"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59815 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934108AbXCFNLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:11:36 -0500
Received: from [131.234.73.23]
	by sipsolutions.net with esmtpsa (TLS-1.0:RSA_ARCFOUR_MD5:16)
	(Exim 4.63)
	(envelope-from <johannes@sipsolutions.net>)
	id 1HOZNX-00030T-7O
	for netdev@vger.kernel.org; Tue, 06 Mar 2007 13:06:55 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tosyh4j1/RgjOKKP+OpE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

The function reads as follows:

int compat_sock_common_getsockopt(struct socket *sock, int level, int optna=
me,
                                  char __user *optval, int __user *optlen)
{
        struct sock *sk =3D sock->sk;

        if (sk->sk_prot->compat_setsockopt !=3D NULL)
                                ^^^

                return sk->sk_prot->compat_getsockopt(sk, level, optname,
                                           ^^^
                                                      optval, optlen);
        return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
}
EXPORT_SYMBOL(compat_sock_common_getsockopt);

Is that intentional to make protocol writers assign both if they want
compat_setsockopt? :P

johannes

--=-tosyh4j1/RgjOKKP+OpE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF7Kc6/ETPhpq3jKURAkDwAKCRGvsINOsO4rghazRIIgu5ocCU9wCgjJ/B
PsIoVEP0T0iL+CdKzmxdOxA=
=G58D
-----END PGP SIGNATURE-----

--=-tosyh4j1/RgjOKKP+OpE--

