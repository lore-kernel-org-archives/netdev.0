From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v2 net 1/5] net:ethernet:aquantia: Remove adapter re-opening when mtu changed.
Date: Thu, 23 Mar 2017 00:19:21 +0300
Message-ID: <c400d112d015b78fad1b7f8b0d411075a10d5209.1490217414.git.pavel.belous@aquantia.com>
References: <cover.1490217414.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:28576
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752563AbdCVVTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 17:19:55 -0400
In-Reply-To: <cover.1490217414.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Closing/opening the adapter is not needed at all.
The new mtu settings take effect immediately.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index d05fbfd..5d6c40d 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -100,11 +100,6 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
 		goto err_exit;
 	ndev->mtu = new_mtu;
 
-	if (netif_running(ndev)) {
-		aq_ndev_close(ndev);
-		aq_ndev_open(ndev);
-	}
-
 err_exit:
 	return err;
 }
-- 
2.7.4
