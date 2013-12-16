From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 5/8] qlcnic: Fix memory allocation
Date: Mon, 16 Dec 2013 15:37:00 -0500
Message-ID: <b852f779f8cc7320d8f2010673bce729217e5b3f.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1457 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752053Ab3LPVJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:52 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Use vzalloc() instead of kzalloc() for allocation of
  bootloader size memory. kzalloc() may fail to allocate
  the size of bootloader

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index fae1b71..cac0503 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1254,24 +1254,24 @@ static int qlcnic_83xx_copy_bootloader(struct qlcnic_adapter *adapter)
 	if (size & 0xF)
 		size = (size + 16) & ~0xF;
 
-	p_cache = kzalloc(size, GFP_KERNEL);
+	p_cache = vzalloc(size);
 	if (p_cache == NULL)
 		return -ENOMEM;
 
 	ret = qlcnic_83xx_lockless_flash_read32(adapter, src, p_cache,
 						size / sizeof(u32));
 	if (ret) {
-		kfree(p_cache);
+		vfree(p_cache);
 		return ret;
 	}
 	/* 16 byte write to MS memory */
 	ret = qlcnic_83xx_ms_mem_write128(adapter, dest, (u32 *)p_cache,
 					  size / 16);
 	if (ret) {
-		kfree(p_cache);
+		vfree(p_cache);
 		return ret;
 	}
-	kfree(p_cache);
+	vfree(p_cache);
 
 	return ret;
 }
-- 
1.8.1.4
