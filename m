From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/14] ixgbe: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:15 -0800
Message-ID: <1416147798-16561-12-git-send-email-edumazet@google.com>
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
Received: from mail-yh0-f73.google.com ([209.85.213.73]:57062 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaKPOYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:16 -0500
Received: by mail-yh0-f73.google.com with SMTP id f10so469742yha.2
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:15 -0800 (PST)
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f5fcba4f9d21..932f77961d66 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3243,10 +3243,8 @@ static void ixgbe_setup_reta(struct ixgbe_adapter *adapter, const u32 *seed)
 static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
-			  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
-			  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 mrqc = 0, rss_field = 0;
+	u32 rss_key[10];
 	u32 rxcsum;
 
 	/* Disable indicating checksum in descriptor, enables RSS hash */
@@ -3290,7 +3288,8 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
 		rss_field |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
 
-	ixgbe_setup_reta(adapter, seed);
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
+	ixgbe_setup_reta(adapter, rss_key);
 	mrqc |= rss_field;
 	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 }
-- 
2.1.0.rc2.206.gedb03e5
