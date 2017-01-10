From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] net: socket: Make unnecessarily global sockfs_setattr() static
Date: Tue, 10 Jan 2017 09:30:51 +0100
Message-ID: <20170110083051.753-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34464 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757440AbdAJIax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 03:30:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sockfs_setattr() static as it is not used outside of net/socket.c

This fixes the following GCC warning:
net/socket.c:534:5: warning: no previous prototype for ‘sockfs_setattr’ [-Wmissing-prototypes]

Fixes: 86741ec25462 ("net: core: Add a UID field to struct sock.")
Cc: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index 009dd12ab7f3..727dfd96da07 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -531,7 +531,7 @@ static ssize_t sockfs_listxattr(struct dentry *dentry, char *buffer,
 	return used;
 }
 
-int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
+static int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
 {
 	int err = simple_setattr(dentry, iattr);
 
-- 
2.11.0
