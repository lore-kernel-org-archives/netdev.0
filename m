From: Pan Bian <bianpan201604@163.com>
Subject: [PATCH 1/1] net: ethernet: broadcom: fix improper return value
Date: Sun,  4 Dec 2016 14:29:29 +0800
Message-ID: <1480832969-5888-1-git-send-email-bianpan201604@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

Marco BNX2X_ALLOC_AND_SET(arr, lbl, func) calls kmalloc() to allocate
memory, and jumps to label "lbl" if the allocation fails. Label "lbl"
first cleans memory and then returns variable rc. Before calling the
macro, the value of variable rc is 0. Because 0 means no error, the
callers of bnx2x_init_firmware() may be misled. This patch fixes the bug,
assigning "-ENOMEM" to rc before calling macro NX2X_ALLOC_AND_SET().

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189141

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0cee4c0..6f9fc20 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13505,6 +13505,7 @@ static int bnx2x_init_firmware(struct bnx2x *bp)
 
 	/* Initialize the pointers to the init arrays */
 	/* Blob */
+	rc = -ENOMEM;
 	BNX2X_ALLOC_AND_SET(init_data, request_firmware_exit, be32_to_cpu_n);
 
 	/* Opcodes */
-- 
1.9.1
