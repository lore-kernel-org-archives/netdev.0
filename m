From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2] iplink: support 'stable-privacy' IPv6 addrgenmode
Date: Wed, 16 Dec 2015 16:15:14 +0100
Message-ID: <1450278914-12717-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36053 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582AbbLPPPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 10:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 ip/ipaddress.c        | 3 +++
 ip/iplink.c           | 4 +++-
 man/man8/ip-link.8.in | 4 ++--
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index bc8359eb9fad..07d5eee2b078 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -292,6 +292,9 @@ static void print_af_spec(FILE *fp, struct rtattr *=
af_spec_attr)
 		case IN6_ADDR_GEN_MODE_NONE:
 			fprintf(fp, "addrgenmode none ");
 			break;
+		case IN6_ADDR_GEN_MODE_STABLE_PRIVACY:
+			fprintf(fp, "addrgenmode stable-privacy ");
+			break;
 		}
 	}
 }
diff --git a/ip/iplink.c b/ip/iplink.c
index f30de86d1858..6d6afebb87e0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,7 +84,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
+	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable-privacy }=
 ]\n");
 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [m=
aster DEV] [type TYPE]\n");
=20
@@ -176,6 +176,8 @@ static int get_addr_gen_mode(const char *mode)
 		return IN6_ADDR_GEN_MODE_EUI64;
 	if (strcasecmp(mode, "none") =3D=3D 0)
 		return IN6_ADDR_GEN_MODE_NONE;
+	if (strcasecmp(mode, "stable-privacy") =3D=3D 0)
+		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	return -1;
 }
=20
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ac6f4813a329..133d3126973d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -150,7 +150,7 @@ ip-link \- network device configuration
 .br
 .B nomaster " |"
 .br
-.B addrgenmode { eui64 | none }
+.B addrgenmode { eui64 | none | stable-privacy }
 .br
 .B link-netnsid ID
 .BR " }"
@@ -1029,7 +1029,7 @@ set master device of the device (enslave device).
 unset master device of the device (release device).
=20
 .TP
-.BR "addrgenmode eui64 " or " addrgenmode none"
+.BR addrgenmode " eui64|none|stable-privacy"
 set IPv6 address generation mode
=20
 .TP
--=20
2.1.4
