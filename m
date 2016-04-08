From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH] iproute2: tc_bpf.c: fix building with musl libc
Date: Fri,  8 Apr 2016 09:59:33 -0300
Message-ID: <1460120373-32096-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:40754 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754469AbcDHNLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 09:11:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need limits.h for PATH_MAX, fixes:

tc_bpf.c: In function =E2=80=98bpf_map_selfcheck_pinned=E2=80=99:
tc_bpf.c:222:12: error: =E2=80=98PATH_MAX=E2=80=99 undeclared (first us=
e in this
function)
  char file[PATH_MAX], buff[4096];

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 tc/tc_bpf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index d94af82..042e76f 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -20,6 +20,7 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <stdarg.h>
+#include <limits.h>
=20
 #ifdef HAVE_ELF
 #include <libelf.h>
--=20
2.7.3
