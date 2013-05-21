From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 4/5] perf: net_dropmonitor: Use bisection in symbol lookup
Date: Tue, 21 May 2013 01:45:42 +0100
Message-ID: <1369097142.3469.135.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tRevJHoDC/9C2G3h77db"
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tRevJHoDC/9C2G3h77db
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 tools/perf/scripts/python/net_dropmonitor.py |   22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/tools/perf/scripts/python/net_dropmonitor.py b/tools/perf/scri=
pts/python/net_dropmonitor.py
index 6acdc82e..32fcee0 100755
--- a/tools/perf/scripts/python/net_dropmonitor.py
+++ b/tools/perf/scripts/python/net_dropmonitor.py
@@ -40,10 +40,24 @@ def get_kallsyms_table():
=20
 def get_sym(sloc):
 	loc =3D int(sloc)
-	for symloc, name in kallsyms[::-1]:
-		if loc >=3D symloc:
-			return (name, loc - symloc)
-	return (None, 0)
+
+	# Invariant: kallsyms[i][0] <=3D loc for all 0 <=3D i <=3D start
+	#            kallsyms[i][0] > loc for all end <=3D i < len(kallsyms)
+	start, end =3D -1, len(kallsyms)
+	while end !=3D start + 1:
+		pivot =3D (start + end) // 2
+		if loc < kallsyms[pivot][0]:
+			end =3D pivot
+		else:
+			start =3D pivot
+
+	# Now (start =3D=3D -1 or kallsyms[start][0] <=3D loc)
+	# and (start =3D=3D len(kallsyms) - 1 or loc < kallsyms[start + 1][0])
+	if start >=3D 0:
+		symloc, name =3D kallsyms[start]
+		return (name, loc - symloc)
+	else:
+		return (None, 0)
=20
 def print_drop_table():
 	print "%25s %25s %25s" % ("LOCATION", "OFFSET", "COUNT")



--=-tRevJHoDC/9C2G3h77db
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZrDtue/yOyVhhEJAQo5Pg/7BB10z6arw8/D4E00yEqX8i6ctFnFr8ZJ
le4efiyGRgFRAHfiYELLXbZPBUn77SumPWeO4Xj5YskARxDUSpJMYN7JStVUx+j6
zS/80usc7TvXbG0SWSHFp/e6fsrgNDtn5HnNWAxo1YugbhMqPZyPE9QhhoQgneFR
rA1MncNMNKfA+EW/BfWKKjoIAR3yOLtbBuSFacr2c161IkNZ1RAgWpYmpQnTFhk8
eBlgB+MMbFrW3gOKKT1RcFXe86dhbltdAgA1L3ELA5qJn04M/EHmDsqnZ/njpNkw
DEmzIFWtr1m52epGZGxfce1VKuDq2Y2jxdozBbafRkKSMTJvihDVx7RKO1RnDknf
ODa170kpJJtmrX6c7XrGGhuN5Rj2QL3i6swDt0EF093c+qINRYcD9S7DAxg8eL9A
Y2bgy+l6pqr3WPhQNVIJ/GfAa7T+gfmkr8jmqG8ucBosSTBoRNiQ99emQNGGaUdr
NGJgrcMmojIKAM+KVBU/ooT31u0amRxvjEaohR5a4Us22ldWdL9ifH92IDRz/w/n
jIf0So2lhYBNTnOoNGS6pAlH+iYPf/9Uvir9BZaAqy/Td68n4+Ih5IfUgxkJfbwd
j6v79U3vCfdrB2PGmtbRCV2eevgAqyVYNy06Ad0xyFh8ealTXt6aOZ35Afuf3jzW
+qdeCnqGBaE=
=k9t0
-----END PGP SIGNATURE-----

--=-tRevJHoDC/9C2G3h77db--
