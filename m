From: Jing Wang <windsdaemon@gmail.com>
Subject: [PATCH 1/1] net: fix compile warning in af_unix.c
Date: Tue, 30 Oct 2012 15:16:36 +0800
Message-ID: <1351581396-20493-1-git-send-email-windsdaemon@gmail.com>
Cc: netdev@vger.kernel.org, Jing Wang <windsdaemon@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:58813 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab2J3HRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 03:17:20 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so2831805dak.19
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2012 00:17:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix some compile warning as follows:
net/unix/af_unix.c: In function 'unix_bind':
net/unix/af_unix.c:895: warning: 'path.dentry' may be used uninitialized in this function
net/unix/af_unix.c:895: warning: 'path.mnt' may be used uninitialized in this function

Signed-off-by: Jing Wang <windsdaemon@gmail.com>
---
 net/unix/af_unix.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..9f710ac 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -895,6 +895,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		struct path path;
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
+		path.mnt = NULL;
+		path.dentry = NULL;
 		err = unix_mknod(sun_path, mode, &path);
 		if (err) {
 			if (err == -EEXIST)
-- 
1.7.5.4
