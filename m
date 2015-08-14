From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169.c: Force transmission when nic refuse to start.
Date: Fri, 14 Aug 2015 10:58:27 +0300
Message-ID: <1439539107-13638-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33268 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbbHNH6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 03:58:40 -0400
Received: by wijp15 with SMTP id p15so10999964wij.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 00:58:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brute force transmission when Rx interrupt exist on
 interface is up.  Guaranteed to start on full duplex and not maximum
 speed.When set  half duplex working same without this patch.
For apply this patch set --whitespace=warn

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index eb2d2a4..6882eab 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7470,15 +7470,22 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	u16 enable_mask = RTL_EVENT_NAPI | tp->event_slow;
 	int work_done= 0;
 	u16 status;
+        int tx_force = 1;
 
 	status = rtl_get_events(tp);
 	rtl_ack_events(tp, status & ~tp->event_slow);
-
+       if (netif_running(dev)) {
 	if (status & RTL_EVENT_NAPI_RX)
 		work_done = rtl_rx(dev, tp, (u32) budget);
+                
 
 	if (status & RTL_EVENT_NAPI_TX)
 		rtl_tx(dev, tp);
+         else if (tx_force == 1) {
+                mdelay(10);
+                rtl_tx(dev, tp);
+         }
+        }
 
 	if (status & tp->event_slow) {
 		enable_mask &= ~tp->event_slow;
-- 
2.1.4
