From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 05/15] ehea: Dont check NETIF_F_TSO in TX path
Date: Fri, 14 Oct 2011 12:31:02 -0300
Message-ID: <1318606272-27647-6-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:39547 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756935Ab1JNPb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:56 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:53 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUFaV3444792
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:15 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVV9w008616
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:32 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

It seems like the ehea xmit routine and an ethtool change of TSO
mode could race, resulting in corrupt packets. Checking gso_size
is enough and we can use the helper function.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 6ded42a..0cb3a9b 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1787,7 +1787,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
-	if ((dev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		write_swqe2_TSO(skb, swqe, lkey);
 	else
 		write_swqe2_nonTSO(skb, swqe, lkey);
-- 
1.7.4.4
