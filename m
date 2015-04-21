From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/3] tc: fix compilation warning on 32bits arch
Date: Tue, 21 Apr 2015 18:06:35 +0200
Message-ID: <1429632397-11122-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53649 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932796AbbDUQGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 12:06:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The warning was:
m_simple.c: In function =E2=80=98parse_simple=E2=80=99:
m_simple.c:142:4: warning: format =E2=80=98%ld=E2=80=99 expects argumen=
t of type =E2=80=98long int=E2=80=99, but argument 3 has type =E2=80=98=
size_t=E2=80=99 [-Wformat]

Useful to be able to compile with -Werror.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 tc/m_simple.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_simple.c b/tc/m_simple.c
index 866552f559b3..3b6d7beb769c 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -139,7 +139,7 @@ parse_simple(struct action_util *a, int *argc_p, ch=
ar ***argv_p, int tca_id,
=20
 	if (strlen(simpdata) > (SIMP_MAX_DATA - 1)) {
 		fprintf(stderr, "simple: Illegal string len %ld <%s> \n",
-			strlen(simpdata), simpdata);
+			(long)strlen(simpdata), simpdata);
 		return -1;
 	}
=20
--=20
2.2.2
