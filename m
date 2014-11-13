From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 49/56] net/socket: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:26 +0100
Message-ID: <1415913813-362-50-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh@joshtriplett.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list)
To: pieter@boesman.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile out splice support from socket when the splice-family of syscalls is not
supported by the system (i.e. CONFIG_SYSCALL_SPLICE is undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 net/socket.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 95ee7d8..5cb347a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -155,8 +155,8 @@ static const struct file_operations socket_file_ops = {
 	.release =	sock_close,
 	.fasync =	sock_fasync,
 	.sendpage =	sock_sendpage,
-	.splice_write = generic_splice_sendpage,
-	.splice_read =	sock_splice_read,
+	SPLICE_WRITE_INIT(generic_splice_sendpage)
+	SPLICE_READ_INIT(sock_splice_read)
 };
 
 /*
@@ -881,7 +881,8 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 	return kernel_sendpage(sock, page, offset, size, flags);
 }
 
-static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
+static ssize_t __maybe_unused sock_splice_read(
+				struct file *file, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags)
 {
-- 
1.9.1
