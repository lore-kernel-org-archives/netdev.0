From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: [PATCH] Make sure sockets implement splice_read
Date: Thu, 14 Feb 2008 18:53:34 +0200
Message-ID: <200802141853.35016.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51247 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752400AbYBNROO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 12:14:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes a segmentation fault when trying to splice from a non-TCP socke=
t.

Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
---
 net/socket.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 7651de0..b6d35cd 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -701,6 +701,9 @@ static ssize_t sock_splice_read(struct file *file, =
loff_t *ppos,
 {
 	struct socket *sock =3D file->private_data;
=20
+	if (unlikely(!sock->ops->splice_read))
+		return -EINVAL;
+
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
=20
--=20
1.5.4.1

