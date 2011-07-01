From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/12] ipv4: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:07 -0700
Message-ID: <322301b8ec8837951d7d2186c42f9476e9efe5f4.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

git diff -w shows no difference.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/raw.c   |   36 ++++++++++++++++++------------------
 net/ipv4/route.c |   28 ++++++++++++++--------------
 2 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index c9893d4..0852678 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -825,28 +825,28 @@ static int compat_raw_getsockopt(struct sock *sk, int level, int optname,
 static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	switch (cmd) {
-		case SIOCOUTQ: {
-			int amount = sk_wmem_alloc_get(sk);
+	case SIOCOUTQ: {
+		int amount = sk_wmem_alloc_get(sk);
 
-			return put_user(amount, (int __user *)arg);
-		}
-		case SIOCINQ: {
-			struct sk_buff *skb;
-			int amount = 0;
-
-			spin_lock_bh(&sk->sk_receive_queue.lock);
-			skb = skb_peek(&sk->sk_receive_queue);
-			if (skb != NULL)
-				amount = skb->len;
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			return put_user(amount, (int __user *)arg);
-		}
+		return put_user(amount, (int __user *)arg);
+	}
+	case SIOCINQ: {
+		struct sk_buff *skb;
+		int amount = 0;
+
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL)
+			amount = skb->len;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
 
-		default:
+	default:
 #ifdef CONFIG_IP_MROUTE
-			return ipmr_ioctl(sk, cmd, (void __user *)arg);
+		return ipmr_ioctl(sk, cmd, (void __user *)arg);
 #else
-			return -ENOIOCTLCMD;
+		return -ENOIOCTLCMD;
 #endif
 	}
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f24c335..a8ccd9b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1439,20 +1439,20 @@ static int ip_error(struct sk_buff *skb)
 	int code;
 
 	switch (rt->dst.error) {
-		case EINVAL:
-		default:
-			goto out;
-		case EHOSTUNREACH:
-			code = ICMP_HOST_UNREACH;
-			break;
-		case ENETUNREACH:
-			code = ICMP_NET_UNREACH;
-			IP_INC_STATS_BH(dev_net(rt->dst.dev),
-					IPSTATS_MIB_INNOROUTES);
-			break;
-		case EACCES:
-			code = ICMP_PKT_FILTERED;
-			break;
+	case EINVAL:
+	default:
+		goto out;
+	case EHOSTUNREACH:
+		code = ICMP_HOST_UNREACH;
+		break;
+	case ENETUNREACH:
+		code = ICMP_NET_UNREACH;
+		IP_INC_STATS_BH(dev_net(rt->dst.dev),
+				IPSTATS_MIB_INNOROUTES);
+		break;
+	case EACCES:
+		code = ICMP_PKT_FILTERED;
+		break;
 	}
 
 	if (!rt->peer)
-- 
1.7.6.rc1
