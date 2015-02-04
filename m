From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ath10k: Delete unnecessary checks before the function call
 "release_firmware"
Date: Wed, 04 Feb 2015 19:33:56 +0100
Message-ID: <54D26614.2080708@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 4 Feb 2015 19:30:23 +0100

The release_firmware() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ath/ath10k/core.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index 2d0671e..45171ad 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -393,16 +393,16 @@ static int ath10k_download_fw(struct ath10k *ar, enum ath10k_firmware_mode mode)
 
 static void ath10k_core_free_firmware_files(struct ath10k *ar)
 {
-	if (ar->board && !IS_ERR(ar->board))
+	if (!IS_ERR(ar->board))
 		release_firmware(ar->board);
 
-	if (ar->otp && !IS_ERR(ar->otp))
+	if (!IS_ERR(ar->otp))
 		release_firmware(ar->otp);
 
-	if (ar->firmware && !IS_ERR(ar->firmware))
+	if (!IS_ERR(ar->firmware))
 		release_firmware(ar->firmware);
 
-	if (ar->cal_file && !IS_ERR(ar->cal_file))
+	if (!IS_ERR(ar->cal_file))
 		release_firmware(ar->cal_file);
 
 	ar->board = NULL;
-- 
2.2.2
