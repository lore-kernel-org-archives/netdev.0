From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 1/4] net: hns3: fix the bug of hns3_set_txbd_baseinfo
Date: Tue, 24 Oct 2017 21:02:09 +0800
Message-ID: <1508850132-106101-2-git-send-email-lipeng321@huawei.com>
References: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SC bits of TX BD mean switch control. For this area, value 0
indicates no switch control, the packet is routed according to the
forwarding table. Value 1 indicates that the packet is transmitted
to the network bypassing the forwarding table.

As HNS3 driver need support VF later, VF conmunicate with its own
PF need forwarding table. This patch sets SC bits of TX BD 0 and use
forwarding table.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 537f6c3..c6c5b2a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -716,7 +716,7 @@ static void hns3_set_txbd_baseinfo(u16 *bdtp_fe_sc_vld_ra_ri, int frag_end)
 		       HNS3_TXD_BDTYPE_M, 0);
 	hnae_set_bit(*bdtp_fe_sc_vld_ra_ri, HNS3_TXD_FE_B, !!frag_end);
 	hnae_set_bit(*bdtp_fe_sc_vld_ra_ri, HNS3_TXD_VLD_B, 1);
-	hnae_set_field(*bdtp_fe_sc_vld_ra_ri, HNS3_TXD_SC_M, HNS3_TXD_SC_S, 1);
+	hnae_set_field(*bdtp_fe_sc_vld_ra_ri, HNS3_TXD_SC_M, HNS3_TXD_SC_S, 0);
 }
 
 static int hns3_fill_desc(struct hns3_enet_ring *ring, void *priv,
-- 
1.9.1
