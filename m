From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH -next] sfc: Don't specify unexistent IRQ
Date: Wed, 8 Apr 2009 03:38:20 +0100
Message-ID: <20090408023819.GA14188@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jean Delvare <khali@linux-fr.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60724 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756927AbZDHCic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 22:38:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>

Neither the lm90 driver nor the lm87 driver do support interrupts, so
there is no point in specifying one when declaring the devices.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c  |    2 --
 drivers/net/sfc/sfe4001.c |    3 ---
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 5182ac5..4a4c74c 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -172,7 +172,6 @@ static const u8 sfe4002_lm87_regs[] = {
 static struct i2c_board_info sfe4002_hwmon_info = {
 	I2C_BOARD_INFO("lm87", 0x2e),
 	.platform_data	= &sfe4002_lm87_channel,
-	.irq		= -1,
 };
 
 /****************************************************************************/
@@ -247,7 +246,6 @@ static const u8 sfn4112f_lm87_regs[] = {
 static struct i2c_board_info sfn4112f_hwmon_info = {
 	I2C_BOARD_INFO("lm87", 0x2e),
 	.platform_data	= &sfn4112f_lm87_channel,
-	.irq		= -1,
 };
 
 #define SFN4112F_ACT_LED	0
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 4eac5da..cee00ad 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -296,7 +296,6 @@ static int sfe4001_check_hw(struct efx_nic *efx)
 
 static struct i2c_board_info sfe4001_hwmon_info = {
 	I2C_BOARD_INFO("max6647", 0x4e),
-	.irq		= -1,
 };
 
 /* This board uses an I2C expander to provider power to the PHY, which needs to
@@ -389,12 +388,10 @@ static void sfn4111t_fini(struct efx_nic *efx)
 
 static struct i2c_board_info sfn4111t_a0_hwmon_info = {
 	I2C_BOARD_INFO("max6647", 0x4e),
-	.irq		= -1,
 };
 
 static struct i2c_board_info sfn4111t_r5_hwmon_info = {
 	I2C_BOARD_INFO("max6646", 0x4d),
-	.irq		= -1,
 };
 
 int sfn4111t_init(struct efx_nic *efx)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
