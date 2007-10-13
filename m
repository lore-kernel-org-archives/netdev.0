From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 03/14] Allow binding to non-local addresses if IP_TRANSPARENT
	is set
Date: Sat, 13 Oct 2007 19:30:31 +0200
Message-ID: <20071013173031.22517.89002.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761390AbXJMSjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:44 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV009X21VWZM20@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:28:44 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting IP_TRANSPARENT is not really useful without allowing non-local
binds for the socket. To make user-space code simpler we allow these bi=
nds
even if IP_TRANSPARENT is set but IP_FREEBIND is not.

Signed-off-by: T=C3=B3th L=C3=A1szl=C3=B3 Attila <panther@balabit.hu>
Acked-by: Patrick McHardy <kaber@trash.net>
---

 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 621b128..4049a74 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -451,7 +451,7 @@ int inet_bind(struct socket *sock, struct sockaddr =
*uaddr, int addr_len)
 	 */
 	err =3D -EADDRNOTAVAIL;
 	if (!sysctl_ip_nonlocal_bind &&
-	    !inet->freebind &&
+	    !(inet->freebind || inet->transparent) &&
 	    addr->sin_addr.s_addr !=3D INADDR_ANY &&
 	    chk_addr_ret !=3D RTN_LOCAL &&
 	    chk_addr_ret !=3D RTN_MULTICAST &&

