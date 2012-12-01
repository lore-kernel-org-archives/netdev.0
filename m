From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/13] sfc: Do not initialise buffer in
 efx_alloc_special_buffer()
Date: Sat, 1 Dec 2012 04:42:59 +0000
Message-ID: <1354336979.2640.47.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26168 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab2LAEnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:43:02 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we initialise the newly allocated buffer to all-1s, which is
important for event queues but not for descriptor queues.  And since
we also do that in efx_nic_init_eventq(), it is completely pointless
to do it here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 368659d..1327f29 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -255,9 +255,6 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 	buffer->entries = len / EFX_BUF_SIZE;
 	BUG_ON(buffer->dma_addr & (EFX_BUF_SIZE - 1));
 
-	/* All zeros is a potentially valid event so memset to 0xff */
-	memset(buffer->addr, 0xff, len);
-
 	/* Select new buffer ID */
 	buffer->index = efx->next_buffer_table;
 	efx->next_buffer_table += buffer->entries;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
