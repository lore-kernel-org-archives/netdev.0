From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 7/7] lnstat: run indefinitely by default
Date: Mon, 13 Apr 2015 16:01:01 +0200
Message-ID: <1428933661-8193-7-git-send-email-pavlix@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47548 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845AbbDMOKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:03 -0400
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

See also:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D977845

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 misc/lnstat.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index e105b70..0385cbb 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -249,7 +249,7 @@ int main(int argc, char **argv)
 		MODE_JSON,
 		MODE_NORMAL,
 	} mode =3D MODE_NORMAL;
-	unsigned long count =3D 1;
+	unsigned long count =3D 0;
 	struct table_hdr *header;
 	static struct field_params fp;
 	int num_req_files =3D 0;
@@ -362,7 +362,7 @@ int main(int argc, char **argv)
 		if (interval < 1 )
 			interval =3D 1;
=20
-		for (i =3D 0; i < count; i++) {
+		for (i =3D 0; i < count || !count; ) {
 			lnstat_update(lnstat_files);
 			if (mode =3D=3D MODE_JSON)
 				print_json(stdout, lnstat_files, &fp);
@@ -373,8 +373,10 @@ int main(int argc, char **argv)
 				print_line(stdout, lnstat_files, &fp);
 			}
 			fflush(stdout);
-			if (i < count - 1)
+			if (i < count - 1 || !count)
 				sleep(interval);
+			if (count)
+				++i;
 		}
 		break;
 	}
--=20
2.3.5
