From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netxen: fix incorrect loop counter decrement
Date: Fri, 18 Aug 2017 14:12:06 +0100
Message-ID: <20170818131206.15417-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Manish Chopra <manish.chopra@cavium.com>,
        Rahul Verma <rahul.verma@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The loop counter k is currently being decremented from zero which
is incorrect. Fix this by incrementing k instead

Detected by CoverityScan, CID#401847 ("Infinite loop")

Fixes: 83f18a557c6d ("netxen_nic: fw dump support")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 66ff15d08bad..0a66389c06c2 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -2311,7 +2311,7 @@ netxen_md_rdqueue(struct netxen_adapter *adapter,
 				 loop_cnt++) {
 		NX_WR_DUMP_REG(select_addr, adapter->ahw.pci_base0, queue_id);
 		read_addr = queueEntry->read_addr;
-		for (k = 0; k < read_cnt; k--) {
+		for (k = 0; k < read_cnt; k++) {
 			NX_RD_DUMP_REG(read_addr, adapter->ahw.pci_base0,
 							&read_value);
 			*data_buff++ = read_value;
-- 
2.11.0
