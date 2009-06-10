From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/31: queue: use NFPROTO_ for queue callsites
Date: Wed, 10 Jun 2009 21:46:25 +0200 (MEST)
Message-ID: <20090610194623.11112.32685.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4b1e27e99f354ad90a1cbdda352b84763e70ac78
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Apr 14 14:26:49 2009 +0200

    netfilter: queue: use NFPROTO_ for queue callsites
    
    af is an nfproto.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 5f22c91..c156db2 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -596,7 +596,7 @@ static int __init ip_queue_init(void)
 #ifdef CONFIG_SYSCTL
 	ipq_sysctl_header = register_sysctl_paths(net_ipv4_ctl_path, ipq_table);
 #endif
-	status = nf_register_queue_handler(PF_INET, &nfqh);
+	status = nf_register_queue_handler(NFPROTO_IPV4, &nfqh);
 	if (status < 0) {
 		printk(KERN_ERR "ip_queue: failed to register queue handler\n");
 		goto cleanup_sysctl;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index b693f84..1cf3f0c 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -598,7 +598,7 @@ static int __init ip6_queue_init(void)
 #ifdef CONFIG_SYSCTL
 	ipq_sysctl_header = register_sysctl_paths(net_ipv6_ctl_path, ipq_table);
 #endif
-	status = nf_register_queue_handler(PF_INET6, &nfqh);
+	status = nf_register_queue_handler(NFPROTO_IPV6, &nfqh);
 	if (status < 0) {
 		printk(KERN_ERR "ip6_queue: failed to register queue handler\n");
 		goto cleanup_sysctl;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 4f2310c..3a6fd77 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -204,10 +204,10 @@ int nf_queue(struct sk_buff *skb,
 				  queuenum);
 
 	switch (pf) {
-	case AF_INET:
+	case NFPROTO_IPV4:
 		skb->protocol = htons(ETH_P_IP);
 		break;
-	case AF_INET6:
+	case NFPROTO_IPV6:
 		skb->protocol = htons(ETH_P_IPV6);
 		break;
 	}
