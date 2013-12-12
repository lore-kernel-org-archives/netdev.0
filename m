From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/16] sfc: Return EBUSY for filter insertion on
 EF10, matching Falcon/Siena
Date: Thu, 12 Dec 2013 23:03:06 +0000
Message-ID: <1386889386.1516.351.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29549 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab3LLXDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:03:09 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MC firmware will return error MC_CMD_ERR_ENOSPC if filter
insertion fails due to lack of resources.  The net driver's filter
implementation for Falcon-architecture returns EBUSY.  They should
behave consistently, so for EF10 change ENOSPC to EBUSY.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 45af374b1df9..ca922b958a2e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2259,6 +2259,8 @@ static int efx_ef10_filter_push(struct efx_nic *efx,
 			  outbuf, sizeof(outbuf), NULL);
 	if (rc == 0)
 		*handle = MCDI_QWORD(outbuf, FILTER_OP_OUT_HANDLE);
+	if (rc == -ENOSPC)
+		rc = -EBUSY; /* to match efx_farch_filter_insert() */
 	return rc;
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
