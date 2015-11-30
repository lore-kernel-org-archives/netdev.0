From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH 21/28] net: pch_gbe: mark Minnow PHY reset GPIO active low
Date: Mon, 30 Nov 2015 16:21:46 +0000
Message-ID: <1448900513-20856-22-git-send-email-paul.burton@imgtec.com>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Minnow PHY reset GPIO is set to 0 to enter reset & 1 to leave reset
- that is, it is an active low GPIO. In order to allow for the code to
be made more generic by further patches, indicate to the GPIO subsystem
that the GPIO is active low & invert the values it is set to such that
they reflect logically whether the device is being reset or not.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
---

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3b98b263b..fde4c11 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2717,7 +2717,8 @@ err_free_netdev:
  */
 static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
 {
-	unsigned long flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
+	unsigned long flags = GPIOF_DIR_OUT | GPIOF_INIT_LOW |
+		GPIOF_EXPORT | GPIOF_ACTIVE_LOW;
 	unsigned gpio = MINNOW_PHY_RESET_GPIO;
 	int ret;
 
@@ -2729,10 +2730,10 @@ static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
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
2.6.2
