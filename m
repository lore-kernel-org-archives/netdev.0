From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 6/7] ipv6: Remove useless parameter in __snmp6_fill_statsdev
Date: Mon, 26 Sep 2016 16:09:14 +0800
Message-ID: <1474877355-12920-7-git-send-email-hejianet@gmail.com>
References: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        marcelo.leitner@gmail.com, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The parameter items(always ICMP6_MIB_MAX) is useless for __snmp6_fill_statsdev.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv6/addrconf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2f1f5d4..35d4baa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4961,18 +4961,18 @@ static inline size_t inet6_if_nlmsg_size(void)
 }
 
 static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
-				      int items, int bytes)
+					int bytes)
 {
 	int i;
-	int pad = bytes - sizeof(u64) * items;
+	int pad = bytes - sizeof(u64) * ICMP6_MIB_MAX;
 	BUG_ON(pad < 0);
 
 	/* Use put_unaligned() because stats may not be aligned for u64. */
-	put_unaligned(items, &stats[0]);
-	for (i = 1; i < items; i++)
+	put_unaligned(ICMP6_MIB_MAX, &stats[0]);
+	for (i = 1; i < ICMP6_MIB_MAX; i++)
 		put_unaligned(atomic_long_read(&mib[i]), &stats[i]);
 
-	memset(&stats[items], 0, pad);
+	memset(&stats[ICMP6_MIB_MAX], 0, pad);
 }
 
 static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
@@ -5005,7 +5005,7 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 				     offsetof(struct ipstats_mib, syncp));
 		break;
 	case IFLA_INET6_ICMP6STATS:
-		__snmp6_fill_statsdev(stats, idev->stats.icmpv6dev->mibs, ICMP6_MIB_MAX, bytes);
+		__snmp6_fill_statsdev(stats, idev->stats.icmpv6dev->mibs, bytes);
 		break;
 	}
 }
-- 
2.5.5
