From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 09/13] sfc: Use canonical pointer type for MAC address
 in efx_set_mac_address()
Date: Wed, 12 Feb 2014 18:59:54 +0000
Message-ID: <52FBC4AA.9070404@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50971 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaBLS77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:59:59 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Functions such as is_valid_ether_addr() expect u8 *, so use that
instead of char *.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 84a1e11..91acdc2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2113,7 +2113,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct sockaddr *addr = data;
-	char *new_addr = addr->sa_data;
+	u8 *new_addr = addr->sa_data;
 
 	if (!is_valid_ether_addr(new_addr)) {
 		netif_err(efx, drv, efx->net_dev,
