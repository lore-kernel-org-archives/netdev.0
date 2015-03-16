From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: kernel socket should be released in init_net namespace
Date: Mon, 16 Mar 2015 18:19:12 +0800
Message-ID: <1426501152-24764-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53426 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbCPKT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 06:19:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating a kernel socket with sock_create_kern() happens in "init_net"
namespace, however, releasing it with sk_release_kernel() occurs in
the current namespace which may be different with "init_net" namespace.
Therefore, we should guarantee that the namespace in which a kernel
socket is created is same as the socket is created.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 4bc42ef..11e144e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1454,8 +1454,8 @@ void sk_release_kernel(struct sock *sk)
 		return;
 
 	sock_hold(sk);
-	sock_release(sk->sk_socket);
 	sock_net_set(sk, get_net(&init_net));
+	sock_release(sk->sk_socket);
 	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_release_kernel);
-- 
1.7.9.5
