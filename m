From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/20] sfc: Update board info for hardware monitor on
	SFN4111T-R5 and later
Date: Thu, 29 Jan 2009 19:19:59 +0000
Message-ID: <1233256799.3656.33.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:45393 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753789AbZA2TUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:20:01 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/sfe4001.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 95bb935..25037c7 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -375,18 +375,26 @@ static void sfn4111t_fini(struct efx_nic *efx)
 	i2c_unregister_device(efx->board_info.hwmon_client);
 }
 
-static struct i2c_board_info sfn4111t_hwmon_info = {
+static struct i2c_board_info sfn4111t_a0_hwmon_info = {
 	I2C_BOARD_INFO("max6647", 0x4e),
 	.irq		= -1,
 };
 
+static struct i2c_board_info sfn4111t_r5_hwmon_info = {
+	I2C_BOARD_INFO("max6646", 0x4d),
+	.irq		= -1,
+};
+
 int sfn4111t_init(struct efx_nic *efx)
 {
 	int i = 0;
 	int rc;
 
 	efx->board_info.hwmon_client =
-		i2c_new_device(&efx->i2c_adap, &sfn4111t_hwmon_info);
+		i2c_new_device(&efx->i2c_adap,
+			       (efx->board_info.minor < 5) ?
+			       &sfn4111t_a0_hwmon_info :
+			       &sfn4111t_r5_hwmon_info);
 	if (!efx->board_info.hwmon_client)
 		return -EIO;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

