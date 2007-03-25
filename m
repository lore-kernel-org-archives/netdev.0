From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Fix breakage, use ip_hdr() for DF check in ip_forward
Date: Sun, 25 Mar 2007 15:37:31 +0200
Message-ID: <20070325133731.GH521@postel.suug.ch>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11746948061847-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43826 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbXCYNhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 09:37:11 -0400
Content-Disposition: inline
In-Reply-To: <11746948061847-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch [NET] Move DF check to ip_forward broke net-2.6.22 as
skb->nh has been renamed to skb->network_header. Use ip_hdr().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/ip_forward.c
===================================================================
--- net-2.6.22.orig/net/ipv4/ip_forward.c	2007-03-25 15:31:32.000000000 +0200
+++ net-2.6.22/net/ipv4/ip_forward.c	2007-03-25 15:32:21.000000000 +0200
@@ -86,7 +86,7 @@ int ip_forward(struct sk_buff *skb)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->u.dst) &&
-	             (skb->nh.iph->frag_off & htons(IP_DF))) && !skb->local_df) {
+	             (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->u.dst)));
