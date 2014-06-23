From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC net-next 01/12] tcp: cookie_v4_init_sequence: skb should be const
Date: Mon, 23 Jun 2014 21:42:38 +0300
Message-ID: <1403548969-12303-2-git-send-email-octavian.purdila@intel.com>
References: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42040 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbaFWSnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 14:43:53 -0400
In-Reply-To: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h     | 5 +++--
 net/ipv4/syncookies.c | 3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 06a3023..39e47c4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -493,10 +493,11 @@ static inline u32 tcp_cookie_time(void)
 
 u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 			      u16 *mssp);
-__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mss);
+__u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
+			      __u16 *mss);
 #else
 static inline __u32 cookie_v4_init_sequence(struct sock *sk,
-					    struct sk_buff *skb,
+					    const struct sk_buff *skb,
 					    __u16 *mss)
 {
 	return 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index c86624b..c0c7568 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -170,7 +170,8 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 }
 EXPORT_SYMBOL_GPL(__cookie_v4_init_sequence);
 
-__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+__u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
+			      __u16 *mssp)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
-- 
1.8.3.2
