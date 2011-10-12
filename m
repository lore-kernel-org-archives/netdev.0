From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-2.6] tg3: negate USE_PHYLIB flag check
Date: Wed, 12 Oct 2011 11:00:41 +0200
Message-ID: <1318410041-2476-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, mcarlson@broadcom.com,
	mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab1JLJAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 05:00:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

USE_PHYLIB flag in tg3_remove_one() is being checked incorrectly. This
results tg3_phy_fini->phy_disconnect is never called and when tg3 module
is removed.

In my case this resulted in panics in phy_state_machine calling function
phydev->adjust_link.

So correct this check.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4a1374d..c11a2b8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15577,7 +15577,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 
 		cancel_work_sync(&tp->reset_task);
 
-		if (!tg3_flag(tp, USE_PHYLIB)) {
+		if (tg3_flag(tp, USE_PHYLIB)) {
 			tg3_phy_fini(tp);
 			tg3_mdio_fini(tp);
 		}
-- 
1.7.6.2
