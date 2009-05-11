From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC 3/5] net: sk_buff - introduce br_seen field to mark skb issued by a bridge
Date: Mon, 11 May 2009 15:46:42 +0400
Message-ID: <20090511125350.996551330@openvz.org>
References: <20090511114639.440944109@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:27590 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbZEKMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 08:53:57 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2140705rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 05:53:57 -0700 (PDT)
Content-Disposition: inline; filename=net-br-introduce-skb-brmark
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To distinguish skb's that was issued by a bridge (to not
loop forever) special skb mark is needed - br_seen.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/skbuff.h |    3 +++
 net/core/skbuff.c      |    3 +++
 2 files changed, 6 insertions(+)

Index: linux-2.6.git/include/linux/skbuff.h
=====================================================================
--- linux-2.6.git.orig/include/linux/skbuff.h
+++ linux-2.6.git/include/linux/skbuff.h
@@ -382,6 +382,9 @@ struct sk_buff {
 	__u8			do_not_encrypt:1;
 	__u8			requeue:1;
 #endif
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+	__u8			br_seen:1;
+#endif
 	/* 0/13/14 bit hole */
 
 #ifdef CONFIG_NET_DMA
Index: linux-2.6.git/net/core/skbuff.c
=====================================================================
--- linux-2.6.git.orig/net/core/skbuff.c
+++ linux-2.6.git/net/core/skbuff.c
@@ -549,6 +549,9 @@ static void __copy_skb_header(struct sk_
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+	new->br_seen		= old->br_seen;
+#endif
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);

