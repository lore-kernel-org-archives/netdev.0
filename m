From: Michael Witten <mfwitten@gmail.com>
Subject: [PATCH net 2/3] net: inet_recvmsg(): Remove unnecessary bitwise operation
Date: Sun, 01 Oct 2017 22:19:14 -0000
Message-ID: <b03bf542933d4dbcb76427f7f4c724e5-mfwitten@gmail.com>
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

Date: Fri, 8 Sep 2017 00:47:49 +0000
The flag `MSG_DONTWAIT' is handled by passing an argument through
the dedicated parameter `nonblock' of the function `tcp_recvmsg()'.

Presumably because `MSG_DONTWAIT' is handled so explicitly, it is
unset in the collection of flags that are passed to `tcp_recvmsg()';
yet, this unsetting appears to be unnecessary, and so this commit
removes the bitwise operation that performs the unsetting.

Signed-off-by: Michael Witten <mfwitten@gmail.com>
---
 net/ipv4/af_inet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e31108e5ef79..2dbed042a412 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -791,7 +791,7 @@ int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	sock_rps_record_flow(sk);
 
 	err = sk->sk_prot->recvmsg(sk, msg, size, flags & MSG_DONTWAIT,
-				   flags & ~MSG_DONTWAIT, &addr_len);
+				   flags, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
-- 
2.14.1
