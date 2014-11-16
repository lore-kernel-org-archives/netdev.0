From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/14] sfc: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:17 -0800
Message-ID: <1416147798-16561-14-git-send-email-edumazet@google.com>
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
Received: from mail-ob0-f201.google.com ([209.85.214.201]:57147 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbaKPOYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:21 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so2677180obb.0
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:21 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_rss_key_fill() helper, as it provides better support for some
bonding setups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b49d04886d4f..238482495e81 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1616,7 +1616,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 		goto fail2;
 
 	if (efx->n_channels > 1)
-		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
+		netdev_rss_key_fill(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
 		efx->rx_indir_table[i] =
 			ethtool_rxfh_indir_default(i, efx->rss_spread);
-- 
2.1.0.rc2.206.gedb03e5
