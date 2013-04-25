From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net 2/2] be2net: Fix to show wol disabled/enabled state correctly.
Date: Thu, 25 Apr 2013 16:26:56 +0530
Message-ID: <197de4df-d32f-410d-9d5c-f4beec269ce8@CMEXHTCAS1.ad.emulex.com>
References: <1366887416-1338-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:8256 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926Ab3DYKzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:55:12 -0400
In-Reply-To: <1366887416-1338-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 76b302f..1b7233c 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -680,7 +680,8 @@ be_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 
 	if (be_is_wol_supported(adapter)) {
 		wol->supported |= WAKE_MAGIC;
-		wol->wolopts |= WAKE_MAGIC;
+		if (adapter->wol)
+			wol->wolopts |= WAKE_MAGIC;
 	} else
 		wol->wolopts = 0;
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
-- 
1.7.9.5
