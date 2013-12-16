From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 9/10] lro: remove unused code
Date: Mon, 16 Dec 2013 10:45:31 -0800
Message-ID: <20131216104531.27407d6f@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59225 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab3LPTkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:36 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so3426007pab.27
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:35 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is not used anywhere in net-next

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/linux/inet_lro.h	2013-10-06 14:48:24.742452035 -0700
+++ b/include/linux/inet_lro.h	2013-12-12 13:28:31.971391114 -0800
@@ -133,33 +133,10 @@ struct net_lro_mgr {
 void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv);
-
-/*
- * Processes a fragment list
- *
- * This functions aggregate fragments and generate SKBs do pass
- * the packets to the stack.
- *
- * @lro_mgr: LRO manager to use
- * @frags: Fragment to be processed. Must contain entire header in first
- *         element.
- * @len: Length of received data
- * @true_size: Actual size of memory the fragment is consuming
- * @priv: Private data that may be used by driver functions
- *        (for example get_tcp_ip_hdr)
- */
-
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv, __wsum sum);
-
 /*
  * Forward all aggregated SKBs held by lro_mgr to network stack
  */
 
 void lro_flush_all(struct net_lro_mgr *lro_mgr);
 
-void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
-		   struct iphdr *iph, struct tcphdr *tcph);
-
 #endif
--- a/net/ipv4/inet_lro.c	2013-10-06 14:48:24.966449847 -0700
+++ b/net/ipv4/inet_lro.c	2013-12-12 13:28:43.435225437 -0800
@@ -506,23 +506,6 @@ void lro_receive_skb(struct net_lro_mgr
 }
 EXPORT_SYMBOL(lro_receive_skb);
 
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv, __wsum sum)
-{
-	struct sk_buff *skb;
-
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);
-	if (!skb)
-		return;
-
-	if (lro_mgr->features & LRO_F_NAPI)
-		netif_receive_skb(skb);
-	else
-		netif_rx(skb);
-}
-EXPORT_SYMBOL(lro_receive_frags);
-
 void lro_flush_all(struct net_lro_mgr *lro_mgr)
 {
 	int i;
@@ -534,14 +517,3 @@ void lro_flush_all(struct net_lro_mgr *l
 	}
 }
 EXPORT_SYMBOL(lro_flush_all);
-
-void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
-		  struct iphdr *iph, struct tcphdr *tcph)
-{
-	struct net_lro_desc *lro_desc;
-
-	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
-	if (lro_desc->active)
-		lro_flush(lro_mgr, lro_desc);
-}
-EXPORT_SYMBOL(lro_flush_pkt);
