From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net] tg3: Expand led off fix to include 5720
Date: Thu, 12 Sep 2013 14:01:31 -0700
Message-ID: <1379019691-4618-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	stable@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 989038e217e94161862a959e82f9a1ecf8dda152 ("tg3: Don't turn off
led on 5719 serdes port 0") added code to skip turning led off on port
0 of the 5719 since it powered down other ports. This workaround needs
to be enabled on the 5720 as well.

Cc: stable@vger.kernel.org
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5701f3d..9011ea0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3034,6 +3034,7 @@ static bool tg3_phy_led_bug(struct tg3 *tp)
 {
 	switch (tg3_asic_rev(tp)) {
 	case ASIC_REV_5719:
+	case ASIC_REV_5720:
 		if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
 		    !tp->pci_fn)
 			return true;
-- 
1.8.1.4
