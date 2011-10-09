From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 5/7] mlx4_en: Fix QP number calculation according to module
 param
Date: Sun, 9 Oct 2011 17:29:26 +0200
Message-ID: <4E91BDD6.8080405@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53800 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751422Ab1JIP3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:29:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Number of bits taken from mac table index in QP
calculation should be based on log_num_mac parameter.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 5ada5b4..8824309 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -128,7 +128,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
-	context->n_mac = 0x2;
+	context->n_mac = dev->caps.log_num_macs;
 	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
 				       base_qpn);
 	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
-- 
1.7.5.4
