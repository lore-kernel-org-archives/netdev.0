From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 7/7] net: hns3: Cleanup for non-static function in hns3 driver
Date: Mon, 9 Oct 2017 15:44:01 +0800
Message-ID: <1507535041-204956-8-git-send-email-linyunsheng@huawei.com>
References: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:7522 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753879AbdJIG7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 02:59:15 -0400
In-Reply-To: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warning from sparse:
warning: symbol 'hns3_set_multicast_list' was not declared.
Should it be static.

hns3_set_multicast_list turns out to be not used, so delete it.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c   |  4 ++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c  | 14 +++++++-------
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c   | 20 ++++----------------
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c    |  4 ++--
 4 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
index 05985d8..8ecd807 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
@@ -276,8 +276,8 @@ int hclge_cmd_send(struct hclge_hw *hw, struct hclge_desc *desc, int num)
 	return retval;
 }
 
-enum hclge_cmd_status hclge_cmd_query_firmware_version(struct hclge_hw *hw,
-						       u32 *version)
+static enum hclge_cmd_status hclge_cmd_query_firmware_version(
+		struct hclge_hw *hw, u32 *version)
 {
 	struct hclge_query_version_cmd *resp;
 	struct hclge_desc desc;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 6115c2f..c91c779 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1550,8 +1550,8 @@ static int hclge_tx_buffer_calc(struct hclge_dev *hdev,
  * @buf_alloc: pointer to buffer calculation data
  * @return: 0: calculate sucessful, negative: fail
  */
-int hclge_rx_buffer_calc(struct hclge_dev *hdev,
-			 struct hclge_pkt_buf_alloc *buf_alloc)
+static int hclge_rx_buffer_calc(struct hclge_dev *hdev,
+				struct hclge_pkt_buf_alloc *buf_alloc)
 {
 	u32 rx_all = hdev->pkt_buf_size;
 	int no_pfc_priv_num, pfc_priv_num;
@@ -2828,9 +2828,9 @@ int hclge_map_vport_ring_to_vector(struct hclge_vport *vport, int vector_id,
 	return 0;
 }
 
-int hclge_map_handle_ring_to_vector(struct hnae3_handle *handle,
-				    int vector,
-				    struct hnae3_ring_chain_node *ring_chain)
+static int hclge_map_handle_ring_to_vector(
+		struct hnae3_handle *handle, int vector,
+		struct hnae3_ring_chain_node *ring_chain)
 {
 	struct hclge_vport *vport = hclge_get_vport(handle);
 	struct hclge_dev *hdev = vport->back;
@@ -3206,8 +3206,8 @@ static void hclge_prepare_mac_addr(struct hclge_mac_vlan_tbl_entry_cmd *new_req,
 	new_req->mac_addr_lo16 = cpu_to_le16(low_val & 0xffff);
 }
 
-u16 hclge_get_mac_addr_to_mta_index(struct hclge_vport *vport,
-				    const u8 *addr)
+static u16 hclge_get_mac_addr_to_mta_index(struct hclge_vport *vport,
+					   const u8 *addr)
 {
 	u16 high_val = addr[1] | (addr[0] << 8);
 	struct hclge_dev *hdev = vport->back;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index aa73855..26bbc91 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -24,7 +24,7 @@
 #include "hnae3.h"
 #include "hns3_enet.h"
 
-const char hns3_driver_name[] = "hns3";
+static const char hns3_driver_name[] = "hns3";
 const char hns3_driver_version[] = VERMAGIC_STRING;
 static const char hns3_driver_string[] =
 			"Hisilicon Ethernet Network Driver for Hip08 Family";
@@ -304,18 +304,6 @@ static int hns3_nic_net_stop(struct net_device *netdev)
 	return 0;
 }
 
-void hns3_set_multicast_list(struct net_device *netdev)
-{
-	struct hnae3_handle *h = hns3_get_handle(netdev);
-	struct netdev_hw_addr *ha = NULL;
-
-	if (h->ae_algo->ops->set_mc_addr) {
-		netdev_for_each_mc_addr(ha, netdev)
-			if (h->ae_algo->ops->set_mc_addr(h, ha->addr))
-				netdev_err(netdev, "set multicast fail\n");
-	}
-}
-
 static int hns3_nic_uc_sync(struct net_device *netdev,
 			    const unsigned char *addr)
 {
@@ -360,7 +348,7 @@ static int hns3_nic_mc_unsync(struct net_device *netdev,
 	return 0;
 }
 
-void hns3_nic_set_rx_mode(struct net_device *netdev)
+static void hns3_nic_set_rx_mode(struct net_device *netdev)
 {
 	struct hnae3_handle *h = hns3_get_handle(netdev);
 
@@ -2596,7 +2584,7 @@ static void hns3_fini_ring(struct hns3_enet_ring *ring)
 	ring->next_to_use = 0;
 }
 
-int hns3_buf_size2type(u32 buf_size)
+static int hns3_buf_size2type(u32 buf_size)
 {
 	int bd_size_type;
 
@@ -2908,7 +2896,7 @@ static int hns3_client_setup_tc(struct hnae3_handle *handle, u8 tc)
 	return ret;
 }
 
-const struct hnae3_client_ops client_ops = {
+static const struct hnae3_client_ops client_ops = {
 	.init_instance = hns3_client_init,
 	.uninit_instance = hns3_client_uninit,
 	.link_status_change = hns3_link_status_change,
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index a892a15..060bace 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -215,8 +215,8 @@ static u64 *hns3_get_stats_tqps(struct hnae3_handle *handle, u64 *data)
  * @stats: statistics info.
  * @data: statistics data.
  */
-void hns3_get_stats(struct net_device *netdev, struct ethtool_stats *stats,
-		    u64 *data)
+static void hns3_get_stats(struct net_device *netdev,
+			   struct ethtool_stats *stats, u64 *data)
 {
 	struct hnae3_handle *h = hns3_get_handle(netdev);
 	u64 *p = data;
-- 
1.9.1
