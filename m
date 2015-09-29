From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next] net/mlx4_core: Test interrupts fail if not all comp vectors called request_irq
Date: Tue, 29 Sep 2015 13:38:11 -0500
Message-ID: <1443551891-17971-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, amirv@mellanox.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:55463 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964820AbbI2Smz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 14:42:55 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Tue, 29 Sep 2015 15:42:50 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 7C3143520078
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 14:41:40 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8TIesmm21561648
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:54 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8TIglJm006910
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:42:48 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

Test interrupts fails if not all completion vectors called
request_irq. This case can happen if only mlx4_en loads and
we have more completion vectors than rx rings.

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 8e81e53..c344884 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 	 * and performing a NOP command
 	 */
 	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
+		/* Make sure request_irq was called */
+		if (!priv->eq_table.eq[i].have_irq)
+			continue;
+
 		/* Temporary use polling for command completions */
 		mlx4_cmd_use_polling(dev);
 
-- 
1.8.3.1
