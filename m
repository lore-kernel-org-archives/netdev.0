From: Dmitry Petukhov <dmgenp@gmail.com>
Subject: [PATCH net] l2tp: take PMTU from tunnel UDP socket
Date: Wed, 9 Apr 2014 02:23:20 +0600
Message-ID: <20140409022320.752f036a@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:33882 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179AbaDHUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 16:24:30 -0400
Received: by mail-bk0-f43.google.com with SMTP id v15so1246451bkz.16
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 13:24:29 -0700 (PDT)
Received: from laptop ([82.193.155.251])
        by mx.google.com with ESMTPSA id q4sm2446633lbh.20.2014.04.08.13.24.27
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 13:24:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When l2tp driver tries to get PMTU for the tunnel destination, it uses
the pointer to struct sock that represents PPPoX socket, while it
should use the pointer that represents UDP socket of the tunnel.

Signed-off-by: Dmitry Petukhov <dmgenp@gmail.com>
---
 net/l2tp/l2tp_ppp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d276e2d..950909f 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -753,9 +753,9 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	session->deref = pppol2tp_session_sock_put;
 
 	/* If PMTU discovery was enabled, use the MTU that was discovered */
-	dst = sk_dst_get(sk);
+	dst = sk_dst_get(tunnel->sock);
 	if (dst != NULL) {
-		u32 pmtu = dst_mtu(__sk_dst_get(sk));
+		u32 pmtu = dst_mtu(__sk_dst_get(tunnel->sock));
 		if (pmtu != 0)
 			session->mtu = session->mru = pmtu -
 				PPPOL2TP_HEADER_OVERHEAD;
--
1.7.9.5
