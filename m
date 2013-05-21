From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3/5] perf: net_dropmonitor: Do not assume ordering of
 dictionaries
Date: Tue, 21 May 2013 01:45:34 +0100
Message-ID: <1369097134.3469.134.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CNAU/NIdG04fRS9ud95b"
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CNAU/NIdG04fRS9ud95b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The sort order of dictionaries in Python is undocumented.  Use
tuples instead, which are documented to be lexically ordered.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 tools/perf/scripts/python/net_dropmonitor.py |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/perf/scripts/python/net_dropmonitor.py b/tools/perf/scri=
pts/python/net_dropmonitor.py
index 4c11605..6acdc82e 100755
--- a/tools/perf/scripts/python/net_dropmonitor.py
+++ b/tools/perf/scripts/python/net_dropmonitor.py
@@ -32,7 +32,7 @@ def get_kallsyms_table():
 		j =3D j +1
 		if ((j % 100) =3D=3D 0):
 			print "\r" + str(j) + "/" + str(linecount),
-		kallsyms.append({ 'loc': loc, 'name' : name})
+		kallsyms.append((loc, name))
=20
 	print "\r" + str(j) + "/" + str(linecount)
 	kallsyms.sort()
@@ -40,9 +40,9 @@ def get_kallsyms_table():
=20
 def get_sym(sloc):
 	loc =3D int(sloc)
-	for i in kallsyms[::-1]:
-		if loc >=3D i['loc']:
-			return (i['name'], loc - i['loc'])
+	for symloc, name in kallsyms[::-1]:
+		if loc >=3D symloc:
+			return (name, loc - symloc)
 	return (None, 0)
=20
 def print_drop_table():



--=-CNAU/NIdG04fRS9ud95b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZrDrue/yOyVhhEJAQr86A/8DPr9oHYhbLtgT+K9BVdum2un9JznvSdT
BINXTBWQHXDBUKdEszLsHneaGYj8xMm5S1142l8PEW/BFWR6MEL4+iuVxMi/o9kA
lNvhSEXLJkQTR9JUXMBQnnxCnmOo+z5Gozd74F1Kwm2kD6EbMJXVrBQFI4QeE7cO
ujwP5wQs+G+JDJaP+YCucvLardZM1MrhyHxHNxX/vxlhW0ANr0ZKCBPLKh6HPUhQ
Hh4SP+Oyx84QHYl6PQ0Snbxq1L1cp+aukvMlPHdpLbug0cvForPzF/CUxV+E320w
sIjHxA2eBkV5cQjzKCxOO0Ok9pM0oAtpEJyGnx5DPbgI5h9IF4oekJIjgimqTzMm
Z4fanxS4LiuWfbv/bQ6feCi2t3v+M9HarzN+/YjH7lmfpZvdyU90yzr7NVy1BRzV
1AoTUA2rAVX3c8Y+F5adEjLygnD2KQ7yy6632V6cvLwcu5F1IVZKur14lTOdKWpy
xih48q3CBngzKExQdzmQBjWktWPULcj2qkIXb1O3tAVFl4EFuMvJpEQRYz9kLPRA
bt91vIoJ1Q+1jc8ez4vdZey8YoGkeoh8TNZYT6B424EyfKqei35bI5CN2V3Ag+Uq
CzMeFuswrKRrz4MlEib+n9EIgGuMpSYZdUQSoPvSPpti8ZF97JSEYIRmb8Cqi1VK
VFTamonIrd0=
=9PQw
-----END PGP SIGNATURE-----

--=-CNAU/NIdG04fRS9ud95b--
