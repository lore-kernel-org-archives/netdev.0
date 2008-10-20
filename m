From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/07: replace old NF_ARP calls with NFPROTO_ARP
Date: Mon, 20 Oct 2008 11:54:18 +0200 (MEST)
Message-ID: <20081020095417.25670.96997.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52363 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbYJTJyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:54:19 -0400
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 01ff237de9f0144bcc024721c3b9a0eac724b0fb
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Oct 20 11:47:30 2008 +0200

    netfilter: replace old NF_ARP calls with NFPROTO_ARP
    
    (Supplements: ee999d8b9573df1b547aacdc6d79f86eb79c25cd)
    
    NFPROTO_ARP actually has a different value from NF_ARP, so ensure all
    callers use the new value so that packets _do_ get delivered to the
    registered hooks.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a4abed5..fa5cda4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -719,7 +719,7 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 	*d = (struct net_device *)in;
-	NF_HOOK(NF_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
 		(struct net_device *)out, br_nf_forward_finish);
 
 	return NF_STOLEN;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b043eda..1a9dd66 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -663,7 +663,7 @@ out:
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NF_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
 }
 
 /*
@@ -928,7 +928,7 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
-	return NF_HOOK(NF_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
+	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
 
 freeskb:
 	kfree_skb(skb);
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 2cc1fff..f9977b3 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -48,7 +48,7 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 	},
 	{
 		.name		= "NFQUEUE",
-		.family		= NF_ARP,
+		.family		= NFPROTO_ARP,
 		.target		= nfqueue_tg,
 		.targetsize	= sizeof(struct xt_NFQ_info),
 		.me		= THIS_MODULE,
