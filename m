From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next] fjes: Fix unnecessary spinlock_irqsave
Date: Tue, 10 May 2016 10:28:49 +0900
Message-ID: <1462843729-32414-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:18970 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbcEJBiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 21:38:08 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 8E291AC0144
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 10:38:00 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit-bd5a256 introduces a deadlock bug in fjes_change_mtu().
This spin_lock_irqsave() is obviously unnecessary.

This patch eliminates unnecessary spin_lock_irqsave() in
fjes_change_mtu()

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index f4e6926..86c331b 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -819,7 +819,6 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if (running) {
-		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		for (epidx = 0; epidx < hw->max_epid; epidx++) {
 			if (epidx == hw->my_epid)
 				continue;
-- 
1.9.1
