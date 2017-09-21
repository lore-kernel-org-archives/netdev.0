From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 44/64] drivers: net: pxa168: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:05 +0530
Message-ID: <1506013525-29291-45-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33335 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752536AbdIURKV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:10:21 -0400
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 9937249..91b1c15 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1496,9 +1496,8 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	netif_napi_add(dev, &pep->napi, pxa168_rx_poll, pep->rx_ring_size);
 
 	memset(&pep->timeout, 0, sizeof(struct timer_list));
-	init_timer(&pep->timeout);
-	pep->timeout.function = rxq_refill_timer_wrapper;
-	pep->timeout.data = (unsigned long)pep;
+	setup_timer(&pep->timeout, rxq_refill_timer_wrapper,
+		    (unsigned long)pep);
 
 	pep->smi_bus = mdiobus_alloc();
 	if (!pep->smi_bus) {
-- 
2.7.4
