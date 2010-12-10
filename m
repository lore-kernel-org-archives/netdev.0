From: Martin Lucina <mato@kotelna.sk>
Subject: [PATCH] Document the kernel_recvmsg() function
Date: Fri, 10 Dec 2010 11:04:05 +0100
Message-ID: <20101210100404.GA28580@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Sustrik <sustrik@250bpm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:48621 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516Ab0LJKEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 05:04:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Updated and sent to the netdev mailing list, Eric thx for the pointer]

Hi,

so, today we spent all day figuring out how the kernel_sendmsg() function
*actually* works. This patch adds some documentation to help the next poor
sod.

-mato

>From 1a977fc0b9544c53761ba3c4c26ca1aac2018663 Mon Sep 17 00:00:00 2001
From: Martin Lucina <mato@kotelna.sk>
Date: Thu, 9 Dec 2010 17:11:18 +0100
Subject: [PATCH] Document the kernel_recvmsg() function

Signed-off-by: Martin Lucina <mato@kotelna.sk>
---
 net/socket.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 3ca2fd9..088fb3f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -732,6 +732,21 @@ static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 	return ret;
 }
 
+/**
+ * kernel_recvmsg - Receive a message from a socket (kernel space)
+ * @sock:       The socket to receive the message from
+ * @msg:        Received message
+ * @vec:        Input s/g array for message data
+ * @num:        Size of input s/g array
+ * @size:       Number of bytes to read
+ * @flags:      Message flags (MSG_DONTWAIT, etc...)
+ *
+ * On return the msg structure contains the scatter/gather array passed in the
+ * vec argument. The array is modified so that it consists of the unfilled
+ * portion of the original array.
+ *
+ * The returned value is the total number of bytes received, or an error.
+ */
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
-- 
1.7.1

