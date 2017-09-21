From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 50/64] drivers: net: can: sja1000: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:11 +0530
Message-ID: <1506013525-29291-51-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/can/sja1000/peak_pcmcia.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index dd56133..4b8758e 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -692,9 +692,7 @@ static int pcan_probe(struct pcmcia_device *pdev)
 	}
 
 	/* init the timer which controls the leds */
-	init_timer(&card->led_timer);
-	card->led_timer.function = pcan_led_timer;
-	card->led_timer.data = (unsigned long)card;
+	setup_timer(&card->led_timer, pcan_led_timer, (unsigned long)card);
 
 	/* request the given irq */
 	err = request_irq(pdev->irq, &pcan_isr, IRQF_SHARED, PCC_NAME, card);
-- 
2.7.4
