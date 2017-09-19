From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 1/7] net: hns3: get phy addr from NCL_config
Date: Tue, 19 Sep 2017 02:06:22 +0100
Message-ID: <20170919010628.175732-2-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170919010628.175732-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

NCL_config file defines phy address for every port. Driver should get
phy address from NCL_config file.If do not get the right phy address,
every port will use the default phy address 0, different port use the
same phy address will cause error.

Signed-off-by: Lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index bb45365fb817..db4e07dac29a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1066,6 +1066,7 @@ static int hclge_configure(struct hclge_dev *hdev)
 	for (i = 0; i < ETH_ALEN; i++)
 		hdev->hw.mac.mac_addr[i] = cfg.mac_addr[i];
 	hdev->hw.mac.media_type = cfg.media_type;
+	hdev->hw.mac.phy_addr = cfg.phy_addr;
 	hdev->num_desc = cfg.tqp_desc_num;
 	hdev->tm_info.num_pg = 1;
 	hdev->tm_info.num_tc = cfg.tc_num;
-- 
2.11.0


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
