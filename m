From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v2 10/20] infiniband: slight optimization of addr compare
Date: Tue, 24 Dec 2013 19:28:34 +0800
Message-ID: <52B96FE2.807@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Faisal Latif <faisal.latif@intel.com>,
	<linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Faisal Latif <faisal.latif@intel.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/infiniband/hw/nes/nes_cm.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 6b29249..9c9f2f5 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1354,8 +1354,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 				  neigh->ha, ntohl(rt->rt_gateway));
 
 			if (arpindex >= 0) {
-				if (!memcmp(nesadapter->arp_table[arpindex].mac_addr,
-					    neigh->ha, ETH_ALEN)) {
+				if (ether_addr_equal(nesadapter->arp_table[arpindex].mac_addr, neigh->ha)) {
 					/* Mac address same as in nes_arp_table */
 					goto out;
 				}
-- 
1.8.0
