From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH] atl1c: restore buffer state
Date: Wed, 20 Feb 2013 01:23:09 +0800
Message-ID: <1361294589-7316-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<qca-linux-team@qca.qualcomm.com>, <nic-devel@qca.qualcomm.com>,
	<jwboyer@redhat.com>, xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in the previous commit : f1f220ea1dda078, the BUSY state of buffer is wrongly
deleted. this patch just restore it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8f33315..1f07fc6 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2072,7 +2072,7 @@ static int atl1c_tx_map(struct atl1c_adapter *adapter,
 		if (unlikely(pci_dma_mapping_error(adapter->pdev,
 						   buffer_info->dma)))
 			goto err_dma;
-
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
 			ATL1C_PCIMAP_TODEVICE);
 		mapped_len += map_len;
-- 
1.7.11.7
