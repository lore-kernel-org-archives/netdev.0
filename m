From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-next] Phonet: fix /proc/net/phonet with network namespaces
Date: Tue, 11 Aug 2009 16:12:07 +0300
Message-ID: <1249996327-8460-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:45516 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZHKNMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 09:12:09 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n7BDBg3I024761
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 16:11:57 +0300
Received: from localhost.localdomain (esdhcp036168.research.nokia.com [172.21.36.168])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n7BDBrdN016053
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 16:11:53 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

seq_open_net() and seq_release() are needed for seq_file_net().

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index aa1617a..5f26c37 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -498,7 +498,8 @@ static const struct seq_operations pn_sock_seq_ops =
=3D {
=20
 static int pn_sock_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &pn_sock_seq_ops);
+	return seq_open_net(inode, file, &pn_sock_seq_ops,
+				sizeof(struct seq_net_private));
 }
=20
 const struct file_operations pn_sock_seq_fops =3D {
@@ -506,5 +507,5 @@ const struct file_operations pn_sock_seq_fops =3D {
 	.open =3D pn_sock_open,
 	.read =3D seq_read,
 	.llseek =3D seq_lseek,
-	.release =3D seq_release,
+	.release =3D seq_release_net,
 };
--=20
1.6.0.4

