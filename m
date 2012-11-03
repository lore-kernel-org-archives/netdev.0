From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/8] drivers/net/wireless/ath/ath6kl/hif.c: drop if around WARN_ON
Date: Sat,  3 Nov 2012 21:30:25 +0100
Message-ID: <1351974625-10282-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1351974625-10282-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351974625-10282-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Just use WARN_ON rather than an if containing only WARN_ON(1).

A simplified version of the semantic patch that makes this transformation
is as follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e;
@@
- if (e) WARN_ON(1);
+ WARN_ON(e);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/ath/ath6kl/hif.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/hif.c b/drivers/net/wireless/ath/ath6kl/hif.c
index 68ed6c2..9e47c4a 100644
--- a/drivers/net/wireless/ath/ath6kl/hif.c
+++ b/drivers/net/wireless/ath/ath6kl/hif.c
@@ -338,8 +338,7 @@ static int ath6kl_hif_proc_err_intr(struct ath6kl_device *dev)
 	status = hif_read_write_sync(dev->ar, ERROR_INT_STATUS_ADDRESS,
 				     reg_buf, 4, HIF_WR_SYNC_BYTE_FIX);
 
-	if (status)
-		WARN_ON(1);
+	WARN_ON(status);
 
 	return status;
 }
@@ -383,8 +382,7 @@ static int ath6kl_hif_proc_cpu_intr(struct ath6kl_device *dev)
 	status = hif_read_write_sync(dev->ar, CPU_INT_STATUS_ADDRESS,
 				     reg_buf, 4, HIF_WR_SYNC_BYTE_FIX);
 
-	if (status)
-		WARN_ON(1);
+	WARN_ON(status);
 
 	return status;
 }
