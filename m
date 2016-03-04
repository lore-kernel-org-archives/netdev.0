From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 02/12] ethtool.c: don't ignore fread() return value
Date: Thu,  3 Mar 2016 20:23:15 -0800
Message-ID: <1457065405-19049-3-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34101 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787AbcCDEXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:42 -0500
Received: by mail-pa0-f67.google.com with SMTP id hj7so2395716pac.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:41 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Decotigny <decot@googlers.com>

This addresses:
  ethtool.c:1116:8: warning: ignoring return value of =E2=80=98fread=E2=
=80=99, declared with attribute warn_unused_result [-Wunused-result]


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index 92c40b8..8a93dd1 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1007,6 +1007,7 @@ static int dump_regs(int gregs_dump_raw, int greg=
s_dump_hex,
 	if (gregs_dump_file) {
 		FILE *f =3D fopen(gregs_dump_file, "r");
 		struct stat st;
+		size_t nread;
=20
 		if (!f || fstat(fileno(f), &st) < 0) {
 			fprintf(stderr, "Can't open '%s': %s\n",
@@ -1016,8 +1017,10 @@ static int dump_regs(int gregs_dump_raw, int gre=
gs_dump_hex,
=20
 		regs =3D realloc(regs, sizeof(*regs) + st.st_size);
 		regs->len =3D st.st_size;
-		fread(regs->data, regs->len, 1, f);
+		nread =3D fread(regs->data, regs->len, 1, f);
 		fclose(f);
+		if (1 !=3D nread)
+			return -1;
 	}
=20
 	if (!gregs_dump_hex)
--=20
2.7.0.rc3.207.g0ac5344
