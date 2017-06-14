From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 02/11] ipv4: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:38:07 +0800
Message-ID: <1497451087-4012-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:54796 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbdFNOii (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:38:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv4/ipconfig.c                 | 3 +--
 net/ipv4/netfilter/nf_reject_ipv4.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index c3b12b1..a6292a6 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -813,8 +813,7 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	if (!skb)
 		return;
 	skb_reserve(skb, hlen);
-	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
-	memset(b, 0, sizeof(struct bootp_pkt));
+	b = (struct bootp_pkt *) skb_put_zero(skb, sizeof(struct bootp_pkt));
 
 	/* Construct IP header */
 	skb_reset_network_header(skb);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 6f8d9e5..2569ba9 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -76,8 +76,7 @@ void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
 	struct tcphdr *tcph;
 
 	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
-	memset(tcph, 0, sizeof(*tcph));
+	tcph = (struct tcphdr *)skb_put_zero(nskb, sizeof(struct tcphdr));
 	tcph->source	= oth->dest;
 	tcph->dest	= oth->source;
 	tcph->doff	= sizeof(struct tcphdr) / 4;
-- 
2.7.4
