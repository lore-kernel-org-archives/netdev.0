From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 05/15] ehea: Dont check NETIF_F_TSO in TX path
Date: Thu, 12 May 2011 10:52:18 +1000
Message-ID: <20110512005622.940842280@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37910 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754036Ab1ELB16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:27:58 -0400
Content-Disposition: inline; filename=ehea_6.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems like the ehea xmit routine and an ethtool change of TSO
mode could race, resulting in corrupt packets. Checking gso_size
is enough and we can use the helper function.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:53.490177714 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:54.730197374 +1000
@@ -1788,7 +1788,7 @@ static inline void write_swqe2_data(stru
 	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
-	if ((dev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		write_swqe2_TSO(skb, swqe, lkey);
 	else
 		write_swqe2_nonTSO(skb, swqe, lkey);


