From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH v2] lance: Return correct error code
Date: Wed, 17 Feb 2016 20:33:26 +0530
Message-ID: <20160217150326.GA3116@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Failure of kzalloc should cause the enclosing function
to return -ENOMEM, not -ENODEV.

Additionally, removed the following checkpatch warnings:
ERROR: spaces required around that '==' (ctx:VxV)
ERROR: space required before the open parenthesis '('
CHECK: Comparison to NULL could be written "!lp"

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
Changes in v2:
        -Modified commit message to properly describe the change.

 drivers/net/ethernet/amd/lance.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 256f590..3a7ebfd 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -547,8 +547,8 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
 
 	lp = kzalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
-	if(lp==NULL)
-		return -ENODEV;
+	if (!lp)
+		return -ENOMEM;
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
 	dev->ml_priv = lp;
 	lp->name = chipname;
-- 
1.9.1
