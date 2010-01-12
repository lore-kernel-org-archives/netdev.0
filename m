From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 14:32:43 +0100
Message-ID: <201001121432.43301.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_7nHTLsraHkerrZA"
To: netdev@vger.kernel.org,
	"Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:56989 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab0ALNcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 08:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_7nHTLsraHkerrZA
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

Enables IPv4 Differentiated Services support for IP priority based
routing. Notice that the IP TOS field was redefined 1998 to DiffServ
(RFC 2474). Type Of Service is deprecated since 1998 !

This patch adds a compliant flag to net/ipv4/Kconfig, which allows
the user to select DiffServ ore TOS priority based routing. Default
answer is TOS.

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
---
 include/net/route.h |    4 ++++
 net/ipv4/Kconfig    |   15 +++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..8bf43a5 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -141,7 +141,11 @@ extern const __u8 ip_tos2prio[16];
 
 static inline char rt_tos2priority(u8 tos)
 {
+#ifdef CONFIG_IP_DIFFSERV_COMPLIANT
+	return tos >> 5;
+#else
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
+#endif
 }
 
 static inline int ip_route_connect(struct rtable **rp, __be32 dst,
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..e1be75c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -272,6 +272,21 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
 
+config IP_DIFFSERV_COMPLIANT
+	bool "IP: DiffServ priority routing"
+	default n
+	help
+	  Enables IPv4 Differentiated Services support for IP priority based
+	  routing. If you say YES here, TOS priority based routing is disabled.
+	  Notice that the IP TOS field was redefined 1998 to DiffServ (RFC 2474).
+	  Type Of Service is deprecated since 1998 ! So in future default answer
+	  should be YES.
+
+	    Y: DiffServ
+	    N: Type Of Service
+
+	  If unsure, say N.
+
 config ARPD
 	bool "IP: ARP daemon support"
 	---help---
-- 

--Boundary-00=_7nHTLsraHkerrZA
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0001-ipv4-add-DiffServ-priority-based-routing.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-ipv4-add-DiffServ-priority-based-routing.patch"

=46rom 224f01d5c0f2ea36efe78d9de4247e756157c445 Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Tue, 12 Jan 2010 14:26:39 +0100
Subject: [PATCH] ipv4: add DiffServ priority based routing

Enables IPv4 Differentiated Services support for IP priority based
routing. Notice that the IP TOS field was redefined 1998 to DiffServ
(RFC 2474). Type Of Service is deprecated since 1998 !

This patch adds a compliant flag to net/ipv4/Kconfig, which allows
the user to select DiffServ ore TOS priority based routing. Default
answer is TOS.

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/net/route.h |    4 ++++
 net/ipv4/Kconfig    |   15 +++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..8bf43a5 100644
=2D-- a/include/net/route.h
+++ b/include/net/route.h
@@ -141,7 +141,11 @@ extern const __u8 ip_tos2prio[16];
=20
 static inline char rt_tos2priority(u8 tos)
 {
+#ifdef CONFIG_IP_DIFFSERV_COMPLIANT
+	return tos >> 5;
+#else
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
+#endif
 }
=20
 static inline int ip_route_connect(struct rtable **rp, __be32 dst,
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..e1be75c 100644
=2D-- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -272,6 +272,21 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
=20
+config IP_DIFFSERV_COMPLIANT
+	bool "IP: DiffServ priority routing"
+	default n
+	help
+	  Enables IPv4 Differentiated Services support for IP priority based
+	  routing. If you say YES here, TOS priority based routing is disabled.
+	  Notice that the IP TOS field was redefined 1998 to DiffServ (RFC 2474).
+	  Type Of Service is deprecated since 1998 ! So in future default answer
+	  should be YES.
+
+	    Y: DiffServ
+	    N: Type Of Service
+
+	  If unsure, say N.
+
 config ARPD
 	bool "IP: ARP daemon support"
 	---help---
=2D-=20
1.6.3.3


--Boundary-00=_7nHTLsraHkerrZA--
