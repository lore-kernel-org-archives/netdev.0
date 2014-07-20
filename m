From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net] dns_resolver: Null-terminate the right string
Date: Mon, 21 Jul 2014 00:06:48 +0100
Message-ID: <1405897608.8631.13.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yl5CpZC0wjt95Umc6WTt"
Cc: netdev <netdev@vger.kernel.org>,
	Manuel =?ISO-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36528 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265AbaGTXHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 19:07:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yl5CpZC0wjt95Umc6WTt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

*_result[len] is parsed as *(_result[len]) which is not at all what we
want to touch here.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: 84a7c0b1db1c ("dns_resolver: assure that dns_query() result is null-=
terminated")
---
v2: Add the Fixes header

 net/dns_resolver/dns_query.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index 9acec61f..dd8696a 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -150,7 +150,7 @@ int dns_query(const char *type, const char *name, size_=
t namelen,
 		goto put;
=20
 	memcpy(*_result, upayload->data, len);
-	*_result[len] =3D '\0';
+	(*_result)[len] =3D '\0';
=20
 	if (_expiry)
 		*_expiry =3D rkey->expiry;


--=20
Ben Hutchings
Make three consecutive correct guesses and you will be considered an expert=
.

--=-yl5CpZC0wjt95Umc6WTt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU8xLjee/yOyVhhEJAQrRmw//X4050c0UgwCuGuarsBP9a1HXxO+UJn1k
Go/CexauAXCnEET+kl09lD8AVnczpOHzsCYuVliBz3oeZyK0O+EmpMOCswVQWKzz
tJUUH0ZQZGzzakw6rz/gjsid7TgAQ0hHdXxLasq1gQNGRXOMaikT3JBLlzrQxs01
zKMkRX3XArkh4nsj7b6kkonO/ludeOA928UddqNKvN4+nhwfe8rIolYYq9PMR9CS
a3LaOsxNfLe2UKz/duXGIxcYAgYEQK3NI2c60EZ3InMsfRLu6L/yHXE68m2IaJiX
RfeZxnI6PJXwFYz7CFh6gsG2NXD9b5+ddAc4cAVKJUHu2hQWyZY5y3TZBCFcMJa8
8Pe85ixBj9OwJcInc5W5WVmDPe6HQNGxnpDGk4Ft4n82w5h+PGeZHlTedY1bDsTK
DqiuK2qPRfNu5sRbQv4EShlvfXha/OxMnOkdQmIUfdX2uR4kKqnm1fQp0VUaZ7zZ
0YSryXiP7u/jXynvv4IFjDzruYzYyUEfO1529ASYWdmE/p95ZBWqHUaW242Ia2Th
wnd2P3ZwbInBbZub7G0stVMPDJZBOKg3h6lTBvV2I7l4/OD4omiIJ3GIpIfnulkx
5FMpMBbDpSpiyDBMazUEOjCNjZgo8Tx4mLHqhKctSGUWnnIC2IZOwqIlLinb5Q7V
MG/cBnHatzw=
=kJvB
-----END PGP SIGNATURE-----

--=-yl5CpZC0wjt95Umc6WTt--
