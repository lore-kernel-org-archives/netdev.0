From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH] net, vxlan Fix compile warning
Date: Fri, 13 Sep 2013 08:29:12 -0400
Message-ID: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, jpirko@redhat.com,
	tgraf@redhat.com, "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab3IMM3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 08:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix a unintialized variable warning.

drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be used =
uninitialized in this function [-Werror=3Dmaybe-uninitialized]
  vs->sock =3D sock;
           ^
drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was declared =
here
  struct socket *sock;
                 ^

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: jpirko@redhat.com
Cc: tgraf@redhat.com
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/vxlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bf64b41..ed3d7f4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2276,7 +2276,7 @@ static struct vxlan_sock *vxlan_socket_create(str=
uct net *net, __be16 port,
 {
 	struct vxlan_net *vn =3D net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
-	struct socket *sock;
+	struct socket *uninitialized_var(sock);
 	struct sock *sk;
 	int rc =3D 0;
 	unsigned int h;
--=20
1.7.9.3
