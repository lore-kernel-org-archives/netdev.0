From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/14] vmxnet3: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:18 -0800
Message-ID: <1416147798-16561-15-git-send-email-edumazet@google.com>
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
Received: from mail-pd0-f202.google.com ([209.85.192.202]:38874 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaKPOYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:23 -0500
Received: by mail-pd0-f202.google.com with SMTP id g10so28685pdj.5
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:23 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of well known RSS key increases attack surface.
Switch to a random one, using generic helper so that all
ports share a common key.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 6dfcbf523936..afd295348ddb 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2199,13 +2199,6 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 
 	if (adapter->rss) {
 		struct UPT1_RSSConf *rssConf = adapter->rss_conf;
-		static const uint8_t rss_key[UPT1_RSS_MAX_KEY_SIZE] = {
-			0x3b, 0x56, 0xd1, 0x56, 0x13, 0x4a, 0xe7, 0xac,
-			0xe8, 0x79, 0x09, 0x75, 0xe8, 0x65, 0x79, 0x28,
-			0x35, 0x12, 0xb9, 0x56, 0x7c, 0x76, 0x4b, 0x70,
-			0xd8, 0x56, 0xa3, 0x18, 0x9b, 0x0a, 0xee, 0xf3,
-			0x96, 0xa6, 0x9f, 0x8f, 0x9e, 0x8c, 0x90, 0xc9,
-		};
 
 		devRead->misc.uptFeatures |= UPT1_F_RSS;
 		devRead->misc.numRxQueues = adapter->num_rx_queues;
@@ -2216,7 +2209,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		rssConf->hashFunc = UPT1_RSS_HASH_FUNC_TOEPLITZ;
 		rssConf->hashKeySize = UPT1_RSS_MAX_KEY_SIZE;
 		rssConf->indTableSize = VMXNET3_RSS_IND_TABLE_SIZE;
-		memcpy(rssConf->hashKey, rss_key, sizeof(rss_key));
+		netdev_rss_key_fill(rssConf->hashKey, sizeof(rssConf->hashKey));
 
 		for (i = 0; i < rssConf->indTableSize; i++)
 			rssConf->indTable[i] = ethtool_rxfh_indir_default(
-- 
2.1.0.rc2.206.gedb03e5
