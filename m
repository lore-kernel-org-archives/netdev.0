From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] unix: fix build warning of used uninitialized variable
Date: Fri, 6 Dec 2013 14:05:24 +0800
Message-ID: <52A16924.9050407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <ebiederm@xmission.com>,
	<gaofeng@cn.fujitsu.com>, <jacob.e.keller@intel.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36291 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab3LFGGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:06:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

af_unix.c: In function unix_bind
af_unix.c:893: warning: path may be used uninitialized in this function

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/unix/af_unix.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 01625cc..4155ed3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -893,6 +893,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		struct path path;
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
+		memset(&path, 0, sizeof(path));
 		err = unix_mknod(sun_path, mode, &path);
 		if (err) {
 			if (err == -EEXIST)
-- 
1.6.0.2
