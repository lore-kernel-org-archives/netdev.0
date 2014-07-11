From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: set EQ DB clear-intr bit in be_open()
Date: Fri, 11 Jul 2014 14:03:01 +0530
Message-ID: <1405067581-31955-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:39210 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaGKIah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 04:30:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

On BE3, if the clear-interrupt bit of the EQ doorbell is not set the first
time it is armed, ocassionally we have observed that the EQ doesn't raise
anymore interrupts even if it is in armed state.
This patch fixes this by setting the clear-interrupt bit when EQs are
armed for the first time in be_open().

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---

David, could you pls queue this patch for the -stable tree. Thks.

 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 34a26e4..1e187fb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2902,7 +2902,7 @@ static int be_open(struct net_device *netdev)
 	for_all_evt_queues(adapter, eqo, i) {
 		napi_enable(&eqo->napi);
 		be_enable_busy_poll(eqo);
-		be_eq_notify(adapter, eqo->q.id, true, false, 0);
+		be_eq_notify(adapter, eqo->q.id, true, true, 0);
 	}
 	adapter->flags |= BE_FLAGS_NAPI_ENABLED;
 
-- 
1.7.1
