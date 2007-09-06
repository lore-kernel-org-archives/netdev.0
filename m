From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e100: timer power saving
Date: Thu, 06 Sep 2007 11:51:37 -0700
Message-ID: <20070906185137.30733.99594.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	arjan@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10026 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757231AbXIFSvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 14:51:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Since E100 timer is 2HZ, use rounding to make timer occur on the
correct boundary.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 280313b..d7b9437 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1604,7 +1604,8 @@ static void e100_watchdog(unsigned long data)
 	else
 		nic->flags &= ~ich_10h_workaround;
 
-	mod_timer(&nic->watchdog, jiffies + E100_WATCHDOG_PERIOD);
+	mod_timer(&nic->watchdog,
+		  round_jiffies(jiffies + E100_WATCHDOG_PERIOD));
 }
 
 static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
