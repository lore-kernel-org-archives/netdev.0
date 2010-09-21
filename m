From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 3/3] caif: Use default send and receive buffer
 size in caif_socket.
Date: Tue, 21 Sep 2010 23:44:46 +0200
Message-ID: <1285105486-7649-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1285105486-7649-1-git-send-email-sjur.brandeland@stericsson.com>
 <1285105486-7649-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:49296 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab0IUVoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:44:54 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L94009189QRXSC0@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:51 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.92]) by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400IWQ9QPI2F1@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:51 +0200 (CEST)
In-reply-to: <1285105486-7649-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

CAIF sockets should use socket's default send and receive buffers sizes.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 3943398..4d918f8 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -30,9 +30,6 @@
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(AF_CAIF);
 
-#define CAIF_DEF_SNDBUF (4096*10)
-#define CAIF_DEF_RCVBUF (4096*100)
-
 /*
  * CAIF state is re-using the TCP socket states.
  * caif_states stored in sk_state reflect the state as reported by
@@ -1118,10 +1115,6 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	/* Store the protocol */
 	sk->sk_protocol = (unsigned char) protocol;
 
-	/* Sendbuf dictates the amount of outbound packets not yet sent */
-	sk->sk_sndbuf = CAIF_DEF_SNDBUF;
-	sk->sk_rcvbuf = CAIF_DEF_RCVBUF;
-
 	/*
 	 * Lock in order to try to stop someone from opening the socket
 	 * too early.
-- 
1.6.3.3

