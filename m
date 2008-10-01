From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 1/6] Phonet: transport protocol auto-loading
Date: Wed,  1 Oct 2008 13:13:00 +0300
Message-ID: <1222855985-22859-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:38287 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbYJAKNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:13:47 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m91ADEx5022067
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 13:13:44 +0300
In-Reply-To: <200810011312.17288.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 1d8df6b..06627d3 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -64,6 +64,11 @@ static int pn_socket_create(struct net *net, struct =
socket *sock, int protocol)
 	}
=20
 	pnp =3D phonet_proto_get(protocol);
+#ifdef CONFIG_KMOD
+	if (pnp =3D=3D NULL
+	 && request_module("net-pf-%d-proto-%d", PF_PHONET, protocol) =3D=3D =
0)
+		pnp =3D phonet_proto_get(protocol);
+#endif
 	if (pnp =3D=3D NULL)
 		return -EPROTONOSUPPORT;
 	if (sock->type !=3D pnp->sock_type) {
--=20
1.5.4.3

