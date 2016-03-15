From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Prevent false warning for lack of FC NPIV
Date: Tue, 15 Mar 2016 19:52:04 +0200
Message-ID: <1458064324-16487-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <linux-scsi@vger.kernel.org>,
	<andrew.patterson@hpe.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all adapters have FC-NPIV configured. If bnx2fc is used with such an
adapter, driver would read irrelevant data from the the nvram and log
"FC-NPIV table with bad length..." In system logs.

Simply accept that reading '0' as the feature offset in nvram indicates
the feature isn't there and return.

Reported-by: Andrew Patterson <andrew.patterson@hpe.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2bf9c87..32652ad 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -14814,6 +14814,10 @@ static int bnx2x_get_fc_npiv(struct net_device *dev,
 	}
 
 	offset = SHMEM2_RD(bp, fc_npiv_nvram_tbl_addr[BP_PORT(bp)]);
+	if (!offset) {
+		DP(BNX2X_MSG_MCP, "No FC-NPIV in NVRAM\n");
+		goto out;
+	}
 	DP(BNX2X_MSG_MCP, "Offset of FC-NPIV in NVRAM: %08x\n", offset);
 
 	/* Read the table contents from nvram */
-- 
1.9.3

