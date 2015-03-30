From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/9 net-next] ipv4: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:09 +0200
Message-ID: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/devinet.c       | 3 +--
 net/ipv4/esp4.c          | 3 +--
 net/ipv4/icmp.c          | 3 +--
 net/ipv4/ip_output.c     | 4 ++--
 net/ipv4/ping.c          | 3 +--
 net/ipv4/tcp_input.c     | 8 ++++----
 net/ipv4/tcp_minisocks.c | 4 ++--
 net/ipv4/tcp_output.c    | 3 +--
 8 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 975ee5e..e4b53f7 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1715,8 +1715,7 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (!in_dev)
 		return -EAFNOSUPPORT;
 
-	if (nla_parse_nested(tb, IFLA_INET_MAX, nla, NULL) < 0)
-		BUG();
+	BUG_ON(nla_parse_nested(tb, IFLA_INET_MAX, nla, NULL) < 0);
 
 	if (tb[IFLA_INET_CONF]) {
 		nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 60173d4..02d41d0 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -289,8 +289,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	if (unlikely(err))
 		goto out;
 
-	if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2));
 
 	err = -EINVAL;
 	padlen = nexthdr[0];
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5e56401..6d59e26 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -922,8 +922,7 @@ static bool icmp_timestamp(struct sk_buff *skb)
 	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC +
 					 tv.tv_nsec / NSEC_PER_MSEC);
 	icmp_param.data.times[2] = icmp_param.data.times[1];
-	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4));
 	icmp_param.data.icmph	   = *icmp_hdr(skb);
 	icmp_param.data.icmph.type = ICMP_TIMESTAMPREPLY;
 	icmp_param.data.icmph.code = 0;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8259e77..f58f52b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -695,8 +695,8 @@ slow_path:
 		/*
 		 *	Copy a block of the IP datagram.
 		 */
-		if (skb_copy_bits(skb, ptr, skb_transport_header(skb2), len))
-			BUG();
+		BUG_ON(skb_copy_bits(skb, ptr, skb_transport_header(skb2),
+				     len));
 		left -= len;
 
 		/*
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 344e7cd..5536c2b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -608,8 +608,7 @@ int ping_getfrag(void *from, char *to,
 
 	if (offset == 0) {
 		fraglen -= sizeof(struct icmphdr);
-		if (fraglen < 0)
-			BUG();
+		BUG_ON(fraglen < 0);
 		if (csum_and_copy_from_iter(to + sizeof(struct icmphdr),
 			    fraglen, &pfh->wcheck,
 			    &pfh->msg->msg_iter) != fraglen)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 023196f..7ae07a4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4642,8 +4642,9 @@ restart:
 			BUG_ON(offset < 0);
 			if (size > 0) {
 				size = min(copy, size);
-				if (skb_copy_bits(skb, offset, skb_put(nskb, size), size))
-					BUG();
+				BUG_ON(skb_copy_bits(skb, offset,
+						     skb_put(nskb, size),
+						     size));
 				TCP_SKB_CB(nskb)->end_seq += size;
 				copy -= size;
 				start += size;
@@ -4966,8 +4967,7 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, const struct tcphdr *t
 		/* Is the urgent pointer pointing into this packet? */
 		if (ptr < skb->len) {
 			u8 tmp;
-			if (skb_copy_bits(skb, ptr, &tmp, 1))
-				BUG();
+			BUG_ON(skb_copy_bits(skb, ptr, &tmp, 1));
 			tp->urg_data = TCP_URG_VALID | tmp;
 			if (!sock_flag(sk, SOCK_DEAD))
 				sk->sk_data_ready(sk);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 274e96f..90e5c9f 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -334,8 +334,8 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			key = tp->af_specific->md5_lookup(sk, sk);
 			if (key != NULL) {
 				tcptw->tw_md5_key = kmemdup(key, sizeof(*key), GFP_ATOMIC);
-				if (tcptw->tw_md5_key && !tcp_alloc_md5sig_pool())
-					BUG();
+				BUG_ON(tcptw->tw_md5_key &&
+				       !tcp_alloc_md5sig_pool());
 			}
 		} while (0);
 #endif
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2e69b8d..aa78fc2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2564,8 +2564,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		return -EBUSY;
 
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
-		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
-			BUG();
+		BUG_ON(before(TCP_SKB_CB(skb)->end_seq, tp->snd_una));
 		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
 			return -ENOMEM;
 	}
-- 
1.9.1
