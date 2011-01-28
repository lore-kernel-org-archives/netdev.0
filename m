From: Stefan Weil <weil@mail.berlios.de>
Subject: [PATCH] vxge: Fix wrong boolean operator
Date: Fri, 28 Jan 2011 23:30:17 +0100
Message-ID: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
Cc: Stefan Weil <weil@mail.berlios.de>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jon.mason@exar.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This error is reported by cppcheck:
drivers/net/vxge/vxge-config.c:3693: warning: Mutual exclusion over || always evaluates to true. Did you intend to use && instead?

It looks like cppcheck is correct, so fix this. No test was run.

Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
Cc: Sivakumar Subramani <sivakumar.subramani@exar.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Cc: Jon Mason <jon.mason@exar.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Stefan Weil <weil@mail.berlios.de>
---
 drivers/net/vxge/vxge-config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 01c05f5..228d4f7 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -3690,7 +3690,7 @@ __vxge_hw_vpath_rts_table_get(struct __vxge_hw_vpath_handle *vp,
 	if (status != VXGE_HW_OK)
 		goto exit;
 
-	if ((rts_table != VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) ||
+	if ((rts_table != VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) &&
 	    (rts_table !=
 	     VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT))
 		*data1 = 0;
-- 
1.7.2.3
