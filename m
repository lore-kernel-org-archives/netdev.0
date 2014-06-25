From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 01/13] tcp: cookie_v4_init_sequence: skb should be const
Date: Wed, 25 Jun 2014 17:09:50 +0300
Message-ID: <1403705402-14388-2-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbaFYOK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:28 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
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
