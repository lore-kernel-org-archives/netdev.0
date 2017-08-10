From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] forcedeth: replace init_timer_deferrable with setup_deferrable_timer
Date: Thu, 10 Aug 2017 04:13:12 -0400
Message-ID: <1502352792-6930-1-git-send-email-yanjun.zhu@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43863 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdHJILS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 04:11:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace init_timer_deferrable with setup_deferrable_timer to simplify
the source code.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index aa912f4..bdbfe8f 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5629,9 +5629,8 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 
 	setup_timer(&np->oom_kick, nv_do_rx_refill, (unsigned long)dev);
 	setup_timer(&np->nic_poll, nv_do_nic_poll, (unsigned long)dev);
-	init_timer_deferrable(&np->stats_poll);
-	np->stats_poll.data = (unsigned long) dev;
-	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
+	setup_deferrable_timer(&np->stats_poll, nv_do_stats_poll,
+			       (unsigned long)dev);
 
 	err = pci_enable_device(pci_dev);
 	if (err)
-- 
2.7.4
