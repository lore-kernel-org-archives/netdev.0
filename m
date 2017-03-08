From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] net: initialize msg.msg_flags in recvfrom
Date: Wed,  8 Mar 2017 18:08:16 +0100
Message-ID: <20170308170816.8533-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KMSAN reports a use of uninitialized memory in put_cmsg() because
msg.msg_flags in recvfrom haven't been initialized properly.
The flag values don't affect the result on this path, but it's still a
good idea to initialize them explicitly.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
Changes since v1:
 - removed KMSAN report and reproducer from the description
---
 net/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index 2c1e8677ff2d..e0757e648c0c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1731,6 +1731,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	/* We assume all kernel code knows the size of sockaddr_storage */
 	msg.msg_namelen = 0;
 	msg.msg_iocb = NULL;
+	msg.msg_flags = 0;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg, flags);
-- 
2.12.0.246.ga2ecc84866-goog
