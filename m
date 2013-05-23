From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Use descriptive label names in
 tg3_start
Date: Thu, 23 May 2013 14:11:25 -0700
Message-ID: <1369343487-6453-5-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1134 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758494Ab3EWVLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:41 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3906327..98b770e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11207,7 +11207,7 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 	 */
 	err = tg3_alloc_consistent(tp);
 	if (err)
-		goto err_out1;
+		goto out_ints_fini;
 
 	tg3_napi_init(tp);
 
@@ -11221,7 +11221,7 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 				tnapi = &tp->napi[i];
 				free_irq(tnapi->irq_vec, tnapi);
 			}
-			goto err_out2;
+			goto out_napi_fini;
 		}
 	}
 
@@ -11239,7 +11239,7 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 	tg3_full_unlock(tp);
 
 	if (err)
-		goto err_out3;
+		goto out_free_irq;
 
 	if (test_irq && tg3_flag(tp, USING_MSI)) {
 		err = tg3_test_msi(tp);
@@ -11250,7 +11250,7 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 			tg3_free_rings(tp);
 			tg3_full_unlock(tp);
 
-			goto err_out2;
+			goto out_napi_fini;
 		}
 
 		if (!tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
@@ -11290,18 +11290,18 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 
 	return 0;
 
-err_out3:
+out_free_irq:
 	for (i = tp->irq_cnt - 1; i >= 0; i--) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		free_irq(tnapi->irq_vec, tnapi);
 	}
 
-err_out2:
+out_napi_fini:
 	tg3_napi_disable(tp);
 	tg3_napi_fini(tp);
 	tg3_free_consistent(tp);
 
-err_out1:
+out_ints_fini:
 	tg3_ints_fini(tp);
 
 	return err;
-- 
1.8.1.4
