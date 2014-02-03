From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 07/13] sfc: Correct comment about number of TX queues
 used on EF10
Date: Mon, 3 Feb 2014 23:34:52 +0000
Message-ID: <52F0279C.4060504@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8183 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819AbaBCXez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:34:55 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

EF10 implements option descriptors to switch TX checksum offload
on and off between packets.  We could therefore use a single
hardware TX queue per kernel TX queue, although we don't yet.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 174a92f..3b39798 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -172,8 +172,8 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	struct efx_ef10_nic_data *nic_data;
 	int i, rc;
 
-	/* We can have one VI for each 8K region.  However we need
-	 * multiple TX queues per channel.
+	/* We can have one VI for each 8K region.  However, until we
+	 * use TX option descriptors we need two TX queues per channel.
 	 */
 	efx->max_channels =
 		min_t(unsigned int,
