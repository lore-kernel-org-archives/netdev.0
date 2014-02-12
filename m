From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 12/14] ethtool: Document the general convention for
 VLAs in kernel space
Date: Wed, 12 Feb 2014 22:14:53 +0000
Message-ID: <1392243293.15615.16.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zxUhAl1br4ly871i8BDv"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52809 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbaBLWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:15:00 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zxUhAl1br4ly871i8BDv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Various ethtool command structures are declared with zero-length array
at the end which are intended to be variable-length in userland
(relying on lack of compiler bounds checking).  However, in the kernel
the structure and array are always allocated and passed to driver
operations separately.  Make that explicit.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/ethtool.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8e3e7e3..0a114d0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -183,6 +183,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index,=
 u32 n_rx_rings)
  * hold the RTNL lock.
  *
  * See the structures used by these operations for further documentation.
+ * Note that for all operations using a structure ending with a zero-
+ * length array, the array is allocated separately in the kernel and
+ * is passed to the driver as an additional parameter.
  *
  * See &struct net_device and &struct net_device_ops for documentation
  * of the generic netdev features interface.


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-zxUhAl1br4ly871i8BDv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyXee/yOyVhhEJAQojWBAAx1ZL2yEGKLcY8E0mtRfJV4XVzeFoa3EX
kaU6KMg8JLGl6JOE3vXv8deHfkjxTInhGuHhvtGzSn5dKDoT9o4O7kqMvUmCXV8f
oHr16ntuqFXQHBOh/Zyr+uqD9yxPZ/vNAwCgxaVhwCoyVQo4xvfl47lpvavgqNPm
sKrkagwgi9b+kACCIL1KgLLe7ktWOwi1p+49sRsCSdtjwBk3iQEBIiY9RH2cCPxE
bGe6y0exQHh2rB24IOPNfb0sOg7Eusi4SANjANA8F3TCJIulV7ze91OJRmPfHvAj
vuFRQDfZwghjXGhrGeJ587sMuT6eDRbXZym44cAFbHHJIAPud7JqdppmwtEr6EAH
LK7jWbEl5YyVJ/J63Gyjk86Tf29f3CVxJ4zFYtQqQH/BUN7LeHRVEI6/7vqpZDFj
bKFqc7d0YmynxPwll/yoHjykq+4ENl157hyyOfzGDV2ds1YJofymflxLqx53WUOf
aHKt1COjt5iJqoXBs9yZ4+Xq4ruHiKblx+l/IMXE1hlsc8+kbZT6zc/WXwXA/zwr
yRua1FZyrsMeFTmM4SMuhACKH1PeBMqwpWdWhUWzcy6GghMFldqu9gZHde9KPve2
O2zApcazeRqLXqEQc8TOi6P7nL2cjsI/3ioEnoHFXX9OJsn4vz93GwXhPJ2lAUYT
rIl51/nZ81I=
=Hqqu
-----END PGP SIGNATURE-----

--=-zxUhAl1br4ly871i8BDv--
