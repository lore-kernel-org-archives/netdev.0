From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 v2 2/2] lnstat: Fix compiler errors of unused return-values
Date: Mon, 22 Jul 2013 19:24:17 +0200
Message-ID: <1374513857-6096-3-git-send-email-christoph.paasch@uclouvain.be>
References: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42600 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409Ab3GVRYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 13:24:33 -0400
In-Reply-To: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many errors when compiling with gcc 4.7.3 about unused return-values
upon the calls to fgets:

lnstat_util.c: In function =E2=80=98lnstat_scan_fields=E2=80=99:
lnstat_util.c:145:7: error: ignoring return value of =E2=80=98fgets=E2=80=
=99, declared with attribute warn_unused_result [-Werror=3Dunused-resul=
t]
lnstat_util.c: In function =E2=80=98lnstat_update=E2=80=99:
lnstat_util.c:97:10: error: ignoring return value of =E2=80=98fgets=E2=80=
=99, declared with attribute warn_unused_result [-Werror=3Dunused-resul=
t]
lnstat_util.c:111:9: error: ignoring return value of =E2=80=98fgets=E2=80=
=99, declared with attribute warn_unused_result [-Werror=3Dunused-resul=
t]
lnstat_util.c: In function =E2=80=98scan_lines=E2=80=99:
lnstat_util.c:52:8: error: ignoring return value of =E2=80=98fgets=E2=80=
=99, declared with attribute warn_unused_result [-Werror=3Dunused-resul=
t]
cc1: all warnings being treated as errors
make[1]: *** [lnstat_util.o] Error 1
make[1]: Leaving directory `/home/christoph/workspace/linux/iproute2/mi=
sc'
make: *** [all] Error 2

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 misc/lnstat_util.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index 9492baf..103c05d 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -49,7 +49,8 @@ static int scan_lines(struct lnstat_file *lf, int i)
=20
 		num_lines++;
=20
-		fgets(buf, sizeof(buf)-1, lf->fp);
+		if (!fgets(buf, sizeof(buf)-1, lf->fp))
+			return num_lines;
 		gettimeofday(&lf->last_read, NULL);
=20
 		for (j =3D 0; j < lf->num_fields; j++) {
@@ -94,7 +95,8 @@ int lnstat_update(struct lnstat_file *lnstat_files)
 			rewind(lf->fp);
 			if (!lf->compat) {
 				/* skip first line */
-				fgets(buf, sizeof(buf)-1, lf->fp);
+				if (!fgets(buf, sizeof(buf)-1, lf->fp))
+					return 0;
 			}
 			scan_lines(lf, 1);
=20
@@ -108,7 +110,8 @@ int lnstat_update(struct lnstat_file *lnstat_files)
 			}
=20
 			rewind(lf->fp);
-			fgets(buf, sizeof(buf)-1, lf->fp);
+			if (!fgets(buf, sizeof(buf)-1, lf->fp))
+				return 0;
 			scan_lines(lf, 0);
 		}
 	}
@@ -142,7 +145,8 @@ static int lnstat_scan_fields(struct lnstat_file *l=
f)
 	char buf[FGETS_BUF_SIZE];
=20
 	rewind(lf->fp);
-	fgets(buf, sizeof(buf)-1, lf->fp);
+	if (!fgets(buf, sizeof(buf)-1, lf->fp))
+		return -1;
=20
 	return __lnstat_scan_fields(lf, buf);
 }
--=20
1.8.1.2
