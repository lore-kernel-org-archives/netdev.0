From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 1/4] l2tp: remove redundant addr_len check in
 l2tp_ip_bind()
Date: Fri, 6 Jan 2017 20:03:54 +0100
Message-ID: <d5a129dbcb8f2eaff22dc5c6022b64c97ff3a484.1483727525.git.g.nault@alphalink.fr>
References: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60907 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967879AbdAFTD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:03:57 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483727525.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addr_len's value has already been verified at this point.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 3d73278b86ca..992761e721af 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -258,7 +258,7 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (!sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
-	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_l2tpip))
+	if (sk->sk_state != TCP_CLOSE)
 		goto out;
 
 	chk_addr_ret = inet_addr_type(net, addr->l2tp_addr.s_addr);
-- 
2.11.0
