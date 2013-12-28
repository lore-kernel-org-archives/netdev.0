From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 10/20] net: vxge: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:17:45 +0800
Message-ID: <52BE6D09.5040106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@kudzu.us>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Jon Mason <jdmason@kudzu.us>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 11b1c70..6eae216 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -1430,7 +1430,7 @@ vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath, struct macInfo *mac)
 		return status;
 	}
 
-	while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
+	while (!ether_addr_equal(mac->macaddr, macaddr)) {
 		status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
 				macaddr, macmask);
 		if (status != VXGE_HW_OK)
-- 
1.8.0
