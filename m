From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] phylib: Wake PHY state machine on interrupt
Date: Wed, 24 Sep 2008 17:02:11 -0700
Message-ID: <1222300931-21242-1-git-send-email-tpiepho@freescale.com>
Cc: afleming@freescale.com, Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:42957 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYIYAFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 20:05:01 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m8P04wFp014018
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 17:04:59 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way the phy layer will respond to a change in phy state immediately,
instead of up to one second later when the state machine timer runs.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/phy.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 45cc291..b9572d8 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -728,6 +728,11 @@ static void phy_change(struct work_struct *work)
 	if (err)
 		goto irq_enable_err;
 
+	/* Stop timer and run the state queue now.  The work function for
+	 * state_queue will start the timer up again.  */
+	del_timer(&phydev->phy_timer);
+	schedule_work(&phydev->state_queue);
+
 	return;
 
 irq_enable_err:
-- 
1.5.4.1

