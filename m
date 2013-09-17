From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/5] sfc: Disable PTP on EF10 until we're ready to
 handle inline RX timestamps
Date: Tue, 17 Sep 2013 01:12:08 +0100
Message-ID: <1379376728.1945.13.camel@bwh-desktop.uk.level5networks.com>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21850 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab3IQAMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:12:12 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike Siena where timestamping is provided by a peripheral, EF10
delivers RX timestamps in the packet prefix.  However the driver
doesn't yet support this.

We are also creating a PHC device for each EF10 function, even though
the clock is really shared between all of them.

Disable hardware PTP/timestamping support until it's complete.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5f42313..357a6e5 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -260,8 +260,6 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
-	efx_ptp_probe(efx);
-
 	return 0;
 
 fail3:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
