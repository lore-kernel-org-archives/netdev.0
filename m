From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 3/4] net: wireless: remove unnecessary platform_set_drvdata()
Date: Tue, 28 May 2013 14:07:11 +0900
Message-ID: <000301ce5b61$368e3dd0$a3aab970$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	"'John W. Linville'" <linville@tuxdriver.com>,
	'Jiri Slaby' <jirislaby@gmail.com>,
	'Nick Kossifidis' <mickflemm@gmail.com>,
	"'Luis R. Rodriguez'" <mcgrof@qca.qualcomm.com>,
	'Jouni Malinen' <jouni@qca.qualcomm.com>,
	'Vasanthakumar Thiagarajan' <vthiagar@qca.qualcomm.com>,
	'Senthil Balasubramanian' <senthilb@qca.qualcomm.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:49935 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124Ab3E1FHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:07:14 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNH00HA4SVP3DO0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 28 May 2013 14:07:13 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/ath/ath5k/ahb.c |    2 --
 drivers/net/wireless/ath/ath9k/ahb.c |    2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
index 8e8bcc7a..e9bc9e6 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -185,7 +185,6 @@ static int ath_ahb_probe(struct platform_device *pdev)
 
  err_free_hw:
 	ieee80211_free_hw(hw);
-	platform_set_drvdata(pdev, NULL);
  err_iounmap:
         iounmap(mem);
  err_out:
@@ -221,7 +220,6 @@ static int ath_ahb_remove(struct platform_device *pdev)
 
 	ath5k_deinit_ah(ah);
 	iounmap(ah->iobase);
-	platform_set_drvdata(pdev, NULL);
 	ieee80211_free_hw(hw);
 
 	return 0;
diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index d1ff3c2..072e4b5 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -150,7 +150,6 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	free_irq(irq, sc);
  err_free_hw:
 	ieee80211_free_hw(hw);
-	platform_set_drvdata(pdev, NULL);
 	return ret;
 }
 
@@ -164,7 +163,6 @@ static int ath_ahb_remove(struct platform_device *pdev)
 		ath9k_deinit_device(sc);
 		free_irq(sc->irq, sc);
 		ieee80211_free_hw(sc->hw);
-		platform_set_drvdata(pdev, NULL);
 	}
 
 	return 0;
-- 
1.7.10.4
