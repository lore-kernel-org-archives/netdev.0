From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 2/3] net: netcp: ethss: fix up incorrect use of list api
Date: Tue, 28 Jul 2015 18:20:13 -0400
Message-ID: <1438122014-24744-3-git-send-email-m-karicheri2@ti.com>
References: <1438122014-24744-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438122014-24744-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code seems to assume a null is returned when the list is empty
from first_sec_slave() to break the loop which is incorrect. Fix the
code by using list_empty().

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 9b7e0a3..77bcfca 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2490,10 +2490,9 @@ static void free_secondary_ports(struct gbe_priv *gbe_dev)
 {
 	struct gbe_slave *slave;
 
-	for (;;) {
+	while (!list_empty(&gbe_dev->secondary_slaves)) {
 		slave = first_sec_slave(gbe_dev);
-		if (!slave)
-			break;
+
 		if (slave->phy)
 			phy_disconnect(slave->phy);
 		list_del(&slave->slave_list);
-- 
1.9.1
