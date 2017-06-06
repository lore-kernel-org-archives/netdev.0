From: Colin King <colin.king@canonical.com>
Subject: [PATCH] i40evf: remove redundant null check on key
Date: Wed,  7 Jun 2017 00:54:07 +0100
Message-ID: <20170606235407.6478-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

key has previously been null checked so the subsequent null check
is redundant as key can never be null at that point, so remove it.

Detected by CoverityScan, CID#1357164 ("Logically dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 9bb2cc7dd4e4..838e57c6e176 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -732,9 +732,7 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 	if (!indir)
 		return 0;
 
-	if (key) {
-		memcpy(adapter->rss_key, key, adapter->rss_key_size);
-	}
+	memcpy(adapter->rss_key, key, adapter->rss_key_size);
 
 	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
 	for (i = 0; i < adapter->rss_lut_size; i++)
-- 
2.11.0
