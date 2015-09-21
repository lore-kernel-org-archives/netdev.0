From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 17/38] isdn: hisax: fix frame calculation
Date: Mon, 21 Sep 2015 15:33:49 +0200
Message-ID: <1442842450-29769-18-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Difference of unsigned values is also unsigned so it does not make
sense to check its sign.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/isdn/hisax/hfc4s8s_l1.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 0e5d673..9600cd7 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -646,14 +646,14 @@ rx_d_frame(struct hfc4s8s_l1 *l1p, int ech)
 
 		f1 = Read_hfc8_stable(l1p->hw, A_F1);
 		f2 = Read_hfc8(l1p->hw, A_F2);
-		df = f1 - f2;
-		if ((f1 - f2) < 0)
-			df = f1 - f2 + MAX_F_CNT + 1;
 
+		if (f1 < f2)
+			df = MAX_F_CNT + 1 + f1 - f2;
+		else
+			df = f1 - f2;
 
-		if (!df) {
+		if (!df)
 			return;	/* no complete frame in fifo */
-		}
 
 		z1 = Read_hfc16_stable(l1p->hw, A_Z1);
 		z2 = Read_hfc16(l1p->hw, A_Z2);
-- 
1.9.1
