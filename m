From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/14] igb: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:14 -0800
Message-ID: <1416147798-16561-11-git-send-email-edumazet@google.com>
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
Received: from mail-qc0-f201.google.com ([209.85.216.201]:63202 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbaKPOYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:13 -0500
Received: by mail-qc0-f201.google.com with SMTP id m20so48096qcx.4
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:12 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of well known RSS key increases attack surface.
Switch to a random one, using generic helper so that all
ports share a common key.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1e35fae7a62b..b0e12e7c4a3d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3372,14 +3372,11 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 mrqc, rxcsum;
 	u32 j, num_rx_queues;
-	static const u32 rsskey[10] = { 0xDA565A6D, 0xC20E5B25, 0x3D256741,
-					0xB08FA343, 0xCB2BCAD0, 0xB4307BAE,
-					0xA32DCB77, 0x0CF23080, 0x3BB7426A,
-					0xFA01ACBE };
+	u32 rss_key[10];
 
-	/* Fill out hash function seeds */
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	for (j = 0; j < 10; j++)
-		wr32(E1000_RSSRK(j), rsskey[j]);
+		wr32(E1000_RSSRK(j), rss_key[j]);
 
 	num_rx_queues = adapter->rss_queues;
 
-- 
2.1.0.rc2.206.gedb03e5
