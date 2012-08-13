From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 2/3] llc2: Call llc_station_exit() on llc2_init()
 failure path
Date: Mon, 13 Aug 2012 13:50:43 +0100
Message-ID: <1344862243.824.141.camel@deadeye.wl.decadent.org.uk>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+AFr+pCc85fMKuxInWwb"
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39146 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab2HMMus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 08:50:48 -0400
In-Reply-To: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+AFr+pCc85fMKuxInWwb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Otherwise the station packet handler will remain registered even though
the module is unloaded.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/af_llc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index f6fe4d4..8c2919c 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -1206,7 +1206,7 @@ static int __init llc2_init(void)
 	rc =3D llc_proc_init();
 	if (rc !=3D 0) {
 		printk(llc_proc_err_msg);
-		goto out_unregister_llc_proto;
+		goto out_station;
 	}
 	rc =3D llc_sysctl_init();
 	if (rc) {
@@ -1226,7 +1226,8 @@ out_sysctl:
 	llc_sysctl_exit();
 out_proc:
 	llc_proc_exit();
-out_unregister_llc_proto:
+out_station:
+	llc_station_exit();
 	proto_unregister(&llc_proto);
 	goto out;
 }



--=-+AFr+pCc85fMKuxInWwb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUCj4I+e/yOyVhhEJAQpZCw//Tx4rSX4KOz0CNF8Kdzk8xNoUdeb0Hm03
5EmhnSBK4+wGmD4JO983EsMXsJfTtzkBh2xhLaZca6KTIugmmgtm/nypwR/X0O8k
ZOL9rMqrNhp9LrPMtySOrTq8d1DrqKjIQD2cTNC3mcWdBulOYMvXSchtLtDXuos6
QnJpzfPn7/vvqrNbr/XllsfgFFPgMzFea2CGtRWon51Sp5/XoeFN6ctK2Z97+iiW
vUQwyJgWTvPTlu3Fs9eY5oJyfSNBJ9F8NxughLVAlc3wxOSIzJKxPIVCzgs9xHwu
ZwQDsu0EIPlLnKdq3uWr7sTciFqK0Gk1i4HH6COnBn1RSU0vbyH+NXqCyI7cVlca
t7Ez/pir+7MJaECG5ceTvx/aMNr5/1LjFqxIIMJq16hCm+2ZeqhN78a+GeY/i8QP
PJRdG1sYF1/EuEgXKwfN96fJezjutTzxiu2xPtm9QXAp4HcX9QP9MaxFAZR9UuQs
a4hEoo010W/t0+oGMxTL2XtaziaCbRlSz3/t+kjkT9Us8IElnRjN6LfUIdylmR+W
M/a5PAALqj5lbxx0lU3eMtPpGB71v+cA58y+K4lZlfIYLSQTea7Jra66nZ6UNaR1
1wFQUohPcZn08+GmE+TmABbP5RiqmyI7D1EYCFPt5KsHfVv9b2pc4GWUkHbSVK/Y
IHszIZ2iNno=
=xXwv
-----END PGP SIGNATURE-----

--=-+AFr+pCc85fMKuxInWwb--
