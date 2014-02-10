From: John Greene <jogreene@redhat.com>
Subject: [PATCH] alx: add missing stats_lock spinlock init
Date: Mon, 10 Feb 2014 14:34:04 -0500
Message-ID: <1392060844-30995-1-git-send-email-jogreene@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304AbaBJTeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 14:34:12 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1AJYBc8029038
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:34:12 -0500
Received: from jgpicker.redhat.com (vpn-48-104.rdu2.redhat.com [10.10.48.104])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s1AJYB90015345
	for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:34:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial fix for init time stack trace occuring in
alx_get_stats64 upon start up. Should have been part of
commit adding the spinlock:
f1b6b106 alx: add alx_get_stats64 operation

Signed-off-by: John Greene <jogreene@redhat.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index e92ffd6..2e45f6e 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1292,6 +1292,7 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	alx = netdev_priv(netdev);
 	spin_lock_init(&alx->hw.mdio_lock);
 	spin_lock_init(&alx->irq_lock);
+	spin_lock_init(&alx->stats_lock);
 	alx->dev = netdev;
 	alx->hw.pdev = pdev;
 	alx->msg_enable = NETIF_MSG_LINK | NETIF_MSG_HW | NETIF_MSG_IFUP |
-- 
1.8.1.4
