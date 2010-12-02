From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 2/2] atm: lanai: use kernel's '%pM' format option to print MAC
Date: Thu,  2 Dec 2010 14:45:08 +0200
Message-ID: <1291293908-29180-2-git-send-email-andy.shevchenko@gmail.com>
References: <1291293908-29180-1-git-send-email-andy.shevchenko@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291293908-29180-1-git-send-email-andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
---
 drivers/atm/lanai.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index cbe15a8..930051d 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2241,11 +2241,8 @@ static int __devinit lanai_dev_open(struct atm_dev *atmdev)
 	memcpy(atmdev->esi, eeprom_mac(lanai), ESI_LEN);
 	lanai_timed_poll_start(lanai);
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): rev.%d, base=0x%lx, irq=%u "
-	    "(%02X-%02X-%02X-%02X-%02X-%02X)\n", lanai->number,
-	    (int) lanai->pci->revision, (unsigned long) lanai->base,
-	    lanai->pci->irq,
-	    atmdev->esi[0], atmdev->esi[1], atmdev->esi[2],
-	    atmdev->esi[3], atmdev->esi[4], atmdev->esi[5]);
+		"(%pMF)\n", lanai->number, (int) lanai->pci->revision,
+		(unsigned long) lanai->base, lanai->pci->irq, atmdev->esi);
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): LANAI%s, serialno=%u(0x%X), "
 	    "board_rev=%d\n", lanai->number,
 	    lanai->type==lanai2 ? "2" : "HB", (unsigned int) lanai->serialno,
-- 
1.7.2.3
