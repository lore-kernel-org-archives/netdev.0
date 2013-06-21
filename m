From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Do not sleep while holding spinlock
Date: Fri, 21 Jun 2013 12:09:42 -0400
Message-ID: <1371830982-18172-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe002.messaging.microsoft.com ([216.32.180.185]:37122
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423180Ab3FUQgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 12:36:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch reverts commit a4791254b6625b06aa33e36304f6e8a1a4a1fdea
("qlcnic: change mdelay to msleep") which overwrote a commit
68b3f28c11bf896be32ad2a2e151aaa5f4a7c98e
("qlcnic: Fix scheduling while atomic bug")

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 43562c2..6acf82b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -642,7 +642,7 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 				qlcnic_83xx_config_intrpt(adapter, 0);
 		}
 		/* Allow dma queues to drain after context reset */
-		msleep(20);
+		mdelay(20);
 	}
 }
 
-- 
1.7.1
