From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/14] e100e: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:11 -0800
Message-ID: <1416147798-16561-8-git-send-email-edumazet@google.com>
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
Received: from mail-oi0-f74.google.com ([209.85.218.74]:58756 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086AbaKPOYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:02 -0500
Received: by mail-oi0-f74.google.com with SMTP id e131so94247oig.1
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:01 -0800 (PST)
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
 drivers/net/ethernet/intel/e1000e/netdev.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 247335d2c7ec..370cfa275ddb 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3449,15 +3449,12 @@ static void e1000e_setup_rss_hash(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 mrqc, rxcsum;
+	u32 rss_key[10];
 	int i;
-	static const u32 rsskey[10] = {
-		0xda565a6d, 0xc20e5b25, 0x3d256741, 0xb08fa343, 0xcb2bcad0,
-		0xb4307bae, 0xa32dcb77, 0x0cf23080, 0x3bb7426a, 0xfa01acbe
-	};
 
-	/* Fill out hash function seed */
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	for (i = 0; i < 10; i++)
-		ew32(RSSRK(i), rsskey[i]);
+		ew32(RSSRK(i), rss_key[i]);
 
 	/* Direct all traffic to queue 0 */
 	for (i = 0; i < 32; i++)
-- 
2.1.0.rc2.206.gedb03e5
