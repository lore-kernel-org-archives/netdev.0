From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 04/17] sfc: Read-to-clear LM87 alarm/interrupt
 status at start of day
Date: Thu, 02 Dec 2010 23:46:31 +0000
Message-ID: <1291333591.3259.27.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12999 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179Ab0LBXqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:34 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not want to shut down the board based on a fault that has
already been cleared.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_boards.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 86180ee..6c20d45 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -99,6 +99,10 @@ static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
 	if (!client)
 		return -EIO;
 
+	/* Read-to-clear alarm/interrupt status */
+	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+
 	rc = efx_poke_lm87(client, reg_values);
 	if (rc)
 		goto err;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

