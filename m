From: Colin King <colin.king@canonical.com>
Subject: [PATCH] qlcnic: remove redundant zero check on retries counter
Date: Fri,  1 Sep 2017 14:44:31 +0100
Message-ID: <20170901134431.23179-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

At the end of the do while loop the integer counter retries will
always be zero and so the subsequent check to see if it is zero
is always true and therefore redundant.  Remove the redundant check
and always return -EIO on this return path.  Also unbreak the literal
string in dev_err message to clean up a checkpatch warning.

Detected by CoverityScan, CID#744279 ("Logically dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index be41e4c77b65..c48a0e2d4d7e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -592,13 +592,9 @@ qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
 
 	} while (--retries);
 
-	if (!retries) {
-		dev_err(&adapter->pdev->dev, "Receive Peg initialization not "
-			      "complete, state: 0x%x.\n", val);
-		return -EIO;
-	}
-
-	return 0;
+	dev_err(&adapter->pdev->dev, "Receive Peg initialization not complete, state: 0x%x.\n",
+		val);
+	return -EIO;
 }
 
 int
-- 
2.14.1
