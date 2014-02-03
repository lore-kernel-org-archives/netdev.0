From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 08/13] sfc: Preserve rx_frm_trunc counters when resizing
 DMA rings
Date: Mon, 3 Feb 2014 23:35:05 +0000
Message-ID: <52F027A9.7070104@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8189 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbaBCXfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:35:09 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

We allocate efx_channel structures with kzalloc() so we don't need to
zero-initialise individual fields in efx_probe_channel().  Further,
this function will be called again during DMA ring resizing and we
should not reset any statistics then.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 83d4643..84a1e11 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -503,8 +503,6 @@ static int efx_probe_channel(struct efx_channel *channel)
 			goto fail;
 	}
 
-	channel->n_rx_frm_trunc = 0;
-
 	return 0;
 
 fail:
