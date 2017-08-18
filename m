From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 04/13] amd-xgbe: Update TSO packet statistics
 accuracy
Date: Fri, 18 Aug 2017 09:02:49 -0500
Message-ID: <20170818140249.14804.75400.stgit@tlendack-t1.amdoffice.net>
References: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0060.outbound.protection.outlook.com ([104.47.42.60]:20163
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752693AbdHROCx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 10:02:53 -0400
In-Reply-To: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When transmitting a TSO packet, the driver only increments the TSO packet
statistic by one rather than the number of total packets that were sent.
Update the driver to record the total number of packets that resulted from
TSO transmit.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 06f953e..bb60507 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1740,7 +1740,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TCPHDRLEN,
 				  packet->tcp_header_len / 4);
 
-		pdata->ext_stats.tx_tso_packets++;
+		pdata->ext_stats.tx_tso_packets += packet->tx_packets;
 	} else {
 		/* Enable CRC and Pad Insertion */
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CPC, 0);
