From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 3/6] fjes: fix bitwise check bug in fjes_raise_intr_rxdata_task
Date: Fri, 15 Apr 2016 11:25:34 +0900
Message-ID: <1460687134-26665-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:44389 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbcDOCeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:34:06 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 6BD52AC02F7
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:33:58 +0900 (JST)
In-Reply-To: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
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
index 05bdd8b..e22a869 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -549,7 +549,8 @@ static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 		if ((hw->ep_shm_info[epid].tx_status_work ==
 		     FJES_TX_DELAY_SEND_PENDING) &&
 		    (pstatus == EP_PARTNER_SHARED) &&
-		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status &
+		      FJES_RX_POLL_WORK)) {
 			fjes_hw_raise_interrupt(hw, epid,
 						REG_ICTL_MASK_RX_DATA);
 		}
-- 
2.4.3
