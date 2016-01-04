From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2 2/4] iplink: support setting addrgenmode stable_secret
Date: Mon,  4 Jan 2016 10:58:04 +0100
Message-ID: <1451901486-3497-3-git-send-email-bjorn@mork.no>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44418 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624AbcADJ6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:58:33 -0500
In-Reply-To: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible to switch to another addrgenmode after setting a
valid secret.  Allow switching back without reconfiguring the
secret for completeness.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 ip/iplink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index f30de86d1858..e824082f7d81 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,7 +84,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
+	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret } =
]\n");
 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [m=
aster DEV] [type TYPE]\n");
=20
@@ -176,6 +176,8 @@ static int get_addr_gen_mode(const char *mode)
 		return IN6_ADDR_GEN_MODE_EUI64;
 	if (strcasecmp(mode, "none") =3D=3D 0)
 		return IN6_ADDR_GEN_MODE_NONE;
+	if (strcasecmp(mode, "stable_secret") =3D=3D 0)
+		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	return -1;
 }
=20
--=20
2.1.4
