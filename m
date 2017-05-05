From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] bna: ethtool: Avoid reading past end of buffer
Date: Fri, 5 May 2017 15:30:23 -0700
Message-ID: <20170505223023.GA17972@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rasesh Mody <rasesh.mody@cavium.com>,
        Sudarsana Kalluru <sudarsana.kalluru@cavium.com>,
        linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        Daniel Micay <danielmicay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using memcpy() from a string that is shorter than the length copied means
the destination buffer is being filled with arbitrary data from the kernel
rodata segment. Instead, use strncpy() which will fill the trailing bytes
with zeros.

This was found with the future CONFIG_FORTIFY_SOURCE feature.

Cc: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 286593922139..31032de5843b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -547,8 +547,8 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 *string)
 		for (i = 0; i < BNAD_ETHTOOL_STATS_NUM; i++) {
 			BUG_ON(!(strlen(bnad_net_stats_strings[i]) <
 				   ETH_GSTRING_LEN));
-			memcpy(string, bnad_net_stats_strings[i],
-			       ETH_GSTRING_LEN);
+			strncpy(string, bnad_net_stats_strings[i],
+				ETH_GSTRING_LEN);
 			string += ETH_GSTRING_LEN;
 		}
 		bmap = bna_tx_rid_mask(&bnad->bna);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
