From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v3 1/7] net: pch_gbe: Mark Minnow PHY reset GPIO active low
Date: Fri, 2 Jun 2017 16:40:36 -0700
Message-ID: <20170602234042.22782-2-paul.burton@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, <linux-mips@linux-mips.org>,
        Eric Dumazet <edumazet@google.com>,
        Paul Burton <paul.burton@imgtec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:62784 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBXlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:41:52 -0400
In-Reply-To: <20170602234042.22782-1-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Minnow PHY reset GPIO is set to 0 to enter reset & 1 to leave reset
- that is, it is an active low GPIO. In order to allow for the code to
be made more generic by further patches, indicate to the GPIO subsystem
that the GPIO is active low & invert the values it is set to such that
they reflect logically whether the device is being reset or not.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
---

Changes in v3: None
Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 5ae9681a2da7..d38198718005 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2696,7 +2696,8 @@ static int pch_gbe_probe(struct pci_dev *pdev,
  */
 static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
 {
-	unsigned long flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
+	unsigned long flags = GPIOF_DIR_OUT | GPIOF_INIT_LOW |
+		GPIOF_EXPORT | GPIOF_ACTIVE_LOW;
 	unsigned gpio = MINNOW_PHY_RESET_GPIO;
 	int ret;
 
@@ -2708,10 +2709,10 @@ static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
 		return ret;
 	}
 
-	gpio_set_value(gpio, 0);
-	usleep_range(1250, 1500);
 	gpio_set_value(gpio, 1);
 	usleep_range(1250, 1500);
+	gpio_set_value(gpio, 0);
+	usleep_range(1250, 1500);
 
 	return ret;
 }
-- 
2.13.0
