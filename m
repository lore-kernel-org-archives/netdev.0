From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 04/20] net: enic: slight optimization of addr compare
Date: Fri, 27 Dec 2013 14:48:20 +0800
Message-ID: <52BD22B4.5080400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Christian Benvenuti <benve@cisco.com>
Cc: Sujith Sankar <ssujith@cisco.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Cc: Neel Patel <neepatel@cisco.com>
Cc: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/cisco/enic/enic_pp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index 43464f0..e6a8319 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -162,7 +162,7 @@ static int enic_are_pp_different(struct enic_port_profile *pp1,
 	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
 		pp2->instance_uuid, PORT_UUID_MAX) |
 		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
-		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
+		!ether_addr_equal(pp1->mac_addr, pp2->mac_addr);
 }
 
 static int enic_pp_preassociate(struct enic *enic, int vf,
-- 
1.8.0
