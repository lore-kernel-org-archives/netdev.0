From: Michael Witten <mfwitten@gmail.com>
Subject: [PATCH net 1/3] net: __sock_cmsg_send(): Remove unused parameter `msg'
Date: Sun, 01 Oct 2017 22:19:09 -0000
Message-ID: <4556542c58034fcaa3bdc5697ba247e9-mfwitten@gmail.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
            <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Thu, 7 Sep 2017 03:21:38 +0000
Signed-off-by: Michael Witten <mfwitten@gmail.com>
---
 include/net/sock.h     | 2 +-
 net/core/sock.c        | 4 ++--
 net/ipv4/ip_sockglue.c | 2 +-
 net/ipv6/datagram.c    | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 03a362568357..83373d7148a9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1562,7 +1562,7 @@ struct sockcm_cookie {
 	u16 tsflags;
 };
 
-int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+int __sock_cmsg_send(struct sock *sk, struct cmsghdr *cmsg,
 		     struct sockcm_cookie *sockc);
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc);
diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..425e03fe1c56 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2091,7 +2091,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
-int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+int __sock_cmsg_send(struct sock *sk, struct cmsghdr *cmsg,
 		     struct sockcm_cookie *sockc)
 {
 	u32 tsflags;
@@ -2137,7 +2137,7 @@ int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 			return -EINVAL;
 		if (cmsg->cmsg_level != SOL_SOCKET)
 			continue;
-		ret = __sock_cmsg_send(sk, msg, cmsg, sockc);
+		ret = __sock_cmsg_send(sk, cmsg, sockc);
 		if (ret)
 			return ret;
 	}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e558e4f9597b..c79b7822b0b9 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -263,7 +263,7 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 		}
 #endif
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			err = __sock_cmsg_send(sk, msg, cmsg, &ipc->sockc);
+			err = __sock_cmsg_send(sk, cmsg, &ipc->sockc);
 			if (err)
 				return err;
 			continue;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a1f918713006..1d1926a4cbe2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -756,7 +756,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 		}
 
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			err = __sock_cmsg_send(sk, msg, cmsg, sockc);
+			err = __sock_cmsg_send(sk, cmsg, sockc);
 			if (err)
 				return err;
 			continue;
-- 
2.14.1
