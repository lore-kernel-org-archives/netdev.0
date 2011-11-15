From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: Display closed UDP sockets on 'ss -ul'
Date: Tue, 15 Nov 2011 16:19:26 +0100
Message-ID: <1321370366-18832-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755946Ab1KOPVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 10:21:53 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAFFLrHT013169
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 10:21:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch emulates 'netstat -ul' behavior, showing 'closed'
(state 07) UDP sockets when ss is called with '-ul' options.
Although dirty, this seems like the least invasive way to fix
it and shouldn't really break anything.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 misc/ss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 1353620..af774d1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2568,7 +2568,7 @@ int main(int argc, char *argv[])
 			current_filter.states =3D SS_ALL;
 			break;
 		case 'l':
-			current_filter.states =3D (1<<SS_LISTEN);
+			current_filter.states =3D (1<<SS_LISTEN) | (1<<SS_CLOSE);
 			break;
 		case '4':
 			preferred_family =3D AF_INET;
--=20
1.7.7.1
