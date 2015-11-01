From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net 1/2] isdn_ppp: Add checks for allocation failure in
 isdn_ppp_open()
Date: Sun, 1 Nov 2015 16:21:24 +0000
Message-ID: <20151101162123.GA9478@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="Q68bSM7Ycu6FN28Q"
Cc: Karsten Keil <isdn@linux-pingi.de>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Re-sent using mutt since Evolution 3.18 mangles patches.

Ben.

 drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index c4198fa..86f9abe 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
 	is->compflags =3D 0;
=20
 	is->reset =3D isdn_ppp_ccp_reset_alloc(is);
+	if (!is->reset)
+		return -ENOMEM;
=20
 	is->lp =3D NULL;
 	is->mp_seqno =3D 0;       /* MP sequence number */
@@ -320,6 +322,10 @@ isdn_ppp_open(int min, struct file *file)
 	 * VJ header compression init
 	 */
 	is->slcomp =3D slhc_init(16, 16);	/* not necessary for 2. link in bundle =
*/
+	if (!is->slcomp) {
+		isdn_ppp_ccp_reset_free(is);
+		return -ENOMEM;
+	}
 #endif
 #ifdef CONFIG_IPPP_FILTER
 	is->pass_filter =3D NULL;


--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVjY8A+e/yOyVhhEJAQrRPQ//e7mTCsl37oBPnQYTuo7PHivzBy1i4+eB
WhVBhETrjmz8sACU8lnEr5v0P/Anpz6DSk8ldCQMJp7gOmN+hWxjZRY6cLKNo4wx
sjrNeRW44WgQUDWZJOLT3T4/QUVRYFYqUNl302luw/Qz+zmqb3pnx+6wBb+NUpkM
pBUzqeEPXAR9puOhDW+sxtq2XXCbvpi0Tc6kXuQiCnD/bF/J8cO4J6mTvj7ZmtO/
EEzJCEIZ993HqZoqa/VSkis49WYrLRZJ+bkvQOLDrf99VlDqf0wx0RY9DWy256a+
EMBb4Vn17JRImOv+sAd7OrZhnwebhSkrC060Sdz/w9aFLct/mQAMStHAtOtg0tzi
lhJIpDsqZOwXSynGG8n1ovKQisI71UjiYuoZvSSWvYsEtHeK5FnVlfDjZTQ+/Z0X
3Xw8ESFAAx3PtI4CskeTFQ1wfEczfK0PNfKWn5+nARgJHkMyAhO1Rh1gtjTXXFzd
WgA5qnHF7+XrSoGb1UnW20vnlbwCX3byHG3zIl+8YJZDsFRtc0gv9ANFEgn1v9aD
D2k4wIiXhFJ2e/HLAxhwlBOEQrNrYcAZc/PdNS34X5/DEZJ0IAoNOkj93FcS6Hv0
gc61/S1vLa/QsD+XWuxkEVeku/0Goxz3PLL2grt/CGE8P/IgZXWemfvK2r2DRYB5
Og3FmivceEo=
=3fnT
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--
