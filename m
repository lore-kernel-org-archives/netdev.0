From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v3 net 1/5] net:ethernet:aquantia: Remove adapter re-opening when MTU changed.
Date: Thu, 23 Mar 2017 14:19:41 +0300
Message-ID: <4d8358ad9533acf78f7c590e2dfcea7890fdbd2a.1490267633.git.pavel.belous@aquantia.com>
References: <cover.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0079.outbound.protection.outlook.com ([104.47.37.79]:2176
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754636AbdCWLUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 07:20:17 -0400
In-Reply-To: <cover.1490267633.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Closing/opening the adapter is not needed at all.
The new MTU settings take effect immediately.

Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")

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
