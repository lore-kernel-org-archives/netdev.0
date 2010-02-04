From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 17/23 v3] mlx4_core: Randomize Mac addresses for slaves
Date: Thu, 04 Feb 2010 17:56:40 +0200
Message-ID: <4B6AEE38.4010207@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49849 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933121Ab0BDP4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:42 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/fw.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 6e3e1d1..202a256 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -32,6 +32,7 @@
  * SOFTWARE.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/mlx4/cmd.h>
 #include <linux/cache.h>
 
@@ -149,11 +150,19 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 						       struct mlx4_cmd_mailbox *outbox)
 {
 	struct mlx4_caps *caps = outbox->buf;
+	u8 rand_mac[6];
+	int i, j;
 
 	memcpy(caps, &dev->caps, sizeof *caps);
 
 	/* The Master function is in charge for qp1 of al slaves */
 	caps->sqp_demux = 0;
+	for (i = 1; i <= dev->caps.num_ports; ++i) {
+		random_ether_addr(rand_mac);
+		caps->def_mac[i] = 0;
+		for (j = 0; j < ETH_ALEN - 1; j++)
+			caps->def_mac[i] |= ((u64)(rand_mac[j]) << 8 * j);
+	}
 
 	/* Ports are activated according to physical function number */
 	mlx4_set_port_mask(dev, caps, slave);
-- 
1.6.1.3


