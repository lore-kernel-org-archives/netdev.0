From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] brcmfmac: Fix likely misuse of | for &
Date: Wed, 30 May 2012 13:25:56 -0700
Message-ID: <af79247f427979584f3e07753ec3ad4766844ec9.1338408931.git.joe@perches.com>
References: <cover.1338408931.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1338408931.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using | with a constant is always true.
Likely this should have be &.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index e2480d1..8e7e692 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -89,9 +89,9 @@ int brcmf_sdio_intr_register(struct brcmf_sdio_dev *sdiodev)
 	data |= 1 << SDIO_FUNC_1 | 1 << SDIO_FUNC_2 | 1;
 	brcmf_sdio_regwb(sdiodev, SDIO_CCCR_IENx, data, &ret);
 
-	/* redirect, configure ane enable io for interrupt signal */
+	/* redirect, configure and enable io for interrupt signal */
 	data = SDIO_SEPINT_MASK | SDIO_SEPINT_OE;
-	if (sdiodev->irq_flags | IRQF_TRIGGER_HIGH)
+	if (sdiodev->irq_flags & IRQF_TRIGGER_HIGH)
 		data |= SDIO_SEPINT_ACT_HI;
 	brcmf_sdio_regwb(sdiodev, SDIO_CCCR_BRCM_SEPINT, data, &ret);
 
-- 
1.7.8.111.gad25c.dirty
