From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rfs: call sock_rps_record_flow() in tcp_splice_read()
Date: Tue, 13 Jul 2010 15:00:12 +0800
Message-ID: <1279004412-11094-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:49811 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab0GMHCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 03:02:44 -0400
Received: by pxi14 with SMTP id 14so2161163pxi.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 00:02:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rfs: call sock_rps_record_flow() in tcp_splice_read()

call sock_rps_record_flow() in tcp_splice_read(), so the applications using
splice(2) or sendfile(2) can utilize RFS.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/tcp.c |    1 +
 1 file changed, 1 insertion(+)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9fce8a8..86b9f67 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -608,6 +608,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 	ssize_t spliced;
 	int ret;
 
+	sock_rps_record_flow(sk);
 	/*
 	 * We can't seek on a socket input
 	 */
