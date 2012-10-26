From: Jing Wang <windsdaemon@gmail.com>
Subject: [PATCH 1/1] af_unix.c: fix the compile warning in unix_bind
Date: Fri, 26 Oct 2012 10:48:47 +0800
Message-ID: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com>
Cc: netdev@vger.kernel.org, Jing Wang <windsdaemon@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48938 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab2JZCtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 22:49:18 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so2452348pbb.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 19:49:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jing Wang <windsdaemon@gmail.com>
---
 net/unix/af_unix.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..3f7d9d5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -860,6 +860,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
+	struct path path;
+	umode_t mode;
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -890,11 +892,12 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	addr->len = addr_len;
 	addr->hash = hash ^ sk->sk_type;
 	atomic_set(&addr->refcnt, 1);
-
+
 	if (sun_path[0]) {
-		struct path path;
-		umode_t mode = S_IFSOCK |
+		mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
+
+		memset(&path, 0, sizeof(path));
 		err = unix_mknod(sun_path, mode, &path);
 		if (err) {
 			if (err == -EEXIST)
-- 
1.7.5.4
