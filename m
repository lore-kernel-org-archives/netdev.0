From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/14] bnx2x: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:07 -0800
Message-ID: <1416147798-16561-4-git-send-email-edumazet@google.com>
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
Received: from mail-ie0-f202.google.com ([209.85.223.202]:42802 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbaKPOXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:45 -0500
Received: by mail-ie0-f202.google.com with SMTP id tr6so53548ieb.3
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:44 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_rss_key_fill() helper, as it provides better support for some
bonding setups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e9af4af5edba..b4d71fd909ee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2099,7 +2099,7 @@ int bnx2x_rss(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 
 	if (config_hash) {
 		/* RSS keys */
-		prandom_bytes(params.rss_key, T_ETH_RSS_KEY * 4);
+		netdev_rss_key_fill(params.rss_key, T_ETH_RSS_KEY * 4);
 		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
 	}
 
-- 
2.1.0.rc2.206.gedb03e5
