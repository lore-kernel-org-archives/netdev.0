From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/7] qlcnic: Remove casts of pointer to same type
Date: Mon, 24 Mar 2014 13:15:37 -0700
Message-ID: <ac82455e9d2f0487a3f96c44a41b5557fd09af95.1395692043.git.joe@perches.com>
References: <cover.1395692043.git.joe@perches.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index ec399b7..2d91975 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1388,7 +1388,7 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 	addr = (u64)dest;
 
 	ret = qlcnic_83xx_ms_mem_write128(adapter, addr,
-					  (u32 *)p_cache, size / 16);
+					  p_cache, size / 16);
 	if (ret) {
 		dev_err(&adapter->pdev->dev, "MS memory write failed\n");
 		release_firmware(fw);
-- 
1.8.1.2.459.gbcd45b4.dirty
