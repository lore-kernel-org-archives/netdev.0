From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qlge: Fix schedule while atomic issue.
Date: Fri,  9 Jan 2009 13:31:52 -0800
Message-ID: <1231536713-24538-4-git-send-email-ron.mercer@qlogic.com>
References: <20090109213045.GD10803@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58231 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755638AbZAIVcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:05 -0500
In-Reply-To: <20090109213045.GD10803@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to sleep while waiting for the hardware
semaphore to become available.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e5a6238..e289423 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -126,12 +126,12 @@ static int ql_sem_trylock(struct ql_adapter *qdev, u32 sem_mask)
 
 int ql_sem_spinlock(struct ql_adapter *qdev, u32 sem_mask)
 {
-	unsigned int seconds = 3;
+	unsigned int wait_count = 30;
 	do {
 		if (!ql_sem_trylock(qdev, sem_mask))
 			return 0;
-		ssleep(1);
-	} while (--seconds);
+		udelay(100);
+	} while (--wait_count);
 	return -ETIMEDOUT;
 }
 
-- 
1.6.0

