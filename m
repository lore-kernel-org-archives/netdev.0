From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: bna: use correct type specifier (2)
Date: Sun, 31 Jul 2016 11:01:20 +0200
Message-ID: <1469955680-32432-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add and val are read with
sscanf(kern_buf, "%x:%x", &addr, &val);
and used as arguments for bna_reg_offset_check and writel
so they have to be unsigned.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index cfcb00c..05c1c1d 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -373,7 +373,8 @@ bnad_debugfs_write_regwr(struct file *file, const char __user *buf,
 	struct bnad_debug_info *debug = file->private_data;
 	struct bnad *bnad = (struct bnad *)debug->i_private;
 	struct bfa_ioc *ioc = &bnad->bna.ioceth.ioc;
-	int addr, val, rc;
+	int rc;
+	u32 addr, val;
 	void __iomem *reg_addr;
 	unsigned long flags;
 	void *kern_buf;
-- 
2.8.1
