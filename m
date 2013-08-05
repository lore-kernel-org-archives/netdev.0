From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/4] be2net: Staticize local functions
Date: Mon, 05 Aug 2013 18:02:02 +0900
Message-ID: <002201ce91ba$7335bfd0$59a13f70$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Sathya Perla' <sathya.perla@emulex.com>,
	'Subbu Seetharaman' <subbu.seetharaman@emulex.com>,
	'Ajit Khaparde' <ajit.khaparde@emulex.com>,
	Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:13872 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab3HEJCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 05:02:06 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR1001IWVRD4JM0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 05 Aug 2013 18:02:02 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These local functions are used only in this file.
Fix the following sparse warnings:

drivers/net/ethernet/emulex/benet/be_main.c:475:6: warning: symbol 'populate_erx_stats' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_main.c:1485:6: warning: symbol 'be_rx_compl_process_gro' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_main.c:2262:5: warning: symbol 'be_poll' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_main.c:3223:6: warning: symbol 'flash_cookie' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_main.c:3280:27: warning: symbol 'get_fsec_info' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_cmds.c:1013:5: warning: symbol 'be_cmd_mccq_ext_create' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_cmds.c:1071:5: warning: symbol 'be_cmd_mccq_org_create' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_cmds.c:3166:5: warning: symbol 'be_cmd_get_profile_config_mbox' was not declared. Should it be
static?
drivers/net/ethernet/emulex/benet/be_cmds.c:3194:5: warning: symbol 'be_cmd_get_profile_config_mccq' was not declared. Should it be
static?
drivers/net/ethernet/emulex/benet/be_roce.c:96:6: warning: symbol '_be_roce_dev_remove' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_roce.c:113:6: warning: symbol '_be_roce_dev_open' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_roce.c:129:6: warning: symbol '_be_roce_dev_close' was not declared. Should it be static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   20 ++++++++++----------
 drivers/net/ethernet/emulex/benet/be_main.c |   13 +++++++------
 drivers/net/ethernet/emulex/benet/be_roce.c |    6 +++---
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 613d887..2bd2d1e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1010,9 +1010,9 @@ static u32 be_encoded_q_len(int q_len)
 	return len_encoded;
 }
 
-int be_cmd_mccq_ext_create(struct be_adapter *adapter,
-			struct be_queue_info *mccq,
-			struct be_queue_info *cq)
+static int be_cmd_mccq_ext_create(struct be_adapter *adapter,
+				struct be_queue_info *mccq,
+				struct be_queue_info *cq)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_mcc_ext_create *req;
@@ -1068,9 +1068,9 @@ int be_cmd_mccq_ext_create(struct be_adapter *adapter,
 	return status;
 }
 
-int be_cmd_mccq_org_create(struct be_adapter *adapter,
-			struct be_queue_info *mccq,
-			struct be_queue_info *cq)
+static int be_cmd_mccq_org_create(struct be_adapter *adapter,
+				struct be_queue_info *mccq,
+				struct be_queue_info *cq)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_mcc_create *req;
@@ -3163,8 +3163,8 @@ err:
 }
 
 /* Uses mbox */
-int be_cmd_get_profile_config_mbox(struct be_adapter *adapter,
-				   u8 domain, struct be_dma_mem *cmd)
+static int be_cmd_get_profile_config_mbox(struct be_adapter *adapter,
+					u8 domain, struct be_dma_mem *cmd)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_profile_config *req;
@@ -3191,8 +3191,8 @@ int be_cmd_get_profile_config_mbox(struct be_adapter *adapter,
 }
 
 /* Uses sync mcc */
-int be_cmd_get_profile_config_mccq(struct be_adapter *adapter,
-				   u8 domain, struct be_dma_mem *cmd)
+static int be_cmd_get_profile_config_mccq(struct be_adapter *adapter,
+					u8 domain, struct be_dma_mem *cmd)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_profile_config *req;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3df1503..4c40e3e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -472,7 +472,7 @@ static void accumulate_16bit_val(u32 *acc, u16 val)
 	ACCESS_ONCE(*acc) = newacc;
 }
 
-void populate_erx_stats(struct be_adapter *adapter,
+static void populate_erx_stats(struct be_adapter *adapter,
 			struct be_rx_obj *rxo,
 			u32 erx_stat)
 {
@@ -1482,8 +1482,9 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
-void be_rx_compl_process_gro(struct be_rx_obj *rxo, struct napi_struct *napi,
-			     struct be_rx_compl_info *rxcp)
+static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
+				    struct napi_struct *napi,
+				    struct be_rx_compl_info *rxcp)
 {
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_rx_page_info *page_info;
@@ -2259,7 +2260,7 @@ static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 	return (work_done < budget); /* Done */
 }
 
-int be_poll(struct napi_struct *napi, int budget)
+static int be_poll(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
 	struct be_adapter *adapter = eqo->adapter;
@@ -3220,7 +3221,7 @@ static void be_netpoll(struct net_device *netdev)
 #endif
 
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
-char flash_cookie[2][16] =      {"*** SE FLAS", "H DIRECTORY *** "};
+static char flash_cookie[2][16] =      {"*** SE FLAS", "H DIRECTORY *** "};
 
 static bool be_flash_redboot(struct be_adapter *adapter,
 			const u8 *p, u32 img_start, int image_size,
@@ -3277,7 +3278,7 @@ static bool is_comp_in_ufi(struct be_adapter *adapter,
 
 }
 
-struct flash_section_info *get_fsec_info(struct be_adapter *adapter,
+static struct flash_section_info *get_fsec_info(struct be_adapter *adapter,
 					 int header_size,
 					 const struct firmware *fw)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
index f3d126d..645e846 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.c
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -93,7 +93,7 @@ void be_roce_dev_add(struct be_adapter *adapter)
 	}
 }
 
-void _be_roce_dev_remove(struct be_adapter *adapter)
+static void _be_roce_dev_remove(struct be_adapter *adapter)
 {
 	if (ocrdma_drv && ocrdma_drv->remove && adapter->ocrdma_dev)
 		ocrdma_drv->remove(adapter->ocrdma_dev);
@@ -110,7 +110,7 @@ void be_roce_dev_remove(struct be_adapter *adapter)
 	}
 }
 
-void _be_roce_dev_open(struct be_adapter *adapter)
+static void _be_roce_dev_open(struct be_adapter *adapter)
 {
 	if (ocrdma_drv && adapter->ocrdma_dev &&
 	    ocrdma_drv->state_change_handler)
@@ -126,7 +126,7 @@ void be_roce_dev_open(struct be_adapter *adapter)
 	}
 }
 
-void _be_roce_dev_close(struct be_adapter *adapter)
+static void _be_roce_dev_close(struct be_adapter *adapter)
 {
 	if (ocrdma_drv && adapter->ocrdma_dev &&
 	    ocrdma_drv->state_change_handler)
-- 
1.7.10.4
