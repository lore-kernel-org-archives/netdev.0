From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: use INET_ECN_MASK instead of hardcoded 3
Date: Fri, 21 Oct 2011 16:11:50 -0700
Message-ID: <1319238710-11272-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:58823 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab1JUXME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 19:12:04 -0400
Received: by ggnb1 with SMTP id b1so4312974ggn.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 16:12:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/ip_sockglue.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index f0dc3ad..09ff51b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -33,6 +33,7 @@
 #include <linux/netfilter.h>
 #include <linux/route.h>
 #include <linux/mroute.h>
+#include <net/inet_ecn.h>
 #include <net/route.h>
 #include <net/xfrm.h>
 #include <net/compat.h>
@@ -578,8 +579,8 @@ static int do_ip_setsockopt(struct sock *sk, int le=
vel,
 		break;
 	case IP_TOS:	/* This sets both TOS and Precedence */
 		if (sk->sk_type =3D=3D SOCK_STREAM) {
-			val &=3D ~3;
-			val |=3D inet->tos & 3;
+			val &=3D ~INET_ECN_MASK;
+			val |=3D inet->tos & INET_ECN_MASK;
 		}
 		if (inet->tos !=3D val) {
 			inet->tos =3D val;
--=20
1.7.3.1
