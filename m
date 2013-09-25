From: =?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
Subject: [PATCH] iproute2: bridge: Close file with bridge monitor file
Date: Wed, 25 Sep 2013 09:45:45 +0200
Message-ID: <1380095145-6618-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab3IYHqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:46:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The `bridge monitor file FILENAME' reads dumped netlink messages from
a file. But it forgot to close the file after using it. This patch
fixes it.

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
---
 bridge/monitor.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/bridge/monitor.c b/bridge/monitor.c
index e96fcaf..76e7d47 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -132,12 +132,15 @@ int do_monitor(int argc, char **argv)
=20
 	if (file) {
 		FILE *fp;
+		int err;
 		fp =3D fopen(file, "r");
 		if (fp =3D=3D NULL) {
 			perror("Cannot fopen");
 			exit(-1);
 		}
-		return rtnl_from_file(fp, accept_msg, stdout);
+		err =3D rtnl_from_file(fp, accept_msg, stdout);
+		fclose(fp);
+		return err;
 	}
=20
 	if (rtnl_open(&rth, groups) < 0)
--=20
1.8.3.1
