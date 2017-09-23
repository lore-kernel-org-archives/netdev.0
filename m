From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/3] net: set tb->fast_sk_family
Date: Fri, 22 Sep 2017 20:20:06 -0400
Message-ID: <1506126008-9148-2-git-send-email-josef@toxicpanda.com>
References: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Cc: Josef Bacik <jbacik@fb.com>
To: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

We need to set the tb->fast_sk_family properly so we can use the proper
comparison function for all subsequent reuseport bind requests.

Fixes: 637bc8bbe6c0 ("inet: reset tb->fastreuseport when adding a reuseport sk")
Reported-and-tested-by: Cole Robinson <crobinso@redhat.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b9c64b40a83a..f87f4805e244 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -328,6 +328,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 			tb->fastuid = uid;
 			tb->fast_rcv_saddr = sk->sk_rcv_saddr;
 			tb->fast_ipv6_only = ipv6_only_sock(sk);
+			tb->fast_sk_family = sk->sk_family;
 #if IS_ENABLED(CONFIG_IPV6)
 			tb->fast_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 #endif
@@ -354,6 +355,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 				tb->fastuid = uid;
 				tb->fast_rcv_saddr = sk->sk_rcv_saddr;
 				tb->fast_ipv6_only = ipv6_only_sock(sk);
+				tb->fast_sk_family = sk->sk_family;
 #if IS_ENABLED(CONFIG_IPV6)
 				tb->fast_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 #endif
-- 
2.7.4
