From: =?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
Subject: [PATCH] Do not listen if rtnl_send() fails in ip link iplink_have_newlink() test
Date: Wed, 11 Dec 2013 14:01:29 +0100
Message-ID: <1386766889-19062-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab3LKNCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 08:02:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If rtnl_send() fails in iplink_have_newlink() test, listening for
response will result in indefinite hang. This can be demonstrated by
"ip link show" while SELinux preventing from sending the RTM_NEWLINK
over netlink.

This patch checks for the return value as is done at all other
rtnl_send() calls.

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
---
 ip/iplink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 58b6c20..f7d9e17 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -178,8 +178,8 @@ static int iplink_have_newlink(void)
 		req.n.nlmsg_type =3D RTM_NEWLINK;
 		req.i.ifi_family =3D AF_UNSPEC;
=20
-		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
-		rtnl_listen(&rth, accept_msg, NULL);
+		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) >=3D 0)
+			rtnl_listen(&rth, accept_msg, NULL);
 	}
 	return have_rtnl_newlink;
 }
--=20
1.8.3.1
