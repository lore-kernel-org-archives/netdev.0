From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 5/5] perf: net_dropmonitor: Remove progress indicator
Date: Tue, 21 May 2013 01:45:57 +0100
Message-ID: <1369097157.3469.136.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KHHl/WcQGtROn9MGfqv9"
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KHHl/WcQGtROn9MGfqv9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We can read /proc/kallsyms in a fraction of a second, so why waste
a further fraction of a second showing progress?

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 tools/perf/scripts/python/net_dropmonitor.py |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/tools/perf/scripts/python/net_dropmonitor.py b/tools/perf/scri=
pts/python/net_dropmonitor.py
index 32fcee0..b574059 100755
--- a/tools/perf/scripts/python/net_dropmonitor.py
+++ b/tools/perf/scripts/python/net_dropmonitor.py
@@ -15,28 +15,17 @@ kallsyms =3D []
=20
 def get_kallsyms_table():
 	global kallsyms
+
 	try:
 		f =3D open("/proc/kallsyms", "r")
-		linecount =3D 0
-		for line in f:
-			linecount =3D linecount+1
-		f.seek(0)
 	except:
 		return
=20
-
-	j =3D 0
 	for line in f:
 		loc =3D int(line.split()[0], 16)
 		name =3D line.split()[2]
-		j =3D j +1
-		if ((j % 100) =3D=3D 0):
-			print "\r" + str(j) + "/" + str(linecount),
 		kallsyms.append((loc, name))
-
-	print "\r" + str(j) + "/" + str(linecount)
 	kallsyms.sort()
-	return
=20
 def get_sym(sloc):
 	loc =3D int(sloc)


--=-KHHl/WcQGtROn9MGfqv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZrDxee/yOyVhhEJAQrqWQ/8DTDYpe0WzoA5BmPH8/SEjy0WxYirY1wQ
Xx/MhS3XsWi5Mk8dwBNdKhW0qhozHg0fxXSh19IVRtA7gqvFPy3r/3z3/lwV8Ufq
jOmJbrq54RyhJsiHOkHGi6ctJjts9gY0OtJLM7pkW+2Mrkb+/RjrIG254Q7KGhDT
+XWhMfF/rhABqab62HH5vGw2FK/ldT0GLHELB/om9aS9UjwazWQNTRdkDlCWtoHT
QspLKJovoPnwq8KE2PvdLJpKG4B0ZvhTRnUuaNk3+aCIVBNmG+r8LZkgIROz5Tu/
LxsO1fP3oSF1+L3dGmMj8B0iRxRPiPuXm/MW5SkoYYhhFR3xbJMZ8uVTbFn1wBSF
dCo6wKeHOUNUVxL+O1fCr15CZyp0FKv1j6B6fHfppu/fbhnTG/U7znpjBP8C7Tj1
QQrhKN3sO+GsHQOwcADa6MrnsYEq2YMHYkVRmTN/p7ZI1YFZk++nqFENS7FGFHWm
jwt/k4WEgYctoQs/eW5Cx1VBp51fRqqgr3LTLU/A1fiTFVLJyrsXOcpPotVofQfS
HfuhOKDlme96KMiEnTDby0JOQSkaCZj8JUe4WBqRFEg6pBRqS8aatwEmWpv/Xk5n
MPGgCMA8AhBMXFI2d4DUDTPILRPT2drrYSJ+FD5ErgYsOsImEn3hVXTQulaLUMA3
FgvhBEPTicM=
=r9Af
-----END PGP SIGNATURE-----

--=-KHHl/WcQGtROn9MGfqv9--
