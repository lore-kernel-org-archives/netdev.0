From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4: Performing SENSE_PORT command only when supported
Date: Wed, 4 May 2011 16:38:46 +0300
Message-ID: <4DC156E6.7070704@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45941 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753250Ab1EDNit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 09:38:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Not all HW supports this functionality, and in this case FW would
report command error.
This patch checks this capability before trying to sense link partner.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 3814fc9..f47ac5a 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -944,10 +944,12 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 	}
 
 	for (port = 1; port <= dev->caps.num_ports; port++) {
-		enum mlx4_port_type port_type = 0;
-		mlx4_SENSE_PORT(dev, port, &port_type);
-		if (port_type)
-			dev->caps.port_type[port] = port_type;
+		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_DPDP) {
+			enum mlx4_port_type port_type = 0;
+			mlx4_SENSE_PORT(dev, port, &port_type);
+			if (port_type)
+				dev->caps.port_type[port] = port_type;
+		}
 		ib_port_default_caps = 0;
 		err = mlx4_get_port_ib_caps(dev, port, &ib_port_default_caps);
 		if (err)
-- 
1.6.0.2



