From: Jan Glauber <jan.glauber@gmail.com>
Subject: [PATCH] net: use SYSCALL_DEFINEx for sys_recv
Date: Wed, 16 Apr 2014 09:32:48 +0200
Message-ID: <1397633568-26464-1-git-send-email-jan.glauber@gmail.com>
Cc: Jan Glauber <jan.glauber@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:36038 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaDPHc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 03:32:59 -0400
Received: by mail-ee0-f50.google.com with SMTP id c13so8618553eek.9
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 00:32:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sys_recv a first class citizen by using the SYSCALL_DEFINEx
macro. Besides being cleaner this will also generate meta data
for the system call so tracing tools like ftrace or LTTng can
resolve this system call.

Signed-off-by: Jan Glauber <jan.glauber@gmail.com>
---
 net/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a19ae19..d258945 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1879,8 +1879,8 @@ out:
  *	Receive a datagram from a socket.
  */
 
-asmlinkage long sys_recv(int fd, void __user *ubuf, size_t size,
-			 unsigned int flags)
+SYSCALL_DEFINE4(recv, int, fd, void __user *, ubuf, size_t, size,
+		unsigned int, flags)
 {
 	return sys_recvfrom(fd, ubuf, size, flags, NULL, NULL);
 }
-- 
1.7.9.5
