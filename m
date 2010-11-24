From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH 1/2] iproute2: treat gre key as number
Date: Wed, 24 Nov 2010 10:18:57 +0200
Message-ID: <1290586738-27056-1-git-send-email-timo.teras@iki.fi>
References: <20101123105418.65072de8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: shemminger@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52240 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab0KXITW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 03:19:22 -0500
Received: by wyb28 with SMTP id 28so9217544wyb.19
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 00:19:21 -0800 (PST)
In-Reply-To: <20101123105418.65072de8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print GRE key as a regular number. It is not really an IPv4 address
and this is also how Cisco and Juniper treats GRE keys. Do keep the
parsing of dotted-quad format for backwards compatibility.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 ip/iptunnel.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 3525fbb..48faf69 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -306,12 +306,8 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	struct ip_tunnel_6rd ip6rd;
 	char s1[1024];
 	char s2[1024];
-	char s3[64];
-	char s4[64];
=20
 	memset(&ip6rd, 0, sizeof(ip6rd));
-	inet_ntop(AF_INET, &p->i_key, s3, sizeof(s3));
-	inet_ntop(AF_INET, &p->o_key, s4, sizeof(s4));
=20
 	/* Do not use format_host() for local addr,
 	 * symbolic name will not be useful.
@@ -377,12 +373,12 @@ static void print_tunnel(struct ip_tunnel_parm *p=
)
 	}
=20
 	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key =3D=3D p=
->i_key)
-		printf(" key %s", s3);
+		printf(" key %u", ntohl(p->i_key));
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
 		if (p->i_flags&GRE_KEY)
-			printf(" ikey %s ", s3);
+			printf(" ikey %u ", ntohl(p->i_key));
 		if (p->o_flags&GRE_KEY)
-			printf(" okey %s ", s4);
+			printf(" okey %u ", ntohl(p->o_key));
 	}
=20
 	if (p->i_flags&GRE_SEQ)
--=20
1.7.1

