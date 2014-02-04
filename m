From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v3] ptp: Allow selecting trigger/event index in testptp
Date: Tue,  4 Feb 2014 08:46:36 +0100
Message-ID: <1391499996-10233-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:37625 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751234AbaBDHql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 02:46:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the trigger/event is hardcoded to 0, this patch adds
a new command line argument -i to select an arbitrary trigger/
event.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
Changes from v2:
* Keep options sorted all places - don't submit patches before cup of=20
  coffee :-)

Changes from v1:
 * Keep options sorted

 Documentation/ptp/testptp.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index a74d0a8..4aba043 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -117,6 +117,7 @@ static void usage(char *progname)
 		" -f val     adjust the ptp clock frequency by 'val' ppb\n"
 		" -g         get the ptp clock time\n"
 		" -h         prints this message\n"
+		" -i val     index for event/trigger\n"
 		" -k val     measure the time offset between system and phc clock\n"
 		"            for 'val' times (Maximum 25)\n"
 		" -p val     enable output with a period of 'val' nanoseconds\n"
@@ -154,6 +155,7 @@ int main(int argc, char *argv[])
 	int capabilities =3D 0;
 	int extts =3D 0;
 	int gettime =3D 0;
+	int index =3D 0;
 	int oneshot =3D 0;
 	int pct_offset =3D 0;
 	int n_samples =3D 0;
@@ -167,7 +169,7 @@ int main(int argc, char *argv[])
=20
 	progname =3D strrchr(argv[0], '/');
 	progname =3D progname ? 1+progname : argv[0];
-	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v")=
)) {
+	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghi:k:p:P:sSt:v=
"))) {
 		switch (c) {
 		case 'a':
 			oneshot =3D atoi(optarg);
@@ -190,6 +192,9 @@ int main(int argc, char *argv[])
 		case 'g':
 			gettime =3D 1;
 			break;
+		case 'i':
+			index =3D atoi(optarg);
+			break;
 		case 'k':
 			pct_offset =3D 1;
 			n_samples =3D atoi(optarg);
@@ -301,7 +306,7 @@ int main(int argc, char *argv[])
=20
 	if (extts) {
 		memset(&extts_request, 0, sizeof(extts_request));
-		extts_request.index =3D 0;
+		extts_request.index =3D index;
 		extts_request.flags =3D PTP_ENABLE_FEATURE;
 		if (ioctl(fd, PTP_EXTTS_REQUEST, &extts_request)) {
 			perror("PTP_EXTTS_REQUEST");
@@ -375,7 +380,7 @@ int main(int argc, char *argv[])
 			return -1;
 		}
 		memset(&perout_request, 0, sizeof(perout_request));
-		perout_request.index =3D 0;
+		perout_request.index =3D index;
 		perout_request.start.sec =3D ts.tv_sec + 2;
 		perout_request.start.nsec =3D 0;
 		perout_request.period.sec =3D 0;
--=20
1.8.5.3
