From: clsoto@linux.vnet.ibm.com
Subject: [PATCH] net/mlx4: Memcpy at slave_event should copy sizeof mlx4_eqe
Date: Fri, 23 Oct 2015 10:19:00 -0400
Message-ID: <1445609940-12234-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, yevgenyp@mellanox.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:49064 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbJWOTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 10:19:13 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Fri, 23 Oct 2015 12:19:11 -0200
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id BD4F81DC0071
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 10:18:03 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9NEJagm4751458
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 12:19:36 -0200
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9NEJ65v006367
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 12:19:06 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If the caps.eqe_size is bigger than the struct mlx4_eqe then there
is a potential for corrupting data at the master context. We can see
the message "Master failed to generate an EQE for slave: X" when the 
event_eqe array wraps and we can see potential oops at the function
mlx4_GEN_EQE. 

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index c344884..603d1c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -196,7 +196,7 @@ static void slave_event(struct mlx4_dev *dev, u8 slave, struct mlx4_eqe *eqe)
 		return;
 	}
 
-	memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
+	memcpy(s_eqe, eqe, sizeof(struct mlx4_eqe) - 1);
 	s_eqe->slave_id = slave;
 	/* ensure all information is written before setting the ownersip bit */
 	dma_wmb();
-- 
1.8.3.1
