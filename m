From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] libertas: Avoid reading past end of buffer
Date: Tue, 9 May 2017 16:23:34 -0700
Message-ID: <20170509232334.GA55070@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, Daniel Micay <danielmicay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using memcpy() from a string that is shorter than the length copied means
the destination buffer is being filled with arbitrary data from the kernel
rodata segment. Instead, use strncpy() which will fill the trailing bytes
with zeros. Additionally adjust indentation to keep checkpatch.pl happy.

This was found with the future CONFIG_FORTIFY_SOURCE feature.

Cc: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/marvell/libertas/mesh.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
index d0c881dd5846..d0b1948ca242 100644
--- a/drivers/net/wireless/marvell/libertas/mesh.c
+++ b/drivers/net/wireless/marvell/libertas/mesh.c
@@ -1177,9 +1177,9 @@ void lbs_mesh_ethtool_get_strings(struct net_device *dev,
 	switch (stringset) {
 	case ETH_SS_STATS:
 		for (i = 0; i < MESH_STATS_NUM; i++) {
-			memcpy(s + i * ETH_GSTRING_LEN,
-					mesh_stat_strings[i],
-					ETH_GSTRING_LEN);
+			strncpy(s + i * ETH_GSTRING_LEN,
+				mesh_stat_strings[i],
+				ETH_GSTRING_LEN);
 		}
 		break;
 	}
-- 
2.7.4


-- 
Kees Cook
Pixel Security
