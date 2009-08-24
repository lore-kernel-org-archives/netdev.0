From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH v2 1/1] NET: llc, zero sockaddr_llc struct
Date: Mon, 24 Aug 2009 07:43:39 +0200
Message-ID: <1251092619-3368-1-git-send-email-jirislaby@gmail.com>
References: <20090823.185617.36449822.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.wserver.cz ([82.113.45.157]:57833 "EHLO
	server1.wserver.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbZHXFnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 01:43:41 -0400
In-Reply-To: <20090823.185617.36449822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sllc_arphrd member of sockaddr_llc might not be changed. Zero sllc
before copying to the above layer's structure.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/llc/af_llc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 9208cf5..c45eee1 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -914,6 +914,7 @@ static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct llc_sock *llc = llc_sk(sk);
 	int rc = 0;
 
+	memset(&sllc, 0, sizeof(sllc));
 	lock_sock(sk);
 	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
-- 
1.6.3.3

