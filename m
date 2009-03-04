From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/7] sfc: Clear I2C adapter structure in falcon_remove_nic()
Date: Wed, 04 Mar 2009 19:53:02 +0000
Message-ID: <1236196382.3140.21.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52848 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755947AbZCDTxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:53:05 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i2c_del_adapter() leaves dangling pointers in the structure.  If we
retry the NIC probe and pass the structure to i2c_add_adapter() again
it will lead to an oops unless we clear it first.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9e2f0f0..efd121c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3114,8 +3114,10 @@ void falcon_remove_nic(struct efx_nic *efx)
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
+	/* Remove I2C adapter and clear it in preparation for a retry */
 	rc = i2c_del_adapter(&efx->i2c_adap);
 	BUG_ON(rc);
+	memset(&efx->i2c_adap, 0, sizeof(efx->i2c_adap));
 
 	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

