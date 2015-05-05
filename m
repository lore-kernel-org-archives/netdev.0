From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 04/14] sfc: Use MCDI to set FILTER_OP_IN_TX_DOMAIN
Date: Wed, 6 May 2015 00:56:24 +0100
Message-ID: <554958A8.8010608@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:41989 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753064AbbEEX4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:56:30 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX_DOMAIN field is currently reserved but its safer to set
it to 0 for future compatibility.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e8450bb..ad23018 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2292,6 +2292,7 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 		       spec->dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP ?
 		       MC_CMD_FILTER_OP_IN_RX_DEST_DROP :
 		       MC_CMD_FILTER_OP_IN_RX_DEST_HOST);
+	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_TX_DOMAIN, 0);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_TX_DEST,
 		       MC_CMD_FILTER_OP_IN_TX_DEST_DEFAULT);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_QUEUE,
