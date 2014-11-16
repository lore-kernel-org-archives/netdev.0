From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/14] bna: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:09 -0800
Message-ID: <1416147798-16561-6-git-send-email-edumazet@google.com>
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
Received: from mail-ob0-f201.google.com ([209.85.214.201]:40452 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbaKPOXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:54 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so2677153obb.0
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:53 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_rss_key_fill() helper, as it provides better support for some
bonding setups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index c3861de9dc81..323721838cf9 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2054,7 +2054,7 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 				 BFI_ENET_RSS_IPV4_TCP);
 		rx_config->rss_config.hash_mask =
 				bnad->num_rxp_per_rx - 1;
-		get_random_bytes(rx_config->rss_config.toeplitz_hash_key,
+		netdev_rss_key_fill(rx_config->rss_config.toeplitz_hash_key,
 			sizeof(rx_config->rss_config.toeplitz_hash_key));
 	} else {
 		rx_config->rss_status = BNA_STATUS_T_DISABLED;
-- 
2.1.0.rc2.206.gedb03e5
