From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Remove bogus variables from syncppp.[ch]
Date: Wed, 02 Jul 2008 21:11:56 +0200
Message-ID: <m3skus3xtv.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55961 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbYGBTX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

Remove bogus variables from syncppp.[ch]

diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 29b4b94..327d585 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -230,13 +230,6 @@ static void sppp_input (struct net_device *dev, struct sk_buff *skb)
 	skb->dev=dev;
 	skb_reset_mac_header(skb);
 
-	if (dev->flags & IFF_RUNNING)
-	{
-		/* Count received bytes, add FCS and one flag */
-		sp->ibytes+= skb->len + 3;
-		sp->ipkts++;
-	}
-
 	if (!pskb_may_pull(skb, PPP_HEADER_LEN)) {
 		/* Too small packet, drop it. */
 		if (sp->pp_flags & PP_DEBUG)
@@ -832,7 +825,6 @@ static void sppp_cp_send (struct sppp *sp, u16 proto, u8 type,
 			sppp_print_bytes ((u8*) (lh+1), len);
 		printk (">\n");
 	}
-	sp->obytes += skb->len;
 	/* Control is high priority so it doesn't get queued behind data */
 	skb->priority=TC_PRIO_CONTROL;
 	skb->dev = dev;
@@ -875,7 +867,6 @@ static void sppp_cisco_send (struct sppp *sp, int type, u32 par1, u32 par2)
 		printk (KERN_WARNING "%s: cisco output: <%xh %xh %xh %xh %xh-%xh>\n",
 			dev->name,  ntohl (ch->type), ch->par1,
 			ch->par2, ch->rel, ch->time0, ch->time1);
-	sp->obytes += skb->len;
 	skb->priority=TC_PRIO_CONTROL;
 	skb->dev = dev;
 	skb_queue_tail(&tx_queue, skb);
diff --git a/include/net/syncppp.h b/include/net/syncppp.h
index e43f407..9e306f7 100644
--- a/include/net/syncppp.h
+++ b/include/net/syncppp.h
@@ -43,8 +43,6 @@ struct sppp
 	u32		pp_rseq;	/* remote sequence number */
 	struct slcp	lcp;		/* LCP params */
 	struct sipcp	ipcp;		/* IPCP params */
-	u32		ibytes,obytes;	/* Bytes in/out */
-	u32		ipkts,opkts;	/* Packets in/out */
 	struct timer_list	pp_timer;
 	struct net_device	*pp_if;
 	char		pp_link_state;	/* Link status */

-- 
Krzysztof Halasa
