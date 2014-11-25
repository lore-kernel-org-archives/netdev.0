From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 01/17] new helper: skb_copy_and_csum_datagram_msg()
Date: Tue, 25 Nov 2014 14:02:15 +0000
Message-ID: <1416924151-28698-1-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |    5 +++++
 net/ipv4/udp.c         |    5 ++---
 net/ipv6/raw.c         |    2 +-
 net/ipv6/udp.c         |    2 +-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 78c299f..cbe4b20 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2651,6 +2651,11 @@ static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
 }
 int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb, int hlen,
 				     struct iovec *iov);
+static inline int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
+			    struct msghdr *msg)
+{
+	return skb_copy_and_csum_datagram_iovec(skb, hlen, msg->msg_iov);
+}
 int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 				 const struct iovec *from, int from_offset,
 				 int len);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4a16b91..b2d6068 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1284,9 +1284,8 @@ try_again:
 		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
 					    msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_iovec(skb,
-						       sizeof(struct udphdr),
-						       msg->msg_iov);
+		err = skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr),
+						     msg);
 
 		if (err == -EINVAL)
 			goto csum_copy_err;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0cbcf98..8baa53e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -492,7 +492,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			goto csum_copy_err;
 		err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	} else {
-		err = skb_copy_and_csum_datagram_iovec(skb, 0, msg->msg_iov);
+		err = skb_copy_and_csum_datagram_msg(skb, 0, msg);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index dbc0b04..7cfb5d74 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -428,7 +428,7 @@ try_again:
 		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
 					    msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
+		err = skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr), msg);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
-- 
1.7.10.4
