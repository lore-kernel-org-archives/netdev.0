From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: [PATCH] reduce stack usage for arlan
Date: Tue, 8 Mar 2005 16:34:57 +0100
Message-ID: <20050308153457.GB8703@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes indicated that this driver is currently unmaintained.
Jeff, do you want this patch?

J=F6rn

--=20
Fancy algorithms are slow when n is small, and n is usually small.
Fancy algorithms have big constants. Until you know that n is
frequently going to be big, don't get fancy.
-- Rob Pike

SARLSTR is never called with nn bigger than 48.  This patch should be
safe and severly reduces stack consumption.

Signed-off-by: J=F6rn Engel <joern@wohnheim.fh-wedel.de>
---

 drivers/net/wireless/arlan-proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.10cow/drivers/net/wireless/arlan-proc.c~arlan_stack	2004-09=
-04 22:59:04.000000000 +0200
+++ linux-2.6.10cow/drivers/net/wireless/arlan-proc.c	2005-02-03 21:29:33=
.000000000 +0100
@@ -28,9 +28,9 @@
 	}
=20
 #define SARLSTR(var,nn) {\
-	char tmpStr[400];\
+	char tmpStr[50];\
 	int  tmpLn =3D nn;\
-	if (nn > 399 ) tmpLn =3D 399; \
+	BUG_ON(tmpLn > 49);\
 	memcpy(tmpStr,(char *) priva->conf->var,tmpLn);\
 	tmpStr[tmpLn] =3D 0; \
 	pos +=3D sprintf(arlan_drive_info+pos, "%s\t=3D\t%s \n",#var,priva->con=
f->var);\
