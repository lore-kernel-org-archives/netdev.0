From: Matthew Leach <matthew.leach@arm.com>
Subject: [PATCH] net: socket: error on a negative msg_namelen
Date: Tue, 11 Mar 2014 11:58:27 +0000
Message-ID: <1394539107-1432-1-git-send-email-matthew.leach@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, Will.Deacon@arm.com,
	Mark.Rutland@arm.com, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Leach <matthew.leach@arm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from service87.mimecast.com ([91.220.42.44]:43650 "EHLO
	service87.mimecast.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbaCKL6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 07:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When copying in a struct msghdr from the user, if the user has set the
msg_namelen parameter to a negative value it gets clamped to a valid
size due to a comparison between signed and unsigned values.

Ensure the syscall errors when the user passes in a negative value.

Signed-off-by: Matthew Leach <matthew.leach@arm.com>
---
 net/socket.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index 879933a..32df584 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1985,6 +1985,10 @@ static int copy_msghdr_from_user(struct msghdr *kmsg=
,
 {
 =09if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
 =09=09return -EFAULT;
+
+=09if (kmsg->msg_namelen < 0)
+=09=09return -EINVAL;
+
 =09if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
 =09=09kmsg->msg_namelen =3D sizeof(struct sockaddr_storage);
 =09return 0;
--=20
1.8.5.3
