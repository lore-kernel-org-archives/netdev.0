From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Compilation issues using netlink.h
Date: Tue, 05 Jan 2010 02:32:23 +0000
Message-ID: <1262658743.26813.8.camel@localhost>
References: <4B37FCB3.9000800@linuxfromscratch.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-g3mqikQz69KrcvV503Xf"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Matthew Burgess <matthew@linuxfromscratch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52481 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753776Ab0AECc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 21:32:29 -0500
In-Reply-To: <4B37FCB3.9000800@linuxfromscratch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-g3mqikQz69KrcvV503Xf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-12-28 at 00:32 +0000, Matthew Burgess wrote:
> Hi,
>=20
> The test case below simplifies a failure I see when trying to compile=20
> strace using kernel headers from Linux-2.6.32.2:
>=20
> #include <linux/netlink.h>
> struct sockaddr_nl nl;
> int main() {
>    return 0;
> }
>=20
> $ gcc -o test test.c
> In file included from test.c:1:
> /usr/include/linux/netlink.h:34: error: expected=20
> specifier-qualifier-list before 'sa_family_t'
>=20
> The comment in netlink.h suggests that 'sa_family_t' is expected to be=20
> found in linux/socket.h, but since commit 9c501935a3 ("net: Support=20
> inclusion of <linux/socket.h> before <sys/socket.h>") that appears to=20
> not be true anymore, it's now in sys/socket.h.

Right.  I'm aware of this and suggested that it should be reverted, but
David Miller reckons I was right in the first place.

> Sure enough, if I change=20
> the include in netlink.h to pull in sys/socket.h instead of=20
> linux/socket.h, that enables the test case (and strace) to compile=20
> again, but I wasn't sure if it was really the right thing to do.

I don't think it is - that will bring in many more definitions.

There are actually a whole lot of kernel networking headers which
require sa_family_t when included by user-space code.  Until
<linux/socket.h> and <sys/socket.h> cooperate to define sa_family_t
once, you will just have to include <sys/socket.h> before kernel
networking headers.

Ben.

--=20
Ben Hutchings
The obvious mathematical breakthrough [to break modern encryption] would be
development of an easy way to factor large prime numbers. - Bill Gates

--=-g3mqikQz69KrcvV503Xf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS0Kkree/yOyVhhEJAQIWaw//UdNSAIQLYyg2S7jEhMdeYtIVMGRFs9IZ
k4PzE6gZVoS3611wfJEiuc41Dput/YF2Np7+gYw8Ng2zHtlc5lAtjGzGLybwmKb8
SMZgDS+2NIeTKyxxMElx+btulpnMLS5iAFA+DaoG+ZM8YOZh0PWSBQ7YzYKfYwMe
+NYJrFA588+YyB0yOMqe4yEhKBHaBXpMaCI73HUXmPGHDON/DU5vY6Q3/UStGyqC
yIgzSqnEaioeGa2bZdBmppdk6x9q5xJ3FYLDiZ4/mT0YVAJSEoLV+hVlMoKMAmFc
pkehza7JRh2cop66TCm/3UvLgby3wXgEskI44F3+HflUzpQ12bFrYC8BHKAIZDVH
3vGiV7x00wwNPfnTriNsrHsJz+RhHnHTTgwGO/xxkzkA42gCfZUyZVgn/7OTdwUr
nsjtT+knRRkap+EHEL4Bi7nmjeKYxZfim1PlioCK3w4dyJ3htj2CyhckALoMCv0P
fVzDZfG4L0OrlTzXofCk1rlQboZQAKawo4ZAip/jETCTFhlTGCzTH3+PmdWNmBTU
lklei/Tv9doF5Q4RhpNeFLKYK18qjlEthWH2LakQbrepR0Qa26aqfKjqphg6x/Ph
dJSN3EDgF/JfUZEPlAKLWSae8xFJQhCU1rL9XXg7TtP7v7xZriZApMjxBr/upoV+
yQYj264DkuE=
=0yBq
-----END PGP SIGNATURE-----

--=-g3mqikQz69KrcvV503Xf--
