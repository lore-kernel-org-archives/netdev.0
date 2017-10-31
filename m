From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: thunderx: remove a couple of redundant assignments
Date: Tue, 31 Oct 2017 14:37:55 +0000
Message-ID: <20171031143755.26021-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The assignment to pointer msg is redundant as it is never read, so
remove msg.  Also remove the first assignment to qset as this is not
read before the next re-assignment of a new value to qset in the
for-loop. Cleans up two clang warnings:

drivers/net/ethernet/cavium/thunder/nic_main.c:589:2: warning: Value
stored to 'msg' is never read
drivers/net/ethernet/cavium/thunder/nic_main.c:611:2: warning: Value
stored to 'qset' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index fb770b0182d3..988c06a28e5e 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -584,9 +584,6 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 static void nic_send_rss_size(struct nicpf *nic, int vf)
 {
 	union nic_mbx mbx = {};
-	u64  *msg;
-
-	msg = (u64 *)&mbx;
 
 	mbx.rss_size.msg = NIC_MBOX_MSG_RSS_SIZE;
 	mbx.rss_size.ind_tbl_size = nic->hw->rss_ind_tbl_size;
@@ -608,7 +605,6 @@ static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg)
 	rssi_base = nic->rssi_base[cfg->vf_id] + cfg->tbl_offset;
 
 	rssi = rssi_base;
-	qset = cfg->vf_id;
 
 	for (; rssi < (rssi_base + cfg->tbl_len); rssi++) {
 		u8 svf = cfg->ind_tbl[idx] >> 3;
-- 
2.14.1
