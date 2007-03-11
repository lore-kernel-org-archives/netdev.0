From: ralf@linux-mips.org
Subject: [PATCH 1/3] Remove ourselves from waitqueue when receiving a signal
Date: Sun, 11 Mar 2007 22:53:20 +0000
Message-ID: <20070311225739.679006723@denk.linux-mips.net>
References: <20070311225319.673076841@denk.linux-mips.net>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:24032 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022215AbXCKXSs (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Sun, 11 Mar 2007 23:18:48 +0000
Content-Disposition: inline; filename=rose-remove-from-wait-queue.patch
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/rose/af_rose.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -877,6 +877,8 @@ static int rose_accept(struct socket *so
 			lock_sock(sk);
 			continue;
 		}
+		current->state = TASK_RUNNING;
+		remove_wait_queue(sk->sk_sleep, &wait);
 		return -ERESTARTSYS;
 	}
 	current->state = TASK_RUNNING;

-- 

