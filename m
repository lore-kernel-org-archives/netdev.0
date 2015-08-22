From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next]r8169:Disable interrupts.
Date: Sat, 22 Aug 2015 08:04:02 +0300
Message-ID: <1440219842-5462-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36429 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbbHVFEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 01:04:15 -0400
Received: by wicja10 with SMTP id ja10so29703609wic.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 22:04:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable interrupts when close the interface.


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6cd7226..ea461fe 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7548,6 +7548,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	/* Update counters before going down */
 	rtl8169_update_counters(dev);
+	rtl8169_irq_mask_and_ack(tp);
 
 	rtl_lock_work(tp);
 	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
-- 
2.1.4
