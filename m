From: Dan McGee <dan@archlinux.org>
Subject: [PATCH] Rename static setns() function
Date: Fri, 15 Jul 2011 13:38:19 -0500
Message-ID: <1310755099-32438-1-git-send-email-dan@archlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan McGee <dan@archlinux.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49624 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab1GOSi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 14:38:26 -0400
Received: by iwn6 with SMTP id 6so1366728iwn.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 11:38:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes the following error:

    gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include
    -DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ipnetns.o ipne=
tns.c
    ipnetns.c:31:12: error: static declaration of =E2=80=98setns=E2=80=99=
 follows non-static
    declaration
    /usr/include/bits/sched.h:93:12: note: previous declaration of =E2=80=
=98setns=E2=80=99
    was here
    make[1]: *** [ipnetns.o] Error 1

=46ixes issue introduced in commit 0dc34c7713bb7055.

Signed-off-by: Dan McGee <dan@archlinux.org>
---
 ip/ipnetns.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index db7007c..46230ad 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -28,7 +28,7 @@
 #define MNT_DETACH	0x00000002	/* Just detach from the tree */
 #endif /* MNT_DETACH */
=20
-static int setns(int fd, int nstype)
+static int do_setns(int fd, int nstype)
 {
 #ifdef __NR_setns
 	return syscall(__NR_setns, fd, nstype);
@@ -150,7 +150,7 @@ static int netns_exec(int argc, char **argv)
 			strerror(errno));
 		return -1;
 	}
-	if (setns(netns, CLONE_NEWNET) < 0) {
+	if (do_setns(netns, CLONE_NEWNET) < 0) {
 		fprintf(stderr, "seting the network namespace failed: %s\n",
 			strerror(errno));
 		return -1;
--=20
1.7.6

