From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/5] drivers/net/wireless/ath/ath6kl/main.c: introduce missing initialization
Date: Sat, 18 Aug 2012 23:25:58 +0200
Message-ID: <1345325159-7365-4-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The result of one call to a function is tested, and then at the second call
to the same function, the previous result, and not the current result, is
tested again.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression ret;
identifier f;
statement S1,S2;
@@

*ret = f(...);
if (\(ret != 0\|ret < 0\|ret == NULL\)) S1
... when any
*f(...);
if (\(ret != 0\|ret < 0\|ret == NULL\)) S2
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/ath/ath6kl/main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index c189e28..c312c61 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -322,7 +322,8 @@ int ath6kl_read_fwlogs(struct ath6kl *ar)
 
 		address = TARG_VTOP(ar->target_type,
 				    le32_to_cpu(debug_buf.next));
-		ath6kl_diag_read(ar, address, &debug_buf, sizeof(debug_buf));
+		ret = ath6kl_diag_read(ar, address, &debug_buf,
+				       sizeof(debug_buf));
 		if (ret)
 			goto out;
 
