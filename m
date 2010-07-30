From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo header
Date: Fri, 30 Jul 2010 08:04:18 +0800
Message-ID: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

after updating the value of the ICMP payload, inet_proto_csum_replace4() should
be called with zero pseudohdr.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 24e614c..59f05ee 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -246,7 +246,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 			iph->saddr = new_addr;
 
 		inet_proto_csum_replace4(&icmph->checksum, skb, addr, new_addr,
-					 1);
+					 0);
 		break;
 	}
 	default:
