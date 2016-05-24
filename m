From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH v2 1/1] tc simple action: bug fix
Date: Tue, 24 May 2016 07:52:48 -0400
Message-ID: <1464090769-29763-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:36090 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbcEXLxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 07:53:01 -0400
Received: by mail-ig0-f193.google.com with SMTP id c3so1669909igl.3
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 04:53:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jamal Hadi Salim <jhs@mojatatu.com>

=46ailed compile
m_simple.c: In function =E2=80=98parse_simple=E2=80=99:
m_simple.c:154:6: warning: too many arguments for format [-Wformat-extr=
a-args]
      *argv);
      ^
m_simple.c:103:14: warning: unused variable =E2=80=98maybe_bind=E2=80=99=
 [-Wunused-variable]

Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_simple.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/tc/m_simple.c b/tc/m_simple.c
index feba61b..27b3e5e 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -100,7 +100,7 @@ parse_simple(struct action_util *a, int *argc_p, ch=
ar ***argv_p, int tca_id,
 	struct tc_defact sel =3D {};
 	int argc =3D *argc_p;
 	char **argv =3D *argv_p;
-	int ok =3D 0, maybe_bind =3D 0;
+	int ok =3D 0;
 	struct rtattr *tail;
 	char *simpdata =3D NULL;
=20
@@ -150,7 +150,7 @@ parse_simple(struct action_util *a, int *argc_p, ch=
ar ***argv_p, int tca_id,
 		if (matches(*argv, "index") =3D=3D 0) {
 			NEXT_ARG();
 			if (get_u32(&sel.index, *argv, 10)) {
-				fprintf(stderr, "simple: Illegal \"index\"\n",
+				fprintf(stderr, "simple: Illegal \"index\" (%s)\n",
 					*argv);
 				return -1;
 			}
@@ -171,7 +171,6 @@ parse_simple(struct action_util *a, int *argc_p, ch=
ar ***argv_p, int tca_id,
 		return -1;
 	}
=20
-
 	sel.action =3D TC_ACT_PIPE;
=20
 	tail =3D NLMSG_TAIL(n);
--=20
1.9.1
