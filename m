From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] ptp: Allow selecting trigger/event index in testptp
Date: Mon,  3 Feb 2014 15:36:27 +0100
Message-ID: <1391438187-21834-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:60808 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752222AbaBCOzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 09:55:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the trigger/event is hardcoded to 0, this patch adds
a new command line argument -i to select an arbitrary trigger/
event.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 Documentation/ptp/testptp.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index a74d0a8..04b21cd 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -123,7 +123,8 @@ static void usage(char *progname)
 		" -P val     enable or disable (val=3D1|0) the system clock PPS\n"
 		" -s         set the ptp clock time from the system time\n"
 		" -S         set the system time from the ptp clock time\n"
-		" -t val     shift the ptp clock time by 'val' seconds\n",
+		" -t val     shift the ptp clock time by 'val' seconds\n"
+		" -i val     index for event/trigger\n",
 		progname);
 }
=20
@@ -161,13 +162,14 @@ int main(int argc, char *argv[])
 	int perout =3D -1;
 	int pps =3D -1;
 	int settime =3D 0;
+	int index =3D 0;
=20
 	int64_t t1, t2, tp;
 	int64_t interval, offset;
=20
 	progname =3D strrchr(argv[0], '/');
 	progname =3D progname ? 1+progname : argv[0];
-	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v")=
)) {
+	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:vi:=
"))) {
 		switch (c) {
 		case 'a':
 			oneshot =3D atoi(optarg);
@@ -209,6 +211,9 @@ int main(int argc, char *argv[])
 		case 't':
 			adjtime =3D atoi(optarg);
 			break;
+		case 'i':
+			index =3D atoi(optarg);
+			break;
 		case 'h':
 			usage(progname);
 			return 0;
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
