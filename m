From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] NET: llc, zero sockaddr_llc struct
Date: Sat, 22 Aug 2009 20:58:55 +0200
Message-ID: <1250967535-30692-1-git-send-email-jirislaby@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933302AbZHVS6z@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sllc_arphrd member of sockaddr_llc might not be set. Zero sllc
before copying it to the above layers.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/llc/af_llc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 9208cf5..22629fc 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -909,7 +909,7 @@ release:
 static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 			  int *uaddrlen, int peer)
 {
-	struct sockaddr_llc sllc;
+	struct sockaddr_llc sllc = {};
 	struct sock *sk = sock->sk;
 	struct llc_sock *llc = llc_sk(sk);
 	int rc = 0;
-- 
1.6.3.3
