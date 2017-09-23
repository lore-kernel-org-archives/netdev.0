From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 2/3] net: use inet6_rcv_saddr to compare sockets
Date: Fri, 22 Sep 2017 20:20:07 -0400
Message-ID: <1506126008-9148-3-git-send-email-josef@toxicpanda.com>
References: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Cc: Josef Bacik <jbacik@fb.com>
To: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

In ipv6_rcv_saddr_equal() we need to use inet6_rcv_saddr(sk) for the
ipv6 compare with the fast socket information to make sure we're doing
the proper comparisons.

Fixes: 637bc8bbe6c0 ("inet: reset tb->fastreuseport when adding a reuseport sk")
Reported-and-tested-by: Cole Robinson <crobinso@redhat.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f87f4805e244..a1bf30438bc5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -266,7 +266,7 @@ static inline int sk_reuseport_match(struct inet_bind_bucket *tb,
 #if IS_ENABLED(CONFIG_IPV6)
 	if (tb->fast_sk_family == AF_INET6)
 		return ipv6_rcv_saddr_equal(&tb->fast_v6_rcv_saddr,
-					    &sk->sk_v6_rcv_saddr,
+					    inet6_rcv_saddr(sk),
 					    tb->fast_rcv_saddr,
 					    sk->sk_rcv_saddr,
 					    tb->fast_ipv6_only,
-- 
2.7.4
