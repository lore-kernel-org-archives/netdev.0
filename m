From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 08/11] fjes: fix bitwise check bug in fjes_raise_intr_rxdata_task
Date: Mon, 11 Apr 2016 17:10:40 +0900
Message-ID: <1460362240-15337-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:19210 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbcDKITN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:19:13 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id BC03BAC02C6
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:56 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fjes_raise_intr_rxdata_task(), there's a bug of bitwise
check because of missing "& FJES_RX_POLL_WORK".
This patch fixes this bug.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index e785d89..8c7a8b0 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -560,7 +560,8 @@ static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 		if ((hw->ep_shm_info[epid].tx_status_work ==
 		     FJES_TX_DELAY_SEND_PENDING) &&
 		    (pstatus == EP_PARTNER_SHARED) &&
-		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status &
+		      FJES_RX_POLL_WORK)) {
 			fjes_hw_raise_interrupt(hw, epid,
 						REG_ICTL_MASK_RX_DATA);
 			hw->ep_shm_info[epid].ep_stats.send_interrupts_rx += 1;
-- 
2.4.3
