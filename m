From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPVS] Fix compiler warning about unused register_ip_vs_protocol
Date: Tue, 20 Nov 2007 15:08:42 +0300
Message-ID: <4742CE4A.2000102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47165 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766AbXKTMIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 07:08:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is silly, but I have turned the CONFIG_IP_VS to m,
to check the compilation of one (recently sent) fix
and set all the CONFIG_IP_VS_PROTO_XXX options to n to
speed up the compilation.

In this configuration the compiler warns me about

  CC [M]  net/ipv4/ipvs/ip_vs_proto.o
net/ipv4/ipvs/ip_vs_proto.c:49: warning: =91register_ip_vs_protocol=92 =
defined but not used

Indeed. With no protocols selected there are no
calls to this function - all are compiled out with
ifdefs.

Maybe the best fix would be to surround this call with
ifdef-s or tune the Kconfig dependences, but I think that
marking this register function as __used is enough. No?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index e844ddb..c0e11ec 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -45,7 +45,7 @@ static struct ip_vs_protocol *ip_vs_proto_table[IP_VS=
_PROTO_TAB_SIZE];
 /*
  *	register an ipvs protocol
  */
-static int register_ip_vs_protocol(struct ip_vs_protocol *pp)
+static int __used register_ip_vs_protocol(struct ip_vs_protocol *pp)
 {
 	unsigned hash =3D IP_VS_PROTO_HASH(pp->protocol);
=20
--=20
1.5.3.4

