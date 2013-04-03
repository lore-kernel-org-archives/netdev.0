From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH] af_unix: fix build warning
Date: Wed, 3 Apr 2013 17:31:06 +0800
Message-ID: <515BF6DA.9010007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28473 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761830Ab3DCJbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 05:31:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/unix/af_unix.c: In function =91unix_bind=92:
net/unix/af_unix.c:892: warning: =91path.mnt=92 may be used uninitializ=
ed in this function
net/unix/af_unix.c:892: warning: =91path.dentry=92 may be used uninitia=
lized in this function

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/unix/af_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 971282b..3ccc049 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -889,7 +889,7 @@ static int unix_bind(struct socket *sock, struct so=
ckaddr *uaddr, int addr_len)
 	atomic_set(&addr->refcnt, 1);

 	if (sun_path[0]) {
-		struct path path;
+		struct path path =3D {};
 		umode_t mode =3D S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
 		err =3D unix_mknod(sun_path, mode, &path);
--=20
1.8.0
