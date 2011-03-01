From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 1/5] tg3: use usleep_range not msleep for small sleeps
Date: Tue,  1 Mar 2011 18:04:26 +0100
Message-ID: <1298999069-12740-2-git-send-email-martinez.javier@gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, kernelnewbies@kernelnewbies.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42940 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757002Ab1CAREZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:04:25 -0500
Received: by ewy6 with SMTP id 6so1731344ewy.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 09:04:24 -0800 (PST)
In-Reply-To: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/tg3.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6be4185..3310c7a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2410,7 +2410,7 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 
 		if (tmp & EEPROM_ADDR_COMPLETE)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (!(tmp & EEPROM_ADDR_COMPLETE))
 		return -EBUSY;
@@ -2688,7 +2688,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			tg3_read_mem(tp, NIC_SRAM_FW_ASF_STATUS_MBOX, &val);
 			if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
 				break;
-			msleep(1);
+			usleep_range(1000, 2000);
 		}
 	}
 	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
@@ -8901,7 +8901,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 			break;
 		}
 
-		msleep(10);
+		usleep_range(10000, 20000);
 	}
 
 	tg3_disable_ints(tp);
@@ -11863,7 +11863,7 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 	      (EEPROM_DEFAULT_CLOCK_PERIOD <<
 	       EEPROM_ADDR_CLKPERD_SHIFT)));
 
-	msleep(1);
+	usleep_range(1000, 2000);
 
 	/* Enable seeprom accesses. */
 	tw32_f(GRC_LOCAL_CTRL,
@@ -11956,7 +11956,7 @@ static int tg3_nvram_write_block_using_eeprom(struct tg3 *tp,
 
 			if (val & EEPROM_ADDR_COMPLETE)
 				break;
-			msleep(1);
+			usleep_range(1000, 2000);
 		}
 		if (!(val & EEPROM_ADDR_COMPLETE)) {
 			rc = -EBUSY;
@@ -12263,7 +12263,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	pci_read_config_word(tp->pdev, tp->pm_cap + PCI_PM_CTRL, &pmcsr);
 	pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
 	pci_write_config_word(tp->pdev, tp->pm_cap + PCI_PM_CTRL, pmcsr);
-	msleep(1);
+	usleep_range(1000, 2000);
 
 	/* Make sure register accesses (indirect or otherwise)
 	 * will function correctly.
-- 
1.7.2.3

