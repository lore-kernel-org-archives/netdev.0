From: David Arcari <darcari@redhat.com>
Subject: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu is changed
Date: Wed,  8 Mar 2017 16:33:21 -0500
Message-ID: <1489008801-120389-1-git-send-email-darcari@redhat.com>
Cc: David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40386 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752324AbdCHW1m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Mar 2017 17:27:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the aquantia device mtu is changed the net_device structure is not
updated.  As a result the ip command does not properly reflect the mtu change.

Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
has a ndo_change_mtu routine.

Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")

Cc: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David Arcari <darcari@redhat.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index dad6362..d05fbfd 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -98,6 +98,7 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
 
 	if (err < 0)
 		goto err_exit;
+	ndev->mtu = new_mtu;
 
 	if (netif_running(ndev)) {
 		aq_ndev_close(ndev);
-- 
1.8.3.1
