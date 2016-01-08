From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add scheduling point in recvmmsg/sendmmsg
Date: Fri, 08 Jan 2016 08:37:20 -0800
Message-ID: <1452271040.8255.226.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36442 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbcAHQhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 11:37:23 -0500
Received: by mail-pa0-f52.google.com with SMTP id yy13so192086980pab.3
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 08:37:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Applications often have to reduce number of datagrams
they receive or send per system call to avoid starvation problems.

Really the kernel should take care of this by using cond_resched(),
so that applications can experiment bigger batch sizes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/socket.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index d730ef9dfbf0..91c2de6f5020 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2041,6 +2041,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		if (err)
 			break;
 		++datagrams;
+		cond_resched();
 	}
 
 	fput_light(sock->file, fput_needed);
@@ -2236,6 +2237,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		/* Out of band data, return right away */
 		if (msg_sys.msg_flags & MSG_OOB)
 			break;
+		cond_resched();
 	}
 
 out_put:
