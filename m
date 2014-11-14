From: Dmitry Torokhov <dtor@chromium.org>
Subject: [PATCH] brcmfmac: fix error handling of irq_of_parse_and_map
Date: Fri, 14 Nov 2014 14:12:21 -0800
Message-ID: <20141114221221.GA35541@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return value of irq_of_parse_and_map() is unsigned int, with 0
indicating failure, so testing for negative result never works.

Signed-off-by: Dmitry Torokhov <dtor@chromium.org>
---

Not tested, found by casual code inspection.

 drivers/net/wireless/brcm80211/brcmfmac/of.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/of.c b/drivers/net/wireless/brcm80211/brcmfmac/of.c
index eb3fce82..c824570 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/of.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/of.c
@@ -40,8 +40,8 @@ void brcmf_of_probe(struct brcmf_sdio_dev *sdiodev)
 		return;
 
 	irq = irq_of_parse_and_map(np, 0);
-	if (irq < 0) {
-		brcmf_err("interrupt could not be mapped: err=%d\n", irq);
+	if (!irq) {
+		brcmf_err("interrupt could not be mapped\n");
 		devm_kfree(dev, sdiodev->pdata);
 		return;
 	}
-- 
2.1.0.rc2.206.gedb03e5


-- 
Dmitry
