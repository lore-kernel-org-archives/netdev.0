From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix kmemcheck annotations
Date: Thu, 29 Oct 2009 11:10:37 +0100
Message-ID: <4AE96A1D.8050300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42601 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbZJ2KKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:10:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sk_buff kmemcheck annotations enlarged this structure by 8/16 bytes

Fix this by moving 'protocol' inside flags1 bitfield,
and queue_mapping inside flags2 bitfield.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0c68fbd..defd51d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -354,8 +354,8 @@ struct sk_buff {
 				ipvs_property:1,
 				peeked:1,
 				nf_trace:1;
+	__be16			protocol:16;
 	kmemcheck_bitfield_end(flags1);
-	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
@@ -367,7 +367,6 @@ struct sk_buff {
 #endif
 
 	int			iif;
-	__u16			queue_mapping;
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
@@ -376,6 +375,7 @@ struct sk_buff {
 #endif
 
 	kmemcheck_bitfield_begin(flags2);
+	__u16			queue_mapping:16;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
