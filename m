From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netxen_nic: remove redundant check if retries is zero
Date: Wed, 15 Mar 2017 15:31:58 +0000
Message-ID: <20170315153158.16122-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Manish Chopra <manish.chopra@cavium.com>,
        Rahul Verma <rahul.verma@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

At the end of the timeout loop, retries will always be zero so
the check for zero is redundant so remove it.  Also replace
printk with pr_err as recommended by checkpatch.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 7b43a3b..3dd9734 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1375,13 +1375,8 @@ netxen_receive_peg_ready(struct netxen_adapter *adapter)
 
 	} while (--retries);
 
-	if (!retries) {
-		printk(KERN_ERR "Receive Peg initialization not "
-			      "complete, state: 0x%x.\n", val);
-		return -EIO;
-	}
-
-	return 0;
+	pr_err("Receive Peg initialization not complete, state: 0x%x.\n", val);
+	return -EIO;
 }
 
 int netxen_init_firmware(struct netxen_adapter *adapter)
-- 
2.10.2
