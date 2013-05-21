From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/5] perf: net_dropmonitor: Fix symbol-relative addresses
Date: Tue, 21 May 2013 01:45:26 +0100
Message-ID: <1369097126.3469.133.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nMgJhR+RqddZrm3XOqIx"
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	708994@bugs.debian.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nMgJhR+RqddZrm3XOqIx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The comparison between traced and symbol addresses is backwards: if
the traced address doesn't exactly match a symbol (which we don't
expect it to), we'll show the next symbol and the offset to it,
whereas we should show the previous symbol and the offset from it.

Cc: stable@vger.kernel.org
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 tools/perf/scripts/python/net_dropmonitor.py |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/perf/scripts/python/net_dropmonitor.py b/tools/perf/scri=
pts/python/net_dropmonitor.py
index adbfbf0..4c11605 100755
--- a/tools/perf/scripts/python/net_dropmonitor.py
+++ b/tools/perf/scripts/python/net_dropmonitor.py
@@ -40,9 +40,9 @@ def get_kallsyms_table():
=20
 def get_sym(sloc):
 	loc =3D int(sloc)
-	for i in kallsyms:
-		if (i['loc'] >=3D loc):
-			return (i['name'], i['loc']-loc)
+	for i in kallsyms[::-1]:
+		if loc >=3D i['loc']:
+			return (i['name'], loc - i['loc'])
 	return (None, 0)
=20
 def print_drop_table():



--=-nMgJhR+RqddZrm3XOqIx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZrDpue/yOyVhhEJAQo7eA/+P0CvUGEbpYsrCfa4WES9LlRvhfa/YalK
nJ4juEMSP/1oNn/aBZyRRALop9qXa11C736PBPK+9/q/mQ+pOV2r60SSZ0TqzE0z
RLCiYm2RB1nf+OgJKx6OWAilUkjqV0cjynO9zXFxjCE55YbUaPoX5Y3nO0bf/cUI
M1uN7XhL2SysO/fdhUVLUXC/hWQwjY6NHn/dzGVpy6pH2dcdoRMxAVlUC3Qe9PiK
k0FTrDZqvIwQa7fmkHIbdD7LIykH9Kh9qs3DmnPoIZku/dFkIcv+nNk05yHeoxYf
3ZuCpyF4vVfllHfP5RfkhkLjL0VguR/WiUc/NL+c9g6HvOQidTK0+kYyhmv8dLKi
Clr+dM+KPs23/Wnz0t/nxNoWl6ped/b+Kx4BxhXmtr1SZlh4GSLyqWbySgH8YJzH
gesrhPfWZ0hQROeBXT5Xyo6HnnwUPYo93B1oXmotNW/JCksX9GaLgvvaUhdMFM93
eCJQSw0wimShk8YYfhw2pfGe2jInf28kwzYLRzx+462olEXayMOgmllP47KIWQBa
ce8j5KpkwmulqetAgLQxGfUrtoHjOF6ywA95PviRVQ/T8WSJd3qN1LinapWUe7h7
6USKUOmNFC2fYc6FdeEy5qpolPhCou5QsFQeLzWwEzwVRX4RHLIRuY/8ySUO1Ey6
yB3gpDoibBc=
=ZWQv
-----END PGP SIGNATURE-----

--=-nMgJhR+RqddZrm3XOqIx--
