From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: stop setting dev_port
Date: Tue, 10 Jan 2017 16:24:31 +0000
Message-ID: <913fe512-d799-8b98-7c7a-a7b6064af821@solarflare.com>
References: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:48827 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759649AbdAJQYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:24:40 -0500
In-Reply-To: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

Setting dev_port changes the device names allocated by systemd. Any devices
with a dev_port >0 will (in default distro configurations) have a suffix of
"d<port-number>" appended.

This is not something done by other drivers, and causes confusion for users.

Fixes: 8be41320f346 ("sfc: Add code to export port_num in netdev->dev_port")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4f3c965..208e004 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -547,7 +547,6 @@ static DEVICE_ATTR(primary_flag, 0444, efx_ef10_show_primary_flag, NULL);
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
-	struct net_device *net_dev = efx->net_dev;
 	int i, rc;
 
 	/* We can have one VI for each 8K region.  However, until we
@@ -637,7 +636,6 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail5;
 	efx->port_num = rc;
-	net_dev->dev_port = rc;
 
 	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
