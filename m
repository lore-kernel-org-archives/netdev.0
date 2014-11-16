From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/14] amd-xgbe: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:06 -0800
Message-ID: <1416147798-16561-3-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:37883 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbaKPOXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:41 -0500
Received: by mail-vc0-f202.google.com with SMTP id hq12so452922vcb.3
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:40 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_rss_key_fill() helper, as it provides better support for some
bonding setups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Lendacky, Thomas <Thomas.Lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 05fbdf96e77e..dbd3850b8b0a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -338,7 +338,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	}
 
 	/* Initialize RSS hash key and lookup table */
-	get_random_bytes(pdata->rss_key, sizeof(pdata->rss_key));
+	netdev_rss_key_fill(pdata->rss_key, sizeof(pdata->rss_key));
 
 	for (i = 0; i < XGBE_RSS_MAX_TABLE_SIZE; i++)
 		XGMAC_SET_BITS(pdata->rss_table[i], MAC_RSSDR, DMCH,
-- 
2.1.0.rc2.206.gedb03e5
