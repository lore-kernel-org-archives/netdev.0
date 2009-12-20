From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] bnx2: Fix bnx2_netif_stop() merge error.
Date: Sun, 20 Dec 2009 10:30:47 -0800
Message-ID: <1261333847-15334-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4779 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbZLTSXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2009 13:23:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error was introduced while merging:

commit 4529819c45161e4a119134f56ef504e69420bc98
bnx2: reset_task is crashing the kernel. Fixing it.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f38764e..65df1de 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -666,6 +666,7 @@ bnx2_netif_stop(struct bnx2 *bp)
 			txq->trans_start = jiffies;
 		}
 	}
+	bnx2_disable_int_sync(bp);
 }
 
 static void
@@ -679,7 +680,6 @@ bnx2_netif_start(struct bnx2 *bp)
 			bnx2_cnic_start(bp);
 		}
 	}
-	bnx2_disable_int_sync(bp);
 }
 
 static void
-- 
1.6.4.GIT


