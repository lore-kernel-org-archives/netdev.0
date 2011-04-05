From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 5/14] ehea: Don't check NETIF_F_TSO in TX path
Date: Tue, 5 Apr 2011 21:33:54 +1000
Message-ID: <20110405213354.0c45b523@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39024 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1DELd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:33:56 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems like the ehea xmit routine and an ethtool change of TSO
mode could race, resulting in corrupt packets. Checking gso_size
is enough and we can use the helper function.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-03-21 18:32:34.568292440 +1100
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-03-21 18:32:37.398397405 +1100
@@ -1792,7 +1792,7 @@ static inline void write_swqe2_data(stru
 	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
-	if ((dev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		write_swqe2_TSO(skb, swqe, lkey);
 	else
 		write_swqe2_nonTSO(skb, swqe, lkey);
