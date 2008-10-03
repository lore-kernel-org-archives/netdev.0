From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 1/6] Phonet: modules auto-loading support
Date: Fri,  3 Oct 2008 17:09:34 +0300
Message-ID: <1223042979-21124-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200810031709.11828.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:32206 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbYJCOJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:09:43 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m93E9MYH013730
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2008 17:09:40 +0300
In-Reply-To: <200810031709.11828.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 1d8df6b..0a74aea 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -64,6 +64,11 @@ static int pn_socket_create(struct net *net, struct =
socket *sock, int protocol)
 	}
=20
 	pnp =3D phonet_proto_get(protocol);
+#ifdef CONFIG_KMOD
+	if (pnp =3D=3D NULL &&
+	    request_module("net-pf-%d-proto-%d", PF_PHONET, protocol) =3D=3D =
0)
+		pnp =3D phonet_proto_get(protocol);
+#endif
 	if (pnp =3D=3D NULL)
 		return -EPROTONOSUPPORT;
 	if (sock->type !=3D pnp->sock_type) {
@@ -94,7 +99,7 @@ out:
 }
=20
 static struct net_proto_family phonet_proto_family =3D {
-	.family =3D AF_PHONET,
+	.family =3D PF_PHONET,
 	.create =3D pn_socket_create,
 	.owner =3D THIS_MODULE,
 };
@@ -447,7 +452,7 @@ static int __init phonet_init(void)
=20
 err:
 	phonet_sysctl_exit();
-	sock_unregister(AF_PHONET);
+	sock_unregister(PF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
 	phonet_device_exit();
 	return err;
@@ -457,7 +462,7 @@ static void __exit phonet_exit(void)
 {
 	isi_unregister();
 	phonet_sysctl_exit();
-	sock_unregister(AF_PHONET);
+	sock_unregister(PF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
 	phonet_device_exit();
 }
@@ -466,3 +471,4 @@ module_init(phonet_init);
 module_exit(phonet_exit);
 MODULE_DESCRIPTION("Phonet protocol stack for Linux");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_PHONET);
--=20
1.5.4.3

