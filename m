From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: bna: use correct type specifications
Date: Sun, 31 Jul 2016 10:53:14 +0200
Message-ID: <1469955194-30017-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:52074 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988AbcGaIx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 04:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addr and len are read with
sscanf(kern_buf, "%x:%x", &addr, &len);
and used as arguments for
bna_reg_offset_check.

So they have to be unsigned.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index 8fc246e..cfcb00c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -312,7 +312,8 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 	struct bnad_debug_info *regrd_debug = file->private_data;
 	struct bnad *bnad = (struct bnad *)regrd_debug->i_private;
 	struct bfa_ioc *ioc = &bnad->bna.ioceth.ioc;
-	int addr, len, rc, i;
+	int rc, i;
+	u32 addr, len;
 	u32 *regbuf;
 	void __iomem *rb, *reg_addr;
 	unsigned long flags;
-- 
2.8.1
