From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 01/15] sfc: Add code to export port_num in netdev->dev_port
Date: Tue, 2 Jun 2015 11:37:25 +0100
Message-ID: <556D8765.2030006@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:23434 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754065AbbFBKhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:37:47 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where we have multiple functions (PFs and VFs), this
sysfs entry is useful to identify the physical port corresponding
to the function we are interested in.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4eb6ab7..06605ab 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -249,6 +249,7 @@ static int efx_ef10_get_mac_address_vf(struct efx_nic *efx, u8 *mac_address)
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
+	struct net_device *net_dev = efx->net_dev;
 	int i, rc;
 
 	/* We can have one VI for each 8K region.  However, until we
@@ -329,6 +330,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail3;
 	efx->port_num = rc;
+	net_dev->dev_port = rc;
 
 	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
