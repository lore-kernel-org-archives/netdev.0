From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] netxen_nic: Remove unused pointer hdr in netxen_setup_minidump()
Date: Sun,  2 Jul 2017 23:16:11 +0100
Message-ID: <1499033771-24820-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Manish Chopra <manish.chopra@cavium.com>,
        Rahul Verma <rahul.verma@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pointer hdr in netxen_setup_minidump() is set but never used, thus
should be removed.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index e306765..6cec2a6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -174,7 +174,6 @@ netxen_setup_minidump(struct netxen_adapter *adapter)
 {
 	int err = 0, i;
 	u32 *template, *tmp_buf;
-	struct netxen_minidump_template_hdr *hdr;
 	err = netxen_get_minidump_template_size(adapter);
 	if (err) {
 		adapter->mdump.fw_supports_md = 0;
@@ -218,8 +217,6 @@ netxen_setup_minidump(struct netxen_adapter *adapter)
 	template = (u32 *) adapter->mdump.md_template;
 	for (i = 0; i < adapter->mdump.md_template_size/sizeof(u32); i++)
 		*template++ = __le32_to_cpu(*tmp_buf++);
-	hdr = (struct netxen_minidump_template_hdr *)
-				adapter->mdump.md_template;
 	adapter->mdump.md_capture_buff = NULL;
 	adapter->mdump.fw_supports_md = 1;
 	adapter->mdump.md_enabled = 0;
-- 
2.7.4
