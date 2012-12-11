From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: ss - change default filter to include all socket types
Date: Tue, 11 Dec 2012 17:42:52 +0100
Message-ID: <1355244172-32071-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962Ab2LKQnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 11:43:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the default filter lists TCP sockets only which is
rather confusing especially when the '-a/--all' flag is used.
This patch changes the default to include all sockets, imitating
netstat(8) behavior.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index b45f5ba..b8cd60d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -105,7 +105,7 @@ struct filter
 };
=20
 struct filter default_filter =3D {
-	.dbs	=3D  (1<<TCP_DB),
+	.dbs	=3D  ~0,
 	.states =3D SS_ALL & ~((1<<SS_LISTEN)|(1<<SS_CLOSE)|(1<<SS_TIME_WAIT)=
|(1<<SS_SYN_RECV)),
 	.families=3D (1<<AF_INET)|(1<<AF_INET6),
 };
--=20
1.7.11.7
