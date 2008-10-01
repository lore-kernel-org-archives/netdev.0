From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 03/16] Allow binding to non-local addresses if
	IP_TRANSPARENT is set
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.89758.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759AbYJAPZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:27 -0400
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting IP_TRANSPARENT is not really useful without allowing non-local
binds for the socket. To make user-space code simpler we allow these bi=
nds
even if IP_TRANSPARENT is set but IP_FREEBIND is not.

Signed-off-by: T=C3=B3th L=C3=A1szl=C3=B3 Attila <panther@balabit.hu>
---

 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8a3ac1f..1fbff5f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -469,7 +469,7 @@ int inet_bind(struct socket *sock, struct sockaddr =
*uaddr, int addr_len)
 	 */
 	err =3D -EADDRNOTAVAIL;
 	if (!sysctl_ip_nonlocal_bind &&
-	    !inet->freebind &&
+	    !(inet->freebind || inet->transparent) &&
 	    addr->sin_addr.s_addr !=3D htonl(INADDR_ANY) &&
 	    chk_addr_ret !=3D RTN_LOCAL &&
 	    chk_addr_ret !=3D RTN_MULTICAST &&


