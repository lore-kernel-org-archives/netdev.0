From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 11/15] sfc: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:42 -0400
Message-ID: <1473689026-6983-12-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/sfc/falcon_boards.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
index 1736f4b806af..f6883b2b5da3 100644
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ b/drivers/net/ethernet/sfc/falcon_boards.c
@@ -64,7 +64,7 @@
 #define LM87_ALARM_TEMP_INT		0x10
 #define LM87_ALARM_TEMP_EXT1		0x20
 
-#if defined(CONFIG_SENSORS_LM87) || defined(CONFIG_SENSORS_LM87_MODULE)
+#if IS_ENABLED(CONFIG_SENSORS_LM87)
 
 static int efx_poke_lm87(struct i2c_client *client, const u8 *reg_values)
 {
@@ -455,7 +455,7 @@ static int sfe4001_init(struct efx_nic *efx)
 	struct falcon_board *board = falcon_board(efx);
 	int rc;
 
-#if defined(CONFIG_SENSORS_LM90) || defined(CONFIG_SENSORS_LM90_MODULE)
+#if IS_ENABLED(CONFIG_SENSORS_LM90)
 	board->hwmon_client =
 		i2c_new_device(&board->i2c_adap, &sfe4001_hwmon_info);
 #else
-- 
2.7.4
