From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2 3/4] iplink: support show and set of "addrgenmode random"
Date: Mon,  4 Jan 2016 10:58:05 +0100
Message-ID: <1451901486-3497-4-git-send-email-bjorn@mork.no>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44806 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbcADJ6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:58:33 -0500
In-Reply-To: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"random" is a new IPv6 addrgenmode, enabling "stable_secret" type
addresses with an auto-generated secret.

$ ip link set eth0 addrgenmode random

$ ip -d link show dev eth0
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast =
state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:21:86:a3:25:7d brd ff:ff:ff:ff:ff:ff promiscuity 0 ad=
drgenmode random

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 ip/ipaddress.c | 3 +++
 ip/iplink.c    | 4 +++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index a495a391a0ec..9d254d27bc1b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -296,6 +296,9 @@ static void print_af_spec(FILE *fp, struct rtattr *=
af_spec_attr)
 		case IN6_ADDR_GEN_MODE_STABLE_PRIVACY:
 			fprintf(fp, "addrgenmode stable_secret ");
 			break;
+		case IN6_ADDR_GEN_MODE_RANDOM:
+			fprintf(fp, "addrgenmode random ");
+			break;
 		default:
 			fprintf(fp, "addrgenmode %#.2hhx ", mode);
 			break;
diff --git a/ip/iplink.c b/ip/iplink.c
index e824082f7d81..75b21540c6b5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,7 +84,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret } =
]\n");
+	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret | =
random } ]\n");
 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [m=
aster DEV] [type TYPE]\n");
=20
@@ -178,6 +178,8 @@ static int get_addr_gen_mode(const char *mode)
 		return IN6_ADDR_GEN_MODE_NONE;
 	if (strcasecmp(mode, "stable_secret") =3D=3D 0)
 		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+	if (strcasecmp(mode, "random") =3D=3D 0)
+		return IN6_ADDR_GEN_MODE_RANDOM;
 	return -1;
 }
=20
--=20
2.1.4
