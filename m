From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/11] sfc: Update board info for hardware monitor on SFN4111T-R5 and later
Date: Fri, 30 Jan 2009 03:51:48 +0000
Message-ID: <20090130035147.GJ15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35577 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbZA3Dvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:51:50 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/sfe4001.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index c7c95db..853057e 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -375,17 +375,25 @@ static void sfn4111t_fini(struct efx_nic *efx)
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
