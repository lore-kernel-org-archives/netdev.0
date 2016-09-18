From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] be2net: mark symbols static where possible
Date: Sun, 18 Sep 2016 16:35:29 +0800
Message-ID: <1474187729-25326-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 4 warnings when building kernel with W=1:
drivers/net/ethernet/emulex/benet/be_main.c:4368:6: warning: no previous prototype for 'be_calculate_pf_pool_rss_tables' [-Wmissing-prototypes]
drivers/net/ethernet/emulex/benet/be_cmds.c:4385:5: warning: no previous prototype for 'be_get_nic_pf_num_list' [-Wmissing-prototypes]
drivers/net/ethernet/emulex/benet/be_cmds.c:4537:6: warning: no previous prototype for 'be_reset_nic_desc' [-Wmissing-prototypes]
drivers/net/ethernet/emulex/benet/be_cmds.c:4910:5: warning: no previous prototype for '__be_cmd_set_logical_link_config' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 9 +++++----
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 15d02da..9cffe48 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4382,7 +4382,7 @@ err:
 }
 
 /* This routine returns a list of all the NIC PF_nums in the adapter */
-u16 be_get_nic_pf_num_list(u8 *buf, u32 desc_count, u16 *nic_pf_nums)
+static u16 be_get_nic_pf_num_list(u8 *buf, u32 desc_count, u16 *nic_pf_nums)
 {
 	struct be_res_desc_hdr *hdr = (struct be_res_desc_hdr *)buf;
 	struct be_pcie_res_desc *pcie = NULL;
@@ -4534,7 +4534,7 @@ static int be_cmd_set_profile_config(struct be_adapter *adapter, void *desc,
 }
 
 /* Mark all fields invalid */
-void be_reset_nic_desc(struct be_nic_res_desc *nic)
+static void be_reset_nic_desc(struct be_nic_res_desc *nic)
 {
 	memset(nic, 0, sizeof(*nic));
 	nic->unicast_mac_count = 0xFFFF;
@@ -4907,8 +4907,9 @@ err:
 	return status;
 }
 
-int __be_cmd_set_logical_link_config(struct be_adapter *adapter,
-				     int link_state, int version, u8 domain)
+static int
+__be_cmd_set_logical_link_config(struct be_adapter *adapter,
+				 int link_state, int version, u8 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_ll_link *req;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 34f63ef..9a94840 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4365,7 +4365,7 @@ static void be_setup_init(struct be_adapter *adapter)
  * for distribution between the VFs. This self-imposed limit will determine the
  * no: of VFs for which RSS can be enabled.
  */
-void be_calculate_pf_pool_rss_tables(struct be_adapter *adapter)
+static void be_calculate_pf_pool_rss_tables(struct be_adapter *adapter)
 {
 	struct be_port_resources port_res = {0};
 	u8 rss_tables_on_port;
-- 
2.7.4
