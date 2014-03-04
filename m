From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4: Support shutdown() interface
Date: Tue,  4 Mar 2014 15:35:20 +0800
Message-ID: <1393918520-3268-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: amirv@mellanox.com, weiyang@linux.vnet.ibm.com,
	benh@kernel.crashing.org, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:50500 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756201AbaCDHfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 02:35:39 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 4 Mar 2014 02:35:39 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D8D3EC90041
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 02:35:33 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s247Za9G6816126
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2014 07:35:37 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s247Za2Y004118
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2014 02:35:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In kexec scenario, we failed to load the mlx4 driver in the
second kernel because the ownership bit was hold by the first
kernel without release correctly.

The patch adds shutdown() interface so that the ownership can
be released correctly in the first kernel. It also helps avoiding
EEH error happened during boot stage of the second kernel because
of undesired traffic, which can't be handled by hardware during
that stage on Power platform.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Tested-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..5a6105f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2684,6 +2684,7 @@ static struct pci_driver mlx4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= mlx4_pci_table,
 	.probe		= mlx4_init_one,
+	.shutdown	= mlx4_remove_one,
 	.remove		= mlx4_remove_one,
 	.err_handler    = &mlx4_err_handler,
 };
-- 
1.7.10.4
