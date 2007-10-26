From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] pcnet: fix sparse triviality
Date: Fri, 26 Oct 2007 15:11:32 -0700
Message-ID: <20071026221132.1913.24518.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65454 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753618AbXJZWLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 18:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since data can never exceed u32, it can't even be larger than LONG_MAX/HZ.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: pcnet32@verizon.net
---

 drivers/net/pcnet32.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index ff92aca..3573e77 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1101,9 +1101,8 @@ static int pcnet32_phys_id(struct net_device *dev, u32 data)
 	mod_timer(&lp->blink_timer, jiffies);
 	set_current_state(TASK_INTERRUPTIBLE);
 
-	/* AV: the limit here makes no sense whatsoever */
-	if ((!data) || (data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ)))
-		data = (u32) (MAX_SCHEDULE_TIMEOUT / HZ);
+	if (!data)
+		data = INT_MAX;
 
 	msleep_interruptible(data * 1000);
 	del_timer_sync(&lp->blink_timer);
